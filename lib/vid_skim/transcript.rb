
# Transcript is a json parser/updater which parses a Video Skimmer formatted
# json file. Like Tube it is important that schema.json (a kwalify schema) 
# is kept in sync with this object.  

module VidSkim
  class Transcript
    attr_accessor :divisions, :title, :youtube_id, :duration

    def initialize(hash)
      @errors = []
      @divisions = {}
      @youtube_id = hash["youtube_id"]
      @title = hash["title"]
      @duration = hash["length"].to_i
      hash["divisions"].each_pair do |key, value|
                        @divisions["#{key}"] = Transcript::Division.new(key)
                        value.each_pair do |method, value|    
                          @divisions["#{key}"].send("#{method}=", value) 
                        end
                     end
    end
    
    # Returns the json representation
    def to_json
      self.to_hash.to_json
    end
    
    # Returns the hash representation
    def to_hash
      c = {}
      @divisions.each_pair{|d,v| c.merge!(v.collect)}
      c
    end 
  

    # Returns a parameterized version of the title for creating the actual
    # html file
    def slug
      Inflector.parameterize(@title, "_")
    end

  
    class << self
      # Searches for a Transcript based on a path
      def find(f)
        hash = JSON.parse(File.open("#{f}").read)
        Transcript.new(hash)
      end
    end
    
  
    # The building blocks of transcripts: each Transcript::Division is a
    # different view to the video
    class Division

      attr_accessor :name, :color, :hover
      def initialize(name)
        @name = name
        @entries = []
      end
    
      # Sets each individual Entry from a straight hash of +entries+, which 
      # are synced to the video
      def entries=(entries)
        @entries=[]
        entries.each do |e|
                      entry = Transcript::Entry.new()
                      e.each_pair {|key, value| entry.send("#{key}=", value)}
                      @entries << entry
                     end
      end
    
      # Returns an array of entries ensuring that their sorted by the low end 
      # of each Range
      def entries
        @entries.sort!{|a, b| a.range.low <=> b.range.low }
      end
      
      # Collects each Entry and returns a hash
      def collect
        c = {
          @name => {
            "color"=> @color,
            "hover"=> @hover,
            "entries"=> []
          }
        }
        entries.each{ |e| c[@name]['entries'] << e.collect }
        c
      end
      
      
      
    
      # Builds a dynamic finder (<tt>unique_entries_by_attribute</tt> where 
      # attribute is an Entry attribute) so that filters returns unique entries 
      # you can do things like:
      #   >> entries = [{'title'=>'Hamm', 'range'=>["00:00:00", "00:00:00"]},
      #               {'title'=> 'Clove', 'range'=>["00:00:00", "00:00:00"]},
      #               {'title'=>'Hamm', 'range'=>["00:00:00", "00:00:00"]}]
      #   >> d = Transcript::Division.new('Endgame')
      #   >> d.entries = entries
      #   >> uniq = d.unique_entries_by_title
      #   >> uniq.each {|u| p u.title }
      #   "Hamm"
      #   "Clove"
      def method_missing(method_id, *args)
        if method_id.to_s =~ /unique_entries_by_([_a-zA-Z]\w*)$/
          unique_entries_by_($1.to_sym) #just having a bit of fun
        else
          super
        end
      end
      
      private
        # Uses a set to build the unique entries returned by method missing
        def unique_entries_by_(key) 
          seen = Set.new()
          entries.select { |e|
            k = e.send(key)
            seen.add?(k)
          }.sort{|a, b| a.range.low <=> b.range.low }
        end
    
    end
    # An Transcript::Entry is an individual section of video 
    class Entry
      attr_accessor :title, :range, :transcript, :extra
    
      def initialize()
      end
    
      # Sets a Transcript::Entry::Range object based on a +range+ of the format
      # ['hh:mm:ss', 'hh:mm:ss'].
      def range=(range)
        @range = Transcript::Entry::Range.new(range)
      end
    
      # Returns the original hash representation of this object
      def collect
        {
          "title"=> @title,
          "range"=> @range.collect,
          "transcript"=> @transcript,
          "extra"=> @extra,
          "annotation" => @annotation
        }
      end
    
      # A Transcript::Entry::Range parses a timecode.
      class Range

        # +range+ sould be of the format ['hh:mm:ss', 'hh:mm:ss']
        def initialize(range)
          @range_low = range.first
          @range_high = range.last
        end
        # Return the low end of the Transcript::Division::Entry::Range
        def low
          @range_low
        end
      
        # Return the high end of the Transcript::Division::Entry::Range
        def high
          @range_high
        end
      
        # Converts a Transcript::Division::Entry::Range into seconds, the
        # argument can either be :low or :high
        def to_seconds(sym)
          seconds = 0
          self.send(sym).split(':').reverse.each_with_index do |i, x|
            seconds += (x == 0 ? 1 : 60 ** x) * i.to_i
          end
          seconds
        end
      
        # Returns the original array representation of this object
        def collect
          [@range_low, @range_high]
        end
      end
    
    end
  
  end
end
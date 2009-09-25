
# The Tube class thinly wraps the yaml defined in <tt>config/tube/schema.yaml</tt>, which
# is a kwalify schema definition. (Note: it's important to treat the schema
# as the canonical document, changes should be made there first, then here.)
# 
# Each Tube has essentially a many to one relationship to a Transcript. 
module VidSkim
  class Tube
  
  
    #The google api feed url.
    YT_FEED_URL = "http://gdata.youtube.com/feeds/api/videos/"
    attr_accessor :title            # str
    attr_accessor :youtube_id       # str
    attr_accessor :deck             # str
    attr_accessor :footer           # str
    attr_accessor :live             # bool
    attr_accessor :slug
  
    #the default transcript to show in the view.
    attr_accessor :default
  
    attr_reader   :transcript
  
    # A new tube is built from an already parsed yaml file. 
    def initialize(hash)
      @slug             = hash['slug']
      @title            = hash['title']
      @youtube_id       = hash['youtube_id']
      @deck             = hash['deck']
      @footer           = hash['footer']
      @live             = hash['live']
      @default          = hash['default'] #fix this
      @transcript       = Transcript.find(@youtube_id)
    end
  
    # Returns true if the Tube is live   
    def live?
      @live
    end
  
  
    # Builds and returns json from the transcript. 
    def json
      @transcript.to_json
    end
  
  
    # Because the YouTube javascript api relies on the video to be fully loaded  
    # and playing before it reports the duration of the video, Tubes must ask 
    # Google what the duration actually is using the YouTube feed api. Which  
    # presents a bit of a problem because private videos don't have feeds, nor
    # does there seem to be a way to associate a developer with a particular  
    # account. 
    #
    # If it's the case that we can't get the duration --  because a video is  
    # private on YouTube -- we return a string containing an arbitrarily large 
    # number of seconds in place of the actual figure.
    def duration
      begin
        Nokogiri::XML(open(YT_FEED_URL + youtube_id)).xpath('//yt:duration').first.attribute('seconds')
      rescue OpenURI::HTTPError
        '1799'
      end
    end
  
    class << self;
      # Returns all the transcripts that are currently live. Fails silently on
      # parsing errors.
      def all(dir="config/tube/")
        tubes=[] 
        Dir.glob("#{dir}*.{yaml,yml}").each { |file|
          begin
            t = Tube.new(file) 
            tubes << t if t.live?
          rescue ArgumentError => boom
            RAILS_DEFAULT_LOGGER.error("Error parsing configuration file. #{file}" + boom)
          rescue Exception => boom
            RAILS_DEFAULT_LOGGER.error("Error parsing configuration file. #{file}" + boom)
          end
        }
        tubes
      end
    
      #Grabs a particular Tube from a yaml path.
      def find(yaml)
        hash = YAML::load_file(yaml)
        yaml =~ /\/([^\/]*)\.(yaml|yml)/
        hash['slug'] = yaml
        instance = Tube.new(hash)
      end
    end
  end
end

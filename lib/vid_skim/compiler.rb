module VidSkim
  # The compiler handles both the compiling to json of an expanded directory, 
  # and the creation of expanded directories.
  class Compiler
    
    # Set up the erb templates for .entry, .div and .trans files.
    def initialize
      @transcript_t = ERB.new <<-EOS
<%= skim.title || "TITLE OF VIDEO" %>
<%= skim.youtube_id || "YOUTUBE_ID" %>
<%= skim.duration || "DURATION IN SECONDS" %>
<%= skim.default || "DEFAULT TAB" %>
      EOS
      @division_t = ERB.new <<-EOS
<%= division.name || "DIVISION ID" %>
<%= division.color || "COLOR IN #XXXXXX FORMAT" %>
<%= division.hover || "HOVER COLOR IN #XXXXXX FORMAT" %>
      EOS
      @entry_t = ERB.new <<-EOS
<%= division.name %>
<%= entry.title || "TITLE HERE" %>
<%= entry.range.collect.to_json || "['00:00:00', '00:00:00']" %>
<%= entry.transcript || "<p>HTML HERE (CAN BE MULTIPLE LINES)</p>" %>
      EOS
    end
    
    # Create an expanded directory from a VidSkim::Transcript
    def explode(skim)
      
      file_tree = {}
      working_dir = Inflector.parameterize(skim.title)
      file_tree[working_dir] = 
                        [["/#{working_dir}.trans", @transcript_t.result(binding)]]
      skim.divisions.each do |title, division|
        file_tree[working_dir] << [
            "/#{division.name}.div",
            @division_t.result(binding)
          ]
        
        division.entries.each_with_index do |entry, i|
          file_tree[working_dir] << [
            "/#{division.name}-#{i}.entry",
            @entry_t.result(binding)
          ]
        
        end
      end
      Files.create_tree(file_tree)
      
    end
    
    # Create a VidSkim::Transcript and compile it to json from an expanded
    # directory
    def compile
      Dir[VidSkim.build_path + "**"].each do |dir|
        next unless File.directory?(dir)
        @skim = VidSkim::Transcript.new({})
        Dir["#{dir}/*.{trans,div,entry}"].each do |path|
          path =~ /.*\.(trans|div|entry)/
          send("compile_#{$1}", File.open(path).read.split("\n"))
        end
        Files.create_file(VidSkim.build_path + Inflector.parameterize(@skim.title) + ".json", @skim.to_json)
      end
      
    
    rescue NameError => boom
        message = "One of your build files failed, are you sure everything's in the right order and the right format?\n\nThis might help:\n#{boom.message}"
      raise NameError.new(message, boom.name)
    end
    
    private
     
    # Compile a trans file
    def compile_trans(arr)
      assign(@skim, [:title=, :youtube_id=, :duration=, :default=], arr)
      @skim.duration = @skim.duration.to_i || 0
    end
    
    # Compile a division file
    def compile_div(arr)
      @skim.divisions[arr[0]] = Transcript::Division.new("")
      name = arr.shift
      @skim.divisions[name].name = name
      assign(@skim.divisions[name], [:color=, :hover=], arr)     
    end
    
    # Compile an entry file
    def compile_entry(arr)
      entry = Transcript::Entry.new()
      division_name = arr.shift
      assign(entry, [:title=], arr)
      entry.range = JSON.parse(arr.shift)
      entry.transcript = arr.join      
      @skim.divisions[division_name].entries << entry
    end
    
    # Assign each attribute to the right place in +@skim+
    def assign(obj, dest, values)
      dest.each do |attribute|
        obj.send(attribute, values.shift)
      end
    end
     
  end
  
end
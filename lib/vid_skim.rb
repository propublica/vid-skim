$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
gem 'nokogiri'
gem 'json'

autoload :JSON,         'json'
autoload :ERB,          'erb'
autoload :FileUtils,    'fileutils'
autoload :Set,          'set'
autoload :OptionParser, 'optparse'


module VidSkim
  autoload :Command, 'vid_skim/command'
  autoload :Transcript, "vid_skim/transcript"
  autoload :Inflector, "vid_skim/inflector"
  autoload :Compiler, "vid_skim/compiler"
  autoload :Parser, "vid_skim/parser"
  autoload :Files, "vid_skim/files"
  
  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
  
  
  class << self
    attr_reader :working_path, :build_path, :output_path
    
    
    # Set the paths for each of the directories VidSkim works with.
    def configure(working_path)
      @working_path = working_path
      @build_path = working_path + '/videos/'
      @output_path = working_path + '/html/'
    end
    
    # Borrowed from Jeremy Ashkenas's wonderful cloud-crowd gem.
    # Build a list of parsers from both VidSkim's defaults and
    # those installed in the working directory.
    def parsers
      return @parsers if @parsers
      @parsers = {}
      installed = Dir["#{@working_path}/parsers/*.rb"]
      default   = Dir["#{ROOT}/parsers/*.rb"]
      
      (installed + default).each do |path|
        name = File.basename(path, File.extname(path))
        require path
        @parsers[name] = Module.const_get(Inflector.camelize(name))
      end
      @parsers
    rescue NameError => e
      adjusted_message = "One of your parsers failed to load. Please ensure that the name of your parser class can be deduced from the name of the file. ex: 'json_parser.rb' => 'JsonParser'\n#{e.message}" 
      raise NameError.new(adjusted_message, e.name)
    end
  end
end

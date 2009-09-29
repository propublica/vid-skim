$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'open-uri'
require 'rubygems'
gem 'nokogiri'
gem 'json'

autoload :YAML,         'yaml'
autoload :Nokogiri,     'nokogiri'
autoload :JSON,         'json'
autoload :ERB,          'erb'
autoload :FileUtils,    'fileutils'
autoload :Set,          'set'
autoload :OptionParser, 'optparse'


module VidSkim
  autoload :Command, 'vid_skim/command'
  autoload :Transcript, "vid_skim/transcript"
  autoload :Inflector, "vid_skim/inflector"
  autoload :Files, "vid_skim/files"

  
  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
  
  class << self
    def configure(working_path)
      @working_path = File.expand_path(File.dirname(working_path))
    end
    
  end
end

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'open-uri'
require 'rubygems'
gem 'nokogiri'
gem 'json'

autoload :YAML,       'yaml'
autoload :Nokogiri,   'nokogiri'
autoload :JSON,       'json'
autoload :ERB,        'erb'
autoload :FileUtils,  'fileutils'

module VidSkim
  autoload :Transcript "vid_skim/transcript"
  autoload :Tube, "vid_skim/tube"
  
  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
end

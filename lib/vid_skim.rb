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
autoload :Set,        'set'

module VidSkim
  autoload :Command, 'vid_skim/command'
  autoload :Transcript, "vid_skim/transcript"
  autoload :Inflector, "vid_skim/inflector"
  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
end

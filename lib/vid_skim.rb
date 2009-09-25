$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'open-uri'
require 'rubygems'
gem 'nokogiri'
gem 'json'

autoload :YAML, 'yaml'
autoload :Nokogiri, 'nokogiri'
autoload :JSON, 'json'
autoload :ERB, 'erb'

module VidSkim
  autoload :Transcript "vid_skim/transcript"
  autoload :Tube, "vid_skim/tube"
end

ENV["VID_SKIM_ENV"] ||= 'test'
require 'spec/autorun'


require "#{File.dirname(__FILE__)}/../lib/vid_skim"

include VidSkim

Spec::Runner.configure do |config|
end

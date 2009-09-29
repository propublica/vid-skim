require 'rubygems'
gem "vid-skim"
#require "edl"

class JsonParser < VidSkim::Parser
  
  def load(file)
    @transcript = VidSkim::Transcript.find(file)
  end
  
  
end
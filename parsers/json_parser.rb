require 'rubygems'
gem "vid-skim"
gem "json"

class JsonParser < VidSkim::Parser
  # Build an expanded collection of files from a VidSkim JSON file.
  def load(file)
    @transcript = VidSkim::Transcript.find(file)
  end
end
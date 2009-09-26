require 'json'
require 'rubygems'
gem 'vid-skim'

class JsonParser < VidSkim::Parser

  def load(file)
    @transcript = VidSkim::Transcript.find(file)
  end

end
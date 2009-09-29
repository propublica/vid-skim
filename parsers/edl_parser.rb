require 'rubygems'
require 'json'
gem 'vid-skim'
gem 'edl'

class EdlParser < VidSkim::Parser
  
  def load(file)
    list = EDL::Parser.new(fps=30).parse(File.open(file))
    @transcript = VidSkim::Transcript.new({})
    @transcript.title = File.basename(file)
    @transcript.divisions["Transcript"] = VidSkim::Transcript::Division.new("Transcript")
    
    list.each do |evt|
      entry = VidSkim::Transcript::Entry.new
      entry.title = evt.clip_name
      clip_start = evt.rec_start_tc
      clip_end = evt.rec_end_tc
      entry.range = ["#{clip_start.hours}:#{clip_start.minutes}:#{clip_start.seconds}", 
                      "#{clip_end.hours}:#{clip_end.minutes}:#{clip_end.seconds}"]
      @transcript.divisions["Transcript"].entries << entry
    end 
  end
  
  
end
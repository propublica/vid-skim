module VidSkim
  # Each parser you define in your parser directory needs to set the
  # +@transcript+ attribute with a VidSkim::Transcript instance. You can see a
  # fully fleshed out example in parsers/edl_parser.rb.
  #
  # A key point to remember: every unset attribute of the @transcript will be 
  # replaced with a sane default when the Compiler expands @transcript.
  class Parser
    attr_accessor :transcript
    # The load method takes a name of a file and must return a 
    # VidSkim::Transcript object
    def load(file)
      raise NotImplementedError, "Parsers must define a load method that takes the name of the file to read from."
    end

    def parse
      Compiler.new.explode(@transcript)
    end

  end
end
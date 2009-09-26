module VidSkim

  class Parser
    attr_accessor :transcript 
    
    def load(file)
      raise NotImplementedError, "Parsers must define a load method that takes the name of the file to read from."
    end

    def save!(dest)
      #tk
    end
    
  end
  
end
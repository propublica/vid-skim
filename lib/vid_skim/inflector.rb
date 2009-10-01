module VidSkim
  # Various string utilities.
  class Inflector
    # From rails
    # Return the camelized form of the word. Useful for loading parsers.
    def self.camelize(word)
      word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    
    # Remove non printing characters and replace them with the seperator +sep+
    def self.parameterize(string, sep = '-')
      string.gsub(/[^a-z0-9\-_\+]+/i, sep).downcase
    end
  end
  
end

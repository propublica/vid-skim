module VidSkim
  
  class Inflector
    # From rails
    def self.camelize(word)
      word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    
    def self.parameterize(string, sep = '-')
      string.gsub(/[^a-z0-9\-_\+]+/i, sep).downcase
    end
  end
  
end

module VidSkim
  
  class Inflector
    # From rails
    def self.parameterize(string, sep = '-')
      string.gsub(/[^a-z0-9\-_\+]+/i, sep).downcase
    end
  end
  
end

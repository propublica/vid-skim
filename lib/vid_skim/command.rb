
module VidSkim
  
  class Command
    
    def initialize
      @command = ARGV.shift
      @directory = ARGV.shift || '.'
    end
    
    def run
      case @command
        when 'install' then run_install
        when 'build' then run_build
      end
    end
    
    def run_install
      
    end
    
    def run_build
      
    end
  end
  
end

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
      Dir.glob(@directory + "videos/*.json").each do |f|
        template  = ERB.new << File.open(VidSkim::ROOT +
                              'views/template.html.erb', 'r').read
        @tube = @tube.new(JSON.parse(open(f, 'r'))
        str = template.result(binding)
        File.new(@directory + "/html/#{@tube.slug}.html", "w").write(str)
      end
    end
  end
  
end
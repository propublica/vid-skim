module VidSkim

  # Command-line `vidskim` client. Handles commands for initial installation
  # and building out the exported HTML files.
  class Command
    
    # Command-line banner for the usage message.
    BANNER = <<-EOS
Usage: vidskim COMMAND path/to/directory

Commands:
  install     Install the VidSkim configuration to the specified directory
  build       Build all videos in a VidSkim directory into HTML pages
    EOS
    
    # Creating a VidSkim::Command parses all command-line arguments and options.
    def initialize
      @command = ARGV.shift
      @directory = ARGV.shift || '.'
    end
    
    def run
      case @command
        when 'install' then run_install
        when 'build'   then run_build
        else                usage
      end
    end
    
    # Install the example VidSkim folder to a location of your choosing.
    def run_install
      FileUtils.mkdir_p(@directory) unless File.exists?(@directory)
      install_dir "#{VidSkim::ROOT}/template/html",   "#{@directory}/html"
      install_dir "#{VidSkim::ROOT}/template/videos", "#{@directory}/videos"
    end
    
    #Build the html files in the videos directory
    def run_build
      Dir.glob(@directory + "/videos/*.json").each do |f|
        template = ERB.new(File.open(VidSkim::ROOT +
                                '/views/template.html.erb', 'r').read)
        @transcript = Transcript.find(f)
        str = template.result(binding)
        File.new(@directory + "/html/#{@transcript.slug}.html", "w").write(str)
      end
    end
    
    # Print out `vidskim` usage.
    def usage
      puts "\n#{BANNER}\n"
    end
    
    
    private
    
    # Install a file and log the installation. Allow opportunities to back out
    # of overwriting existing files.
    def install_dir(source, dest)
      if File.exists?(dest)
        print "#{dest} already exists. Overwrite it? (yes/no) "
        return unless ['y', 'yes', 'ok'].include? gets.chomp.downcase
      end
      FileUtils.cp_r(source, dest)
      puts "installed #{dest}" unless ENV["VID_SKIM_ENV"] == 'test'
    end
      
  end
end
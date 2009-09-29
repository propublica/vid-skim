module VidSkim

  # Command-line `vidskim` client. Handles commands for initial installation
  # and building out the exported HTML files.
  class Command
    
    # Command-line banner for the usage message.
    BANNER = <<-EOS
Usage: vidskim COMMAND path/to/directory OPTIONS

Commands:
  install     Install the VidSkim configuration to the specified directory
  build       Build all videos in a VidSkim directory into HTML pages
  
  Options:
    EOS
    
    # Creating a VidSkim::Command parses all command-line arguments and
    # options.
    def initialize
      @options = {}   
      parse_options      
      @command = ARGV.shift
      @directory = ARGV.shift || '.'
      case @command
        when 'install' then run_install
        when 'build'   then run_build

        else                usage
      end
    end
    
    def parse_options
      @option_parser = OptionParser.new do |opts|
        opts.on('-p', '--parser NAME', 'name of parser') do |parser_name|
          @options[:parser_name] = parser_name
        end
        
        opts.on('-f', '--file FILE', 'input file to parse') do |parser_file|
          @options[:parser_file] = parser_file
        end
        
        opts.on('--force', 'Force overwriting of files') do
          @options[:force] = true
        end
        
        opts.on_tail('-v', '--version', 'show version') do
          puts "VidSkim version #{VERSION}"
          exit
        end
      end
      @option_parser.parse!(ARGV)
    end
    
    # Install the example VidSkim folder to a location of your choosing.
    def run_install
      FileUtils.mkdir_p(@directory) unless File.exists?(@directory)
      install_dir "#{VidSkim::ROOT}/template/html",   "#{@directory}/html"
      install_dir "#{VidSkim::ROOT}/template/videos", "#{@directory}/videos"
    end
    
    # Build the html files from the json in the videos directory.
    def run_build
      Dir.glob(@directory + "/videos/*.json").each do |f|
        template = ERB.new(File.open(VidSkim::ROOT +
                                '/views/template.html.erb', 'r').read)
        @transcript = Transcript.find(f)
        str = template.result(binding)
        create_file(@directory + "/html/#{@transcript.slug}.html", str)
      end
    end
    

    
    # Print out `vidskim` usage.
    def usage
      puts "\n#{BANNER}\n"
    end
    
    
    private
    
    # Check if a file exists and asks the user if they want to overwrite it         
    # returns false if they say no.
    def check_file(dest)
      if File.exists?(dest) && !@options[:force]
        print "#{dest} already exists. Overwrite it? (yes/no) "
        return false unless ['y', 'yes', 'ok'].include? gets.chomp.downcase
      end
      true
    end
    
    # Install a file and log the installation. Allow opportunities to back out
    # of overwriting existing files.
    def install_dir(source, dest)
      return unless check_file(dest)
      FileUtils.cp_r(source, dest)
      puts "installed #{dest}" unless ENV["VID_SKIM_ENV"] == 'test'
    end
    
    # Create a file and underlying directories if needed and log the creation.
    def create_file(dest, str)
      return unless check_file(dest)
      File.new(dest, "w").write(str)
      puts "created #{dest}" unless ENV["VID_SKIM_ENV"] == 'test'
    end
      
  end
end
module VidSkim

  # Command-line `vidskim` client. Handles commands for initial installation
  # and building out the exported HTML files.
  class Command
    
    # Command-line banner for the usage message.
    BANNER = <<-EOS
Usage: vidskim COMMAND path/to/directory <parser_name>

Commands:
  install     Install the VidSkim configuration to the specified directory
  build       Build all videos in a VidSkim directory into HTML pages
  parse       Parse a file using a parser into the VidSkim directory
  compile     Compiles and builds each json file from an expanded format
    EOS
    
    # Creating a VidSkim::Command parses all command-line arguments and
    # options.
    def initialize
      @command = ARGV.shift
      @directory = ARGV.shift || '.'
    end
    
    def run
      case @command
        when 'install' then run_install
        when 'build'   then run_build
        when 'parse'   then run_parse
        when 'compile' then run_compile
        else                usage
      end
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
    
    # Runs a parser to build the files in the videos directory. 
    def run_parse
      parser = ARGV.shift
      file = ARGV.shift
      require "#{parser}"
      eval("#{parser}.new.load(#{file}).save(#{@directory})")
    end
    
    # Runs the compiler to compile and build the files in each directory 
    # created by a parser or by hand
    def run_compile
      Dir.glob(@directory + "/**/").each do |d|
        compiler = VidSkim::Compiler.new(d)
        creat_file(@directory + compiler.dir, compiler.compile)
      end
      run_build
    end
    
    # Print out `vidskim` usage.
    def usage
      puts "\n#{BANNER}\n"
    end
    
    
    private
    
    # Check if a file exists and asks the user if they want to overwrite it         
    # returns false if they say no.
    def check_file(dest)
      if File.exists?(dest)
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
    
    # Create a file and log the creation.
    def create_file(dest, str)
      return unless check_file(dest)
      File.new(dest, "w").write(str)
      puts "created #{dest}" unless ENV["VID_SKIM_ENV"] == 'test'
    end
      
  end
end
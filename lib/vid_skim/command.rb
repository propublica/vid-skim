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
  parse       Parse a file using a parser into the VidSkim directory
  compile     Compiles and builds each json file from an expanded format
  
  parse path/to/directory -f <input_file> -p <parser_name>  
      Parse an <input_file> using the parser in <parser_name>
      
      Example: vid-skim parse ./vids -f edit.edl -p edl_parser will parse an    
               EDL file using the edl_parser
               
  Options:
    EOS
    
    # Creating a VidSkim::Command parses all command-line arguments and
    # options.
    def initialize
      @options = {}   
      parse_options      
      @command = ARGV.shift
      @directory = ARGV.shift || '.'
      configure
      case @command
        when 'install' then run_install
        when 'build'   then run_build
        when 'parse'   then run_parse
        when 'compile' then run_compile
        else                usage
      end
    end
    
   
    
    def parse_options
      @option_parser = OptionParser.new do |opts|
        opts.on('-p', '--parser NAME', 'Name of parser') do |parser_name|
          @options[:parser_name] = parser_name
        end
        
        opts.on('-f', '--file FILE', 'Input file to parse') do |parser_file|
          @options[:parser_file] = parser_file
        end
        
        opts.on('--force', 'Force overwriting of files') do
          Files.force = true
        end
        
        opts.on_tail('-v', '--version', 'Show version') do
          puts "VidSkim version #{VERSION}"
          exit
        end
      end
      @option_parser.banner = BANNER
      @option_parser.parse!(ARGV)
    end
    
    # Install the example VidSkim folder to a location of your choosing.
    def run_install
      FileUtils.mkdir_p(VidSkim.working_path) unless File.exists?(VidSkim.working_path)
      Files.install_dir "#{VidSkim::ROOT}/template/html",   "#{VidSkim.output_path}"
      Files.install_dir "#{VidSkim::ROOT}/template/videos", "#{VidSkim.build_path}"
    end
    
    # Build the html files from the json in the videos directory.
    def run_build
      Files.walk_tree(".json").each do |f|
        template = ERB.new(File.open(VidSkim::ROOT +
                                '/views/template.html.erb', 'r').read)
        @transcript = Transcript.find(f)
        str = template.result(binding)
        Files.create_file(VidSkim.output_path + "#{@transcript.slug}.html", str)
      end
    end
    
    # Runs a parser to build the files in the videos directory.  Allow an escape hatch if the   
    # directory exists
    def run_parse
      raise Error.new("To run a parser you must use both the -p and -f flags.") if
              !@options[:parser_name] && !@options[:parser_file]
      parser = VidSkim.parsers[@options[:parser_name]].new
      parser.load(@options[:parser_file])
      parser.parse
    end
    
    # Runs the compiler to compile and build the files in each directory 
    # created by a parser or by hand.
    def run_compile
      compiler = VidSkim::Compiler.new
      compiler.compile
    end
    
    # Print out `vidskim` usage.
    def usage
      puts "\n#{@option_parser}\n"
    end
    
    
    private
    # Make sure that everyone knows where to put any files they generate
    def configure
      VidSkim.configure(@directory)
    end
    
      
  end
end
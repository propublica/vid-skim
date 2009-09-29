module VidSkim

  class Files
    
    class << self
      attr_accessor :force
    end
    
    def self.create_tree(tree)
      tree.each_pair do |dir, files|
        dir = "/videos/" + dir
        path = File.join(VidSkim.working_path, dir)
        FileUtils.mkdir_p path unless File.exists? path
        files.each do |filename, contents|
          if filename.respond_to? :each_pair 
            create_tree filename, path
          else
            self.create_file(path + filename, contents)
          end
        end
      end
    end
     
  
    # Check if a file exists and asks the user if they want to overwrite it         
    # returns false if they say no.
    def self.check_file(dest)
      if File.exists?(dest) && !@force && ENV["VID_SKIM_ENV"] != 'test'
        print "#{dest} already exists. Overwrite it? (yes/no) "
        return false unless ['y', 'yes', 'ok'].include? gets.chomp.downcase
      end
      true
    end

    # Install a file and log the installation. Allow opportunities to back out
    # of overwriting existing files.
    def self.install_dir(source, dest)
      return unless check_file(dest)
      FileUtils.cp_r(source, dest)
      puts "installed #{dest}" unless ENV["VID_SKIM_ENV"] == 'test'
    end

    # Create a file and underlying directories if needed and log the creation.
    def self.create_file(dest, str)
      return unless check_file(dest)
      File.new(dest, "w").write(str)
      puts "created #{dest}" unless ENV["VID_SKIM_ENV"] == 'test'
    end
    
  end
  
end
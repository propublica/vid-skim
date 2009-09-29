require 'spec/spec_helper'

describe Command do

  it "be able to install Video Skimmer to a location of your choosing" do
    dir = 'tmp/install_dir'
    ARGV.replace ['install', dir]
    Command.new
    File.exists?(dir).should == true
    File.directory?(dir).should == true
    File.directory?("#{dir}/videos").should == true
    File.directory?("#{dir}/html").should == true
    FileUtils.rm_r(dir)
  end
  
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'yaml'
describe Tube do
  before(:each) do
    @valid_attributes = {
      :hash => YAML::load_file('spec/fixtures/tubes.yml')
    }
  end

  it "should create a new instance given valid attributes" do
    Tube.new(@valid_attributes)
  end
end

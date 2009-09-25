require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'json'

describe Transcript do
  before(:each) do
    @data = JSON.parse(File.read("spec/fixtures/transcript.json"))
    @t = Transcript.new(@data)
  end

  it "should create a new instance given valid attributes" do
    Transcript.new(@data)
  end
  
  it "should have divisions" do
    @t.divisions.should_not be_nil
  end
  
  it "should have entries" do
    @t.divisions.each_pair do |key, d|
      d.entries.should_not be_empty
    end
  end
  
  it "should parse the range for each entry" do
    @t.divisions.each_pair do |key, d| 
      d.entries.each do |e|      
        e.range.low.should_not be_nil
        e.range.high.should_not be_nil 
      end
    end
  end
  
  it "should return json" do
    @t.to_json.should_not be_nil
  end
  
  it "should return the same hash as was put in" do
    transcript_entry_count = @t.to_hash['Transcript']['entries'].length
    data_entry_count = @data["divisions"]["Transcript"]["entries"].length
    transcript_entry_count.should == data_entry_count
  end
  
  it "should be reversible" do
    JSON.parse(@t.to_hash.to_json).should == @t.to_hash
  end
  
end

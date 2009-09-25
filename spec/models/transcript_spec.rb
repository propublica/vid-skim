require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'json'
require 'kwalify'


describe Transcript do
  before(:each) do
    @json = File.open("spec/fixtures/transcripts.json").read
    @valid_attributes = {
      :id => 'eerhqc4r19E',
      :hash => JSON.parse(@json)
      
    }
    @t = Transcript.new(@valid_attributes[:hash], @valid_attributes[:id])
    schema = Kwalify::Yaml.load(File.open("config/tube/transcripts/schema.json").read)
    validator = Kwalify::Validator.new(schema)
    @parser = Kwalify::Yaml::Parser.new(validator)
  end

  it "should create a new instance given valid attributes" do
    Transcript.new(@valid_attributes[:hash], @valid_attributes[:id])
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
    @t.to_hash.should == @valid_attributes[:hash]
  end
  
  it "should be reversible" do
    JSON.parse(@t.to_hash.to_json).should == @t.to_hash
  end
  
end

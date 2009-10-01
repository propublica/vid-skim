require "rubygems"
require "selenium"
require "selenium/rspec/spec_helper"

describe "UI" do
  attr_reader :selenium_driver
  alias :page :selenium_driver

  before :all  do
    
    @selenium_driver = Selenium::Client::Driver.new \
        :host => "localhost", 
        :port => 4444, 
        :browser => "*firefox", 
        :url => "http://0.0.0.0:3000/", 
        :timeout_in_seconds => 60
  end

  before :each do
    page.start_new_browser_session
    page.execution_delay=1000
    page.open "/ron_boline_interview.html"
    page.wait_for_element('ytplayer')
    page.wait_for_condition( "window.trans.initted == true")
  end


  it "should change links when asked nicely" do 
    page.click "link=Weapons Cost"
    page.text?("Once the amount that seemed to be prudent").should be_true
  end
  
  it "should change views when asked nicely" do
    page.click "link=Annotations", :wait_for => :text, :text => "Annotations"
    page.text?("What kinds of things did Triple Canopy do to get the equipment that it needed?").should be_true
  end
  

  append_after(:each) do    
    @selenium_driver.close_current_browser_session
  end
  
end

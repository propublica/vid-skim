require 'spec/spec_helper'

describe Inflector do

  it "should properly parameterize strings" do
    Inflector.parameterize("A Hard Day's Night").should == 'a-hard-day-s-night'
    Inflector.parameterize("Iran Is Warned Over Nuclear ‘Deception’", '_').should == 'iran_is_warned_over_nuclear_deception_'
    Inflector.parameterize("Thousands Hold Peaceful March at G-20 Summit").should == 'thousands-hold-peaceful-march-at-g-20-summit'
  end
  
end

require 'lib/pagerduty'

describe Pagerduty do 
  it "should raise a PagerdutyException if the api response wasn't successfull" do
    pagerduty = Pagerduty.new("test", "test")
    pagerduty.stub(:api_call).and_return({'status' => 'BORK!'})
    lambda { pagerduty.trigger("BORK!") }.should raise_error(PagerdutyException)
  end
end
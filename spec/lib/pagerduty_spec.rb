require 'lib/pagerduty'

describe Pagerduty do 
  it "should raise a PagerdutyException if the api response wasn't successfull" do
    pagerduty = Pagerduty.new("test", "test")
    pagerduty.stub(:api_call).and_return({'status' => 'BORK!'})
    lambda { pagerduty.trigger("BORK!") }.should raise_error(PagerdutyException)
  end

  it "should propagate details to the pagerduty api" do
    pagerduty = Pagerduty.new("test", "test")
    response = { 'status' => 'success', 'incident_key' => 'key'}
    description = "description"
    details = { 'my' => 'details' }
    pagerduty.should_receive(:api_call).with('trigger', description, details).and_return(response)
    pagerduty.trigger(description, details)
  end
end
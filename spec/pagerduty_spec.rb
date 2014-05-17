# encoding: utf-8
require "spec_helper"

describe PagerdutyException do
  Given(:pagerduty_instance) { mock }
  Given(:api_response) { mock }

  When(:pagerduty_exception) { PagerdutyException.new(pagerduty_instance, api_response) }

  Then { pagerduty_exception.pagerduty_instance == pagerduty_instance }
  Then { pagerduty_exception.api_response == api_response }
end

describe Pagerduty do

end

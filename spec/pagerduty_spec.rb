# encoding: utf-8
require "spec_helper"

describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(service_key) }
  Given(:service_key) { "a-test-service-key" }

  describe "#get_incident" do
    Given(:incident_key) { "a-test-incident-key" }

    When(:incident) { pagerduty.get_incident(incident_key) }

    Then { incident.must_be_kind_of PagerdutyIncident }
    Then { incident.service_key.must_equal service_key }
    Then { incident.incident_key.must_equal incident_key }
  end
end

describe PagerdutyException do
  Given(:pagerduty_instance) { mock }
  Given(:api_response) { mock }

  When(:pagerduty_exception) { PagerdutyException.new(pagerduty_instance, api_response) }

  Then { pagerduty_exception.pagerduty_instance == pagerduty_instance }
  Then { pagerduty_exception.api_response == api_response }
end

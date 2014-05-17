# encoding: utf-8
require "spec_helper"

describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(service_key) }
  Given(:service_key) { "a-test-service-key" }

  Given(:http) { stub_everything }
  Given { Net::HTTP.stubs(:new).returns(http) }

  describe "#trigger" do
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    context "PagerDuty successfully creates the incident" do
      Given { http.stubs(:request).returns(response_with_body(<<-JSON)) }
        {
          "status": "success",
          "incident_key": "My Incident Key",
          "message": "Event processed"
        }
      JSON

      When(:incident) { pagerduty.trigger(description, details) }

      Then { incident.must_be_kind_of PagerdutyIncident }
      Then { incident.service_key.must_equal service_key }
      Then { incident.incident_key.must_equal "My Incident Key" }
    end

    context "PagerDuty fails to create the incident" do
      Given { http.stubs(:request).returns(response_with_body(<<-JSON)) }
        {
          "status": "failure",
          "message": "Event not processed"
        }
      JSON

      When(:error) {
        begin
          pagerduty.trigger(description, details)
        rescue Exception => exception
          exception
        end
      }

      Then { error.must_be_kind_of PagerdutyException }
      Then { error.pagerduty_instance == pagerduty }
      Then { error.api_response == { "status" => "failure", "message" => "Event not processed" } }
    end

    context "PagerDuty responds with HTTP bad request" do
      Given { http.stubs(:request).returns(bad_request) }

      When(:error) {
        begin
          pagerduty.trigger(description, details)
        rescue Exception => exception
          exception
        end
      }

      Then { error.must_be_kind_of Net::HTTPServerException }
    end
  end

  describe "#get_incident" do
    Given(:incident_key) { "a-test-incident-key" }

    When(:incident) { pagerduty.get_incident(incident_key) }

    Then { incident.must_be_kind_of PagerdutyIncident }
    Then { incident.service_key.must_equal service_key }
    Then { incident.incident_key.must_equal incident_key }
  end

  def response_with_body(body)
    response = Net::HTTPSuccess.new 1.1, "200", "OK"
    response.stubs(:body).returns(body)
    response
  end

  def bad_request
    Net::HTTPBadRequest.new 1.1, "400", "Bad Request"
  end

end

describe PagerdutyException do
  Given(:pagerduty_instance) { mock }
  Given(:api_response) { mock }

  When(:pagerduty_exception) { PagerdutyException.new(pagerduty_instance, api_response) }

  Then { pagerduty_exception.pagerduty_instance == pagerduty_instance }
  Then { pagerduty_exception.api_response == api_response }
end

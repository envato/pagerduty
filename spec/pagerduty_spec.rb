# encoding: utf-8
require "spec_helper"

describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(service_key) }
  Given(:service_key) { "a-test-service-key" }

  Given(:http) { stub_everything }
  Given { Net::HTTP.stubs(:new).returns(http) }
  Given(:post) { stub_everything }
  Given { Net::HTTP::Post.stubs(:new).returns(post) }

  describe "#trigger" do
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    describe "provides the correct request" do
      context "PagerDuty successfully creates the incident" do
        Given { http.stubs(:request).returns(standard_response) }
        Given { post.expects(:body=).with '{"event_type":"trigger","service_key":"a-test-service-key","description":"a-test-description","details":{"key":"value"}}' }

        When(:incident) { pagerduty.trigger(description, details) }

        Then { incident } # calls expected methods
      end
    end

    describe "can handle responses" do

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

        When(:incident) { pagerduty.trigger(description, details) }

        Then { incident.must_raise PagerdutyException }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given { http.stubs(:request).returns(bad_request) }

        When(:incident) { pagerduty.trigger(description, details) }

        Then { incident.must_raise Net::HTTPServerException }
      end
    end
  end

  describe "#get_incident" do
    Given(:incident_key) { "a-test-incident-key" }

    When(:incident) { pagerduty.get_incident(incident_key) }

    Then { incident.must_be_kind_of PagerdutyIncident }
    Then { incident.service_key.must_equal service_key }
    Then { incident.incident_key.must_equal incident_key }
  end

  describe PagerdutyIncident do
    Given(:incident) { PagerdutyIncident.new(service_key, incident_key) }
    Given(:incident_key) { "a-test-incident-key" }
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    describe "#acknowledge" do

      describe "provides the correct request" do
        Given { http.stubs(:request).returns(standard_response) }
        Given { post.expects(:body=).with '{"event_type":"acknowledge","service_key":"a-test-service-key","description":"a-test-description","details":{"key":"value"},"incident_key":"a-test-incident-key"}' }

        When(:acknowledge) { incident.acknowledge(description, details) }

        Then { acknowledge } # calls expected methods
      end

      describe "can handle responses" do

        context "PagerDuty successfully creates the incident" do
          Given { http.stubs(:request).returns(response_with_body(<<-JSON)) }
            {
              "status": "success",
              "incident_key": "a-test-incident-key",
              "message": "Event processed"
            }
          JSON

          When(:acknowledge) { incident.acknowledge(description, details) }

          Then { acknowledge.must_equal incident}
        end

        context "PagerDuty fails to create the incident" do
          Given { http.stubs(:request).returns(response_with_body(<<-JSON)) }
            {
              "status": "failure",
              "message": "Event not processed"
            }
          JSON

          When(:acknowledge) { incident.acknowledge(description, details) }

          Then { acknowledge.must_raise PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given { http.stubs(:request).returns(bad_request) }

          When(:acknowledge) { incident.acknowledge(description, details) }

          Then { acknowledge.must_raise Net::HTTPServerException }
        end
      end
    end
  end

  def standard_response
    response_with_body '{ "status": "success", "incident_key": "My Incident Key" }'
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

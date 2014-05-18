# encoding: utf-8
require "spec_helper"

describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(service_key) }
  Given(:service_key) { "a-test-service-key" }

  Given(:http) { double.as_null_object }
  Given { Net::HTTP.stub(:new => http) }
  Given(:post) { double.as_null_object }
  Given { Net::HTTP::Post.stub(:new => post) }

  describe "#trigger" do
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    describe "provides the correct request" do
      Given { http.stub(:request => standard_response) }

      When(:incident) { pagerduty.trigger(description, details) }

      Then { expect(post).to have_received(:body=).with '{"event_type":"trigger","service_key":"a-test-service-key","description":"a-test-description","details":{"key":"value"}}' }
    end

    describe "can handle responses" do

      context "PagerDuty successfully creates the incident" do
        Given { http.stub(:request => response_with_body(<<-JSON)) }
          {
            "status": "success",
            "incident_key": "My Incident Key",
            "message": "Event processed"
          }
        JSON

        When(:incident) { pagerduty.trigger(description, details) }

        Then { expect(incident).to be_a PagerdutyIncident }
        Then { incident.service_key == service_key }
        Then { incident.incident_key == "My Incident Key" }
      end

      context "PagerDuty fails to create the incident" do
        Given { http.stub(:request => response_with_body(<<-JSON)) }
          {
            "status": "failure",
            "message": "Event not processed"
          }
        JSON

        When(:incident) { pagerduty.trigger(description, details) }

        Then { expect(incident).to have_raised PagerdutyException }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given { http.stub(:request => bad_request) }

        When(:incident) { pagerduty.trigger(description, details) }

        Then { expect(incident).to have_raised Net::HTTPServerException }
      end
    end
  end

  describe "#get_incident" do
    Given(:incident_key) { "a-test-incident-key" }

    When(:incident) { pagerduty.get_incident(incident_key) }

    Then { expect(incident).to be_a PagerdutyIncident }
    Then { expect(incident.service_key).to eq service_key }
    Then { expect(incident.incident_key).to eq incident_key }
  end

  describe PagerdutyIncident do
    Given(:incident) { PagerdutyIncident.new(service_key, incident_key) }
    Given(:incident_key) { "a-test-incident-key" }
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    describe "#acknowledge" do

      describe "provides the correct request" do
        Given { http.stub(:request => standard_response) }

        When(:acknowledge) { incident.acknowledge(description, details) }

        Then { expect(post).to have_received(:body=).with '{"event_type":"acknowledge","service_key":"a-test-service-key","description":"a-test-description","details":{"key":"value"},"incident_key":"a-test-incident-key"}' }
      end

      describe "can handle responses" do

        context "PagerDuty successfully creates the incident" do
          Given { http.stub(:request => response_with_body(<<-JSON)) }
            {
              "status": "success",
              "incident_key": "a-test-incident-key",
              "message": "Event processed"
            }
          JSON

          When(:acknowledge) { incident.acknowledge(description, details) }

          Then { expect(acknowledge).to be incident}
        end

        context "PagerDuty fails to create the incident" do
          Given { http.stub(:request => response_with_body(<<-JSON)) }
            {
              "status": "failure",
              "message": "Event not processed"
            }
          JSON

          When(:acknowledge) { incident.acknowledge(description, details) }

          Then { expect(acknowledge).to have_failed PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given { http.stub(:request => bad_request) }

          When(:acknowledge) { incident.acknowledge(description, details) }

          Then { expect(acknowledge).to have_failed Net::HTTPServerException }
        end
      end
    end

    describe "#resolve" do

      describe "provides the correct request" do
        Given { http.stub(:request => standard_response) }

        When(:resolve) { incident.resolve(description, details) }

        Given { expect(post).to have_received(:body=).with '{"event_type":"resolve","service_key":"a-test-service-key","description":"a-test-description","details":{"key":"value"},"incident_key":"a-test-incident-key"}' }
      end

      describe "can handle responses" do

        context "PagerDuty successfully creates the incident" do
          Given { http.stub(:request => response_with_body(<<-JSON)) }
            {
              "status": "success",
              "incident_key": "a-test-incident-key",
              "message": "Event processed"
            }
          JSON

          When(:resolve) { incident.resolve(description, details) }

          Then { expect(resolve).to be incident}
        end

        context "PagerDuty fails to create the incident" do
          Given { http.stub(:request => response_with_body(<<-JSON)) }
            {
              "status": "failure",
              "message": "Event not processed"
            }
          JSON

          When(:resolve) { incident.resolve(description, details) }

          Then { expect(resolve).to have_failed PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given { http.stub(:request => bad_request) }

          When(:resolve) { incident.resolve(description, details) }

          Then { expect(resolve).to have_failed Net::HTTPServerException }
        end
      end
    end
  end

  def standard_response
    response_with_body '{ "status": "success", "incident_key": "My Incident Key" }'
  end

  def response_with_body(body)
    response = Net::HTTPSuccess.new 1.1, "200", "OK"
    response.stub(:body => body)
    response
  end

  def bad_request
    Net::HTTPBadRequest.new 1.1, "400", "Bad Request"
  end

  describe PagerdutyException do
    Given(:pagerduty_instance) { double }
    Given(:api_response) { double }

    When(:pagerduty_exception) { PagerdutyException.new(pagerduty_instance, api_response) }

    Then { pagerduty_exception.pagerduty_instance == pagerduty_instance }
    Then { pagerduty_exception.api_response == api_response }
  end
end

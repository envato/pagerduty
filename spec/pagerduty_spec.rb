# encoding: utf-8
require "spec_helper"

describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(service_key) }
  Given(:service_key) { "a-test-service-key" }

  Given(:transport) { double.as_null_object }
  Given { Pagerduty.stub(:transport => transport) }

  describe "#trigger" do
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    describe "provides the correct request" do
      Given { transport.stub(:send => standard_response) }
      When(:incident) { pagerduty.trigger(description, details) }
      Then {
        expect(transport).to have_received(:send).with(
          event_type: "trigger",
          service_key: "a-test-service-key",
          description: "a-test-description",
          details: { key: "value" }
        )
      }
    end

    describe "handles all responses" do

      context "PagerDuty successfully creates the incident" do
        Given {
          transport.stub(:send => {
            "status" => "success",
            "incident_key" => "My Incident Key",
            "message" => "Event processed",
          })
        }
        When(:incident) { pagerduty.trigger(description, details) }
        Then { expect(incident).to be_a PagerdutyIncident }
        Then { incident.service_key == service_key }
        Then { incident.incident_key == "My Incident Key" }
      end

      context "PagerDuty fails to create the incident" do
        Given {
          transport.stub(:send => {
            "status" => "failure",
            "message" => "Event not processed",
          })
        }
        When(:incident) { pagerduty.trigger(description, details) }
        Then { expect(incident).to have_raised PagerdutyException }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given { transport.stub(:send).and_raise(Net::HTTPServerException.new(nil, nil)) }
        When(:incident) { pagerduty.trigger(description, details) }
        Then { expect(incident).to have_raised Net::HTTPServerException }
      end
    end
  end

  describe "#get_incident" do
    Given(:incident_key) { "a-test-incident-key" }
    When(:incident) { pagerduty.get_incident(incident_key) }
    Then { expect(incident).to be_a PagerdutyIncident }
    Then { incident.service_key == service_key }
    Then { incident.incident_key == incident_key }
  end

  describe PagerdutyIncident do
    Given(:incident) { PagerdutyIncident.new(service_key, incident_key) }
    Given(:incident_key) { "a-test-incident-key" }
    Given(:description) { "a-test-description" }
    Given(:details) { { key: "value" } }

    describe "#acknowledge" do

      describe "provides the correct request" do
        Given { transport.stub(:send => standard_response) }
        When(:acknowledge) { incident.acknowledge(description, details) }
        Then {
          expect(transport).to have_received(:send).with(
            event_type: "acknowledge",
            service_key: "a-test-service-key",
            description: "a-test-description",
            details: { key: "value" },
            incident_key: "a-test-incident-key",
          )
        }
      end

      describe "handles all responses" do

        context "PagerDuty successfully acknowledges the incident" do
          Given {
            transport.stub(:send => {
              "status" => "success",
              "incident_key" => "a-test-incident-key",
              "message" => "Event acknowledged",
            })
          }
          When(:acknowledge) { incident.acknowledge(description, details) }
          Then { expect(acknowledge).to be incident}
        end

        context "PagerDuty fails to acknowledge the incident" do
          Given {
            transport.stub(:send => {
              "status" => "failure",
              "incident_key" => "a-test-incident-key",
              "message" => "Event not acknowledged",
            })
          }
          When(:acknowledge) { incident.acknowledge(description, details) }
          Then { expect(acknowledge).to have_failed PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given { transport.stub(:send).and_raise(Net::HTTPServerException.new(nil, nil)) }
          When(:acknowledge) { incident.acknowledge(description, details) }
          Then { expect(acknowledge).to have_failed Net::HTTPServerException }
        end
      end
    end

    describe "#resolve" do

      describe "provides the correct request" do
        Given { transport.stub(:send => standard_response) }
        When(:resolve) { incident.resolve(description, details) }
        Then {
          expect(transport).to have_received(:send).with(
            event_type: "resolve",
            service_key: "a-test-service-key",
            description: "a-test-description",
            details: { key: "value" },
            incident_key: "a-test-incident-key",
          )
        }
      end

      describe "handles all responses" do

        context "PagerDuty successfully resolves the incident" do
          Given {
            transport.stub(:send => {
              "status" => "success",
              "incident_key" => "a-test-incident-key",
              "message" => "Event resolved",
            })
          }
          When(:resolve) { incident.resolve(description, details) }
          Then { expect(resolve).to be incident}
        end

        context "PagerDuty fails to create the incident" do
          Given {
            transport.stub(:send => {
              "status" => "failure",
              "message" => "Event not resolved",
            })
          }
          When(:resolve) { incident.resolve(description, details) }
          Then { expect(resolve).to have_failed PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given { transport.stub(:send).and_raise(Net::HTTPServerException.new(nil, nil)) }
          When(:resolve) { incident.resolve(description, details) }
          Then { expect(resolve).to have_failed Net::HTTPServerException }
        end
      end
    end
  end

  def standard_response
    { "status" => "success", "incident_key" => "My Incident Key" }
  end

  describe PagerdutyException do
    Given(:pagerduty_instance) { double }
    Given(:api_response) { double }

    When(:pagerduty_exception) { PagerdutyException.new(pagerduty_instance, api_response) }

    Then { pagerduty_exception.pagerduty_instance == pagerduty_instance }
    Then { pagerduty_exception.api_response == api_response }
  end
end

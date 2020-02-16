# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(service_key, options) }

  Given(:service_key) { "a-test-service-key" }
  Given(:options) { {} }
  Given(:transport) {
    instance_spy(Pagerduty::HttpTransport, send_payload: standard_response)
  }
  Given {
    allow(Pagerduty::HttpTransport)
      .to receive(:new)
      .and_return(transport)
  }

  describe "#service_key" do
    When(:returned_service_key) { pagerduty.service_key }
    Then { expect(returned_service_key).to eq(service_key) }
  end

  describe "#trigger" do
    describe "provides the correct request" do
      context "no options" do
        When(:incident) { pagerduty.trigger("a-test-description") }
        Then {
          expect(transport).to have_received(:send_payload).with(
            service_key: "a-test-service-key",
            event_type:  "trigger",
            description: "a-test-description",
          )
        }
      end

      context "all options" do
        When(:incident) {
          pagerduty.trigger(
            "a-test-description",
            incident_key: "a-test-incident-key",
            client:       "a-test-client",
            client_url:   "a-test-client-url",
            details:      { key: "value" },
          )
        }
        Then {
          expect(transport).to have_received(:send_payload).with(
            service_key:  "a-test-service-key",
            event_type:   "trigger",
            description:  "a-test-description",
            incident_key: "a-test-incident-key",
            client:       "a-test-client",
            client_url:   "a-test-client-url",
            details:      { key: "value" },
          )
        }
      end

      context "with proxy" do
        Given(:options) {
          {
            proxy_host:     "test-proxy-host",
            proxy_port:     "test-proxy-port",
            proxy_username: "test-proxy-username",
            proxy_password: "test-proxy-password",
          }
        }
        When(:incident) { pagerduty.trigger("a-test-description") }
        Then {
          expect(Pagerduty::HttpTransport).to have_received(:new).with(
            a_hash_including(
              proxy: {
                host:     "test-proxy-host",
                port:     "test-proxy-port",
                username: "test-proxy-username",
                password: "test-proxy-password",
              },
            ),
          )
        }
      end
    end

    describe "handles all responses" do
      context "PagerDuty successfully creates the incident" do
        Given {
          allow(transport).to receive(:send_payload).and_return(
            "status"       => "success",
            "incident_key" => "My Incident Key",
            "message"      => "Event processed",
          )
        }
        When(:incident) { pagerduty.trigger("description") }
        Then { expect(incident).to be_a PagerdutyIncident }
        Then { incident.service_key == service_key }
        Then { incident.incident_key == "My Incident Key" }
        Then { incident.instance_variable_get("@transport") == transport }
      end

      context "PagerDuty fails to create the incident" do
        Given {
          allow(transport).to receive(:send_payload).and_return(
            "status"  => "failure",
            "message" => "Event not processed",
          )
        }
        When(:incident) { pagerduty.trigger("description") }
        Then { expect(incident).to have_raised PagerdutyException }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given {
          allow(transport)
            .to receive(:send_payload)
            .and_raise(Net::HTTPServerException.new(nil, nil))
        }
        When(:incident) { pagerduty.trigger("description") }
        Then { expect(incident).to have_raised Net::HTTPServerException }
      end
    end
  end

  describe "#get_incident" do
    When(:incident) { pagerduty.get_incident(incident_key) }

    context "a valid incident_key" do
      Given(:incident_key) { "a-test-incident-key" }
      Then { expect(incident).to be_a PagerdutyIncident }
      Then { incident.service_key == service_key }
      Then { incident.incident_key == incident_key }
      Then { incident.instance_variable_get("@transport") == transport }
    end

    context "a nil incident_key" do
      Given(:incident_key) { nil }
      Then { expect(incident).to have_failed ArgumentError }
    end
  end

  describe PagerdutyIncident do
    Given(:incident) { pagerduty.get_incident(incident_key) }

    Given(:incident_key) { "a-test-incident-key" }

    describe "#acknowledge" do
      describe "provides the correct request" do
        context "no args" do
          When(:acknowledge) { incident.acknowledge }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "acknowledge",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
            )
          }
        end

        context "a description" do
          When(:acknowledge) { incident.acknowledge("test-description") }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "acknowledge",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
              description:  "test-description",
            )
          }
        end

        context "a description and details" do
          When(:acknowledge) {
            incident.acknowledge("test-description", my: "detail")
          }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "acknowledge",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
              description:  "test-description",
              details:      { my: "detail" },
            )
          }
        end
      end

      describe "handles all responses" do
        context "PagerDuty successfully acknowledges the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status"       => "success",
              "incident_key" => "a-test-incident-key",
              "message"      => "Event acknowledged",
            )
          }
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to be incident }
        end

        context "PagerDuty fails to acknowledge the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status"       => "failure",
              "incident_key" => "a-test-incident-key",
              "message"      => "Event not acknowledged",
            )
          }
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to have_failed PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given {
            allow(transport)
              .to receive(:send_payload)
              .and_raise(Net::HTTPServerException.new(nil, nil))
          }
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to have_failed Net::HTTPServerException }
        end
      end
    end

    describe "#resolve" do
      describe "provides the correct request" do
        context "no args" do
          When(:resolve) { incident.resolve }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "resolve",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
            )
          }
        end

        context "a description" do
          When(:resolve) { incident.resolve("test-description") }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "resolve",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
              description:  "test-description",
            )
          }
        end

        context "a description and details" do
          When(:resolve) { incident.resolve("test-description", my: "detail") }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "resolve",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
              description:  "test-description",
              details:      { my: "detail" },
            )
          }
        end
      end

      describe "handles all responses" do
        context "PagerDuty successfully resolves the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status"       => "success",
              "incident_key" => "a-test-incident-key",
              "message"      => "Event resolved",
            )
          }
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to be incident }
        end

        context "PagerDuty fails to create the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status"  => "failure",
              "message" => "Event not resolved",
            )
          }
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to have_failed PagerdutyException }
        end

        context "PagerDuty responds with HTTP bad request" do
          Given {
            allow(transport)
              .to receive(:send_payload)
              .and_raise(Net::HTTPServerException.new(nil, nil))
          }
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to have_failed Net::HTTPServerException }
        end
      end
    end

    describe "#trigger" do
      describe "provides the correct request" do
        context "no options" do
          Given(:incident_key) { "instance incident_key" }
          When(:trigger) { incident.trigger("description") }
          Then {
            expect(transport).to have_received(:send_payload).with(
              incident_key: "instance incident_key",
              service_key:  "a-test-service-key",
              event_type:   "trigger",
              description:  "description",
            )
          }
        end

        context "with incident_key option" do
          When(:trigger) {
            incident.trigger(
              "description",
              incident_key: "method param incident_key",
            )
          }
          Then {
            expect(transport).to have_received(:send_payload).with(
              incident_key: "method param incident_key",
              service_key:  "a-test-service-key",
              event_type:   "trigger",
              description:  "description",
            )
          }
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
    Given(:message) { "a test error message" }

    When(:pagerduty_exception) {
      PagerdutyException.new(pagerduty_instance, api_response, message)
    }

    Then { pagerduty_exception.pagerduty_instance == pagerduty_instance }
    Then { pagerduty_exception.api_response == api_response }
    Then { pagerduty_exception.message == message }
  end
end

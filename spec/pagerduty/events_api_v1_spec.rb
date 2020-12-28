# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pagerduty do
  When(:pagerduty) {
    Pagerduty.build(
      integration_key: service_key,
      api_version:     api_version,
      http_proxy:      http_proxy,
    )
  }

  Given(:service_key) { "a-test-service-key" }
  Given(:api_version) { 1 }
  Given(:http_proxy) { {} }
  Given(:transport) {
    instance_spy(Pagerduty::HttpTransport, send_payload: standard_response)
  }
  Given {
    allow(Pagerduty::HttpTransport)
      .to receive(:new)
      .and_return(transport)
  }
  Given(:standard_response) {
    { "status" => "success", "incident_key" => "incident-key-from-response" }
  }

  describe ".build" do
    context "given version: `1`" do
      Given(:api_version) { 1 }
      Then { expect(pagerduty).to be_a(Pagerduty::EventsApiV1) }
    end

    context "given version: `'1'`" do
      Given(:api_version) { "1" }
      Then { expect(pagerduty).to be_a(Pagerduty::EventsApiV1) }
    end
  end

  describe "#trigger" do
    describe "sending the API request" do
      context "given no options" do
        When(:incident) { pagerduty.trigger("a-test-description") }
        Then {
          expect(transport).to have_received(:send_payload).with(
            service_key: "a-test-service-key",
            event_type:  "trigger",
            description: "a-test-description",
          )
        }
      end

      context "given most options" do
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

      context "configured with an HTTP proxy" do
        Given(:http_proxy) {
          {
            host:     "test-proxy-host",
            port:     "test-proxy-port",
            username: "test-proxy-username",
            password: "test-proxy-password",
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

    describe "handling responses" do
      context "PagerDuty successfully creates the incident" do
        Given {
          allow(transport).to receive(:send_payload).and_return(
            "status"       => "success",
            "incident_key" => "My Incident Key",
            "message"      => "Event processed",
          )
        }
        When(:incident) { pagerduty.trigger("description") }
        Then { expect(incident).to be_a Pagerduty::EventsApiV1::Incident }
        Then { incident.incident_key == "My Incident Key" }
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
            .and_raise(Net::HTTPClientException.new(nil, nil))
        }
        When(:incident) { pagerduty.trigger("description") }
        Then { expect(incident).to have_raised Net::HTTPClientException }
      end
    end
  end

  describe "#incident" do
    When(:incident) { pagerduty.incident(incident_key) }

    context "a valid incident_key" do
      Given(:incident_key) { "a-test-incident-key" }
      Then { expect(incident).to be_a Pagerduty::EventsApiV1::Incident }
      Then { incident.incident_key == incident_key }
    end

    context "a nil incident_key" do
      Given(:incident_key) { nil }
      Then { expect(incident).to have_failed ArgumentError }
    end
  end

  describe Pagerduty::EventsApiV1::Incident do
    Given(:incident) { pagerduty.incident(incident_key) }

    Given(:incident_key) { "a-test-incident-key" }

    describe "#acknowledge" do
      describe "sending the API request" do
        context "given no arguments" do
          When(:acknowledge) { incident.acknowledge }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "acknowledge",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
            )
          }
        end

        context "given a description" do
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

        context "given a description and details" do
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

      describe "handling responses" do
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
              .and_raise(Net::HTTPClientException.new(nil, nil))
          }
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to have_failed Net::HTTPClientException }
        end
      end
    end

    describe "#resolve" do
      describe "sending the API request" do
        context "given no arguments" do
          When(:resolve) { incident.resolve }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_type:   "resolve",
              service_key:  "a-test-service-key",
              incident_key: "a-test-incident-key",
            )
          }
        end

        context "given a description" do
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

        context "given a description and details" do
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

      describe "handling responses" do
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
              .and_raise(Net::HTTPClientException.new(nil, nil))
          }
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to have_failed Net::HTTPClientException }
        end
      end
    end

    describe "#trigger" do
      describe "sending the API request" do
        context "given no options" do
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

        context "given a incident_key option" do
          When(:trigger) { incident.trigger("desc", incident_key: "key") }
          Then { expect(trigger).to have_failed ArgumentError }
        end
      end
    end
  end
end

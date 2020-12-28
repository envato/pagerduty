# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pagerduty do
  When(:pagerduty) {
    Pagerduty.build(
      integration_key: integration_key,
      api_version:     api_version,
      http_proxy:      http_proxy,
    )
  }

  Given(:integration_key) { "a-test-routing-key" }
  Given(:api_version) { 2 }
  Given(:http_proxy) { nil }
  Given(:transport) {
    instance_spy(Pagerduty::HttpTransport, send_payload: standard_response)
  }
  Given {
    allow(Pagerduty::HttpTransport)
      .to receive(:new)
      .and_return(transport)
  }
  Given(:standard_response) {
    {
      "status"    => "success",
      "message"   => "MY MESSAGE",
      "dedup_key" => "my-incident-key",
    }
  }
  Given(:simple_incident_details) {
    {
      summary:  "summary",
      source:   "source",
      severity: "critical",
    }
  }

  describe ".build" do
    context "given version: `2`" do
      Given(:api_version) { 2 }
      Then { expect(pagerduty).to be_a(Pagerduty::EventsApiV2) }
    end

    context "given version: `'2'`" do
      Given(:api_version) { "2" }
      Then { expect(pagerduty).to be_a(Pagerduty::EventsApiV2) }
    end
  end

  describe "#trigger" do
    describe "sending the API request" do
      context "given no event details" do
        When(:incident) { pagerduty.trigger }
        Then { expect(incident).to have_raised ArgumentError }
      end

      context "given all event details" do
        When(:incident) {
          pagerduty.trigger(
            summary:        "summary",
            source:         "source",
            severity:       "critical",
            timestamp:      Time.iso8601("2015-07-17T08:42:58Z"),
            component:      "component",
            group:          "group",
            class:          "class",
            custom_details: {
              random: "random",
            },
            images:         [{
              src:  "http://via.placeholder.com/350x150",
              href: "https://example.com/",
              alt:  "Example text",
            }],
            links:          [{
              href: "https://example.com/",
              text: "Link text",
            }],
            client:         "Sample Monitoring Service",
            client_url:     "https://monitoring.example.com",
          )
        }
        Then {
          expect(transport).to have_received(:send_payload).with(
            routing_key:  "a-test-routing-key",
            event_action: "trigger",
            dedup_key:    nil,
            payload:      {
              summary:        "summary",
              source:         "source",
              severity:       "critical",
              timestamp:      "2015-07-17T08:42:58Z",
              component:      "component",
              group:          "group",
              class:          "class",
              custom_details: {
                random: "random",
              },
            },
            images:       [{
              src:  "http://via.placeholder.com/350x150",
              href: "https://example.com/",
              alt:  "Example text",
            }],
            links:        [{
              href: "https://example.com/",
              text: "Link text",
            }],
            client:       "Sample Monitoring Service",
            client_url:   "https://monitoring.example.com",
          )
        }
      end

      context "given simple event details" do
        When { pagerduty.trigger(simple_incident_details) }
        Then {
          expect(transport).to have_received(:send_payload).with(
            routing_key:  "a-test-routing-key",
            dedup_key:    nil,
            event_action: "trigger",
            payload:      {
              summary:  "summary",
              source:   "source",
              severity: "critical",
            },
          )
        }
      end

      context "given a dedup_key option" do
        When(:trigger) {
          pagerduty.trigger(simple_incident_details.merge(dedup_key: "key"))
        }
        Then { expect(trigger).to have_failed ArgumentError }
      end

      context "given an incident_key option" do
        When(:trigger) {
          pagerduty.trigger(simple_incident_details.merge(incident_key: "key"))
        }
        Then { expect(trigger).to have_failed ArgumentError }
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
        When(:incident) { pagerduty.trigger(simple_incident_details) }
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
            "status"    => "success",
            "dedup_key" => "incident-key-in-response",
            "message"   => "Event processed",
          )
        }
        When(:incident) { pagerduty.trigger(simple_incident_details) }
        Then { expect(incident).to be_a Pagerduty::EventsApiV2::Incident }
        Then { incident.incident_key == "incident-key-in-response" }
      end

      context "PagerDuty fails to create the incident" do
        Given {
          allow(transport).to receive(:send_payload).and_return(
            "status"  => "invalid event",
            "message" => "Event object is invalid",
          )
        }
        When(:incident) { pagerduty.trigger(simple_incident_details) }
        Then { expect(incident).to have_raised PagerdutyException }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given {
          allow(transport)
            .to receive(:send_payload)
            .and_raise(Net::HTTPClientException.new(nil, nil))
        }
        When(:incident) { pagerduty.trigger(simple_incident_details) }
        Then { expect(incident).to have_raised Net::HTTPClientException }
      end
    end
  end

  describe "#incident" do
    When(:incident) { pagerduty.incident(incident_key) }

    context "a valid incident_key" do
      Given(:incident_key) { "a-test-incident-key" }
      Then { expect(incident).to be_a Pagerduty::EventsApiV2::Incident }
      Then { incident.incident_key == incident_key }
    end

    context "a nil incident_key" do
      Given(:incident_key) { nil }
      Then { expect(incident).to have_failed ArgumentError }
    end
  end

  describe Pagerduty::EventsApiV2::Incident do
    Given(:incident) { pagerduty.incident(incident_key) }
    Given(:incident_key) { "a-test-incident-key" }

    describe "#acknowledge" do
      describe "sending the API request" do
        context "given no event details" do
          When { incident.acknowledge }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_action: "acknowledge",
              routing_key:  "a-test-routing-key",
              dedup_key:    "a-test-incident-key",
            )
          }
        end

        context "given a single string arg (like in V1)" do
          When(:acknowledge) { incident.acknowledge("test-description") }
          Then { expect(acknowledge).to have_failed ArgumentError }
        end

        context "given a string arg and options hash (like in V1)" do
          When(:acknowledge) {
            incident.acknowledge("test-description", my: "detail")
          }
          Then { expect(acknowledge).to have_failed ArgumentError }
        end
      end

      describe "handling API responses" do
        context "PagerDuty successfully acknowledges the incident" do
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to be incident }
        end

        context "PagerDuty fails to acknowledge the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status"  => "invalid event",
              "message" => "Event object is invalid",
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
        context "given no event details" do
          When(:resolve) { incident.resolve }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_action: "resolve",
              routing_key:  "a-test-routing-key",
              dedup_key:    "a-test-incident-key",
            )
          }
        end

        context "a description" do
          When(:resolve) { incident.resolve("test-description") }
          Then { expect(resolve).to have_failed ArgumentError }
        end

        context "a description and details" do
          When(:resolve) { incident.resolve("test-description", my: "detail") }
          Then { expect(resolve).to have_failed ArgumentError }
        end
      end

      describe "handling API responses" do
        context "PagerDuty successfully resolves the incident" do
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to be incident }
        end

        context "PagerDuty fails to create the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status"  => "invalid event",
              "message" => "Event object is invalid",
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
        context "given no arguments" do
          When(:trigger) { incident.trigger }
          Then { expect(trigger).to have_failed ArgumentError }
        end

        context "given simple event details" do
          Given(:incident_key) { "instance incident_key" }
          When(:trigger) { incident.trigger(simple_incident_details) }
          Then {
            expect(transport).to have_received(:send_payload).with(
              routing_key:  "a-test-routing-key",
              dedup_key:    "instance incident_key",
              event_action: "trigger",
              payload:      {
                summary:  "summary",
                source:   "source",
                severity: "critical",
              },
            )
          }
        end

        context "given a dedup_key option" do
          When(:trigger) {
            incident.trigger(simple_incident_details.merge(dedup_key: "key"))
          }
          Then { expect(trigger).to have_failed ArgumentError }
        end

        context "given an incident_key option" do
          When(:trigger) {
            incident.trigger(simple_incident_details.merge(incident_key: "key"))
          }
          Then { expect(trigger).to have_failed ArgumentError }
        end
      end
    end
  end
end

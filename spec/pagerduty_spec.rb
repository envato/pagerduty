
require "spec_helper"

describe Pagerduty do
  Given(:pagerduty) { Pagerduty.new(routing_key, options) }

  Given(:routing_key) { "a-test-routing-key" }
  Given(:options) { { transport: transport } }
  Given(:transport) { spy }

  describe "#trigger" do
    describe "provides the correct request" do
      Given {
        allow(transport)
          .to receive(:send_payload)
          .and_return(standard_response)
      }

      context "no options" do
        When(:incident) { pagerduty.trigger }
        Then {
          expect(incident).to have_raised ArgumentError
        }
      end

      context "all options" do
        When(:incident) {
          pagerduty.trigger(
            summary: "summary",
            source: "source",
            severity: "critical",
            timestamp: "timestamp",
            component: "component",
            group: "group",
            class: "class",
            custom_details: {
              random: "random",
            },
            images: [{
              src: "http://via.placeholder.com/350x150",
              href: "https://example.com/",
              alt: "Example text",
            }],
            links: [{
              href: "https://example.com/",
              text: "Link text",
            }],
            client: "Sample Monitoring Service",
            client_url: "https://monitoring.example.com",
          )
        }
        Then {
          expect(transport).to have_received(:send_payload).with(
            routing_key: "a-test-routing-key",
            event_action: "trigger",
            dedup_key: nil,
            payload: {
              summary: "summary",
              source: "source",
              severity: "critical",
              timestamp: "timestamp",
              component: "component",
              group: "group",
              class: "class",
              custom_details: {
                random: "random",
              },
            },
            images: [{
              src: "http://via.placeholder.com/350x150",
              href: "https://example.com/",
              alt: "Example text",
            }],
            links: [{
              href: "https://example.com/",
              text: "Link text",
            }],
            client: "Sample Monitoring Service",
            client_url: "https://monitoring.example.com",
          )
        }
      end

      context "with proxy" do
        Given(:options) {
          {
            proxy_host: "test-proxy-host",
            proxy_port: "test-proxy-port",
            proxy_username: "test-proxy-username",
            proxy_password: "test-proxy-password",
          }
        }
        Given {
          allow(Pagerduty::HttpTransport)
            .to receive(:new)
            .and_return(transport)
        }
        When(:incident) { pagerduty.trigger("a-test-description") }
        Then {
          expect(Pagerduty::HttpTransport).to have_received(:new).with(
            proxy_host: "test-proxy-host",
            proxy_port: "test-proxy-port",
            proxy_username: "test-proxy-username",
            proxy_password: "test-proxy-password",
          )
        }
      end
    end

    describe "handles all responses" do
      context "PagerDuty successfully creates the incident" do
        Given {
          allow(transport).to receive(:send_payload).and_return(
            standard_response,
          )
        }
        When(:incident) { pagerduty.trigger(min_req_input) }
        Then { expect(incident).to be_a PagerdutyIncident }
        Then { incident.routing_key == routing_key }
        Then { incident.dedup_key == "my-dedup-key" }
        Then { incident.instance_variable_get("@transport") == transport }
      end

      context "PagerDuty fails to create the incident" do
        Given {
          allow(transport).to receive(:send_payload).and_return(
            "status" => "invalid event",
            "message" => "Event object is invalid",
          )
        }
        When(:incident) { pagerduty.trigger(min_req_input) }
        Then { expect(incident).to have_raised PagerdutyException }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given {
          allow(transport)
            .to receive(:send_payload)
            .and_raise(Net::HTTPServerException.new(nil, nil))
        }
        When(:incident) { pagerduty.trigger(min_req_input) }
        Then { expect(incident).to have_raised Net::HTTPServerException }
      end
    end
  end

  describe "#get_incident" do
    When(:incident) { pagerduty.get_incident(dedup_key) }

    context "a valid incident_key" do
      Given(:dedup_key) { "a-test-dedup-key" }
      Then { expect(incident).to be_a PagerdutyIncident }
      Then { incident.routing_key == routing_key }
      Then { incident.dedup_key == dedup_key }
      Then { incident.instance_variable_get("@transport") == transport }
    end

    context "a nil incident_key" do
      Given(:dedup_key) { nil }
      Then { expect(incident).to have_failed ArgumentError }
    end
  end

  describe PagerdutyIncident do
    Given(:incident) {
      PagerdutyIncident.new(routing_key, dedup_key, options)
    }
    Given(:dedup_key) { "a-test-dedup-key" }

    describe "#acknowledge" do
      describe "provides the correct request" do
        Given {
          allow(transport)
            .to receive(:send_payload)
            .and_return(standard_response)
        }

        context "no args" do
          When(:acknowledge) { incident.acknowledge }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_action: "acknowledge",
              routing_key: "a-test-routing-key",
              dedup_key: "a-test-dedup-key",
              images: nil,
              links: nil,
              client: nil,
              client_url: nil,
            )
          }
        end

        context "a description" do
          When(:acknowledge) { incident.acknowledge("test-description") }
          Then {
            expect(acknowledge).to have_failed ArgumentError
          }
        end

        context "a description and details" do
          When(:acknowledge) {
            incident.acknowledge("test-description", my: "detail")
          }
          Then {
            expect(acknowledge).to have_failed ArgumentError
          }
        end
      end

      describe "handles all responses" do
        context "PagerDuty successfully acknowledges the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              standard_response,
            )
          }
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to be incident }
        end

        context "PagerDuty fails to acknowledge the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status" => "invalid event",
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
              .and_raise(Net::HTTPServerException.new(nil, nil))
          }
          When(:acknowledge) { incident.acknowledge }
          Then { expect(acknowledge).to have_failed Net::HTTPServerException }
        end
      end
    end

    describe "#resolve" do
      describe "provides the correct request" do
        Given {
          allow(transport)
            .to receive(:send_payload)
            .and_return(standard_response)
        }

        context "no args" do
          When(:resolve) { incident.resolve }
          Then {
            expect(transport).to have_received(:send_payload).with(
              event_action: "resolve",
              routing_key: "a-test-routing-key",
              dedup_key: "a-test-dedup-key",
              images: nil,
              links: nil,
              client: nil,
              client_url: nil,
            )
          }
        end

        context "a description" do
          When(:resolve) { incident.resolve("test-description") }
          Then {
            expect(resolve).to have_failed ArgumentError
          }
        end

        context "a description and details" do
          When(:resolve) { incident.resolve("test-description", my: "detail") }
          Then {
            expect(resolve).to have_failed ArgumentError
          }
        end
      end

      describe "handles all responses" do
        context "PagerDuty successfully resolves the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              standard_response,
            )
          }
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to be incident }
        end

        context "PagerDuty fails to create the incident" do
          Given {
            allow(transport).to receive(:send_payload).and_return(
              "status" => "invalid event",
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
              .and_raise(Net::HTTPServerException.new(nil, nil))
          }
          When(:resolve) { incident.resolve }
          Then { expect(resolve).to have_failed Net::HTTPServerException }
        end
      end
    end

    describe "#trigger" do
      describe "provides the correct request" do
        Given {
          allow(transport)
            .to receive(:send_payload)
            .and_return(standard_response)
        }

        context "incorrect parameter type" do
          Given(:dedup_key) { "instance dedup_key" }
          When(:trigger) { incident.trigger("description") }
          Then {
            expect(trigger).to have_failed TypeError
          }
        end

        context "no options" do
          Given(:dedup_key) { "instance dedup_key" }
          When(:trigger) { incident.trigger(min_req_input) }
          Then {
            expect(transport).to have_received(:send_payload).with(
              routing_key:  "a-test-routing-key",
              dedup_key: "instance dedup_key",
              event_action:   "trigger",
              images: nil,
              links: nil,
              client: nil,
              client_url: nil,
              payload: {
                summary: "summary",
                source: "source",
                severity: "critical",
              },
            )
          }
        end

        context "with incident_key option" do
          When(:trigger) {
            incident.trigger(
              dedup_key: "instance dedup_key",
            )
          }
          Then {
            expect(transport).to have_received(:send_payload).with(
              routing_key:  "a-test-routing-key",
              dedup_key: "instance dedup_key",
              event_action:   "trigger",
              images: nil,
              links: nil,
              client: nil,
              client_url: nil,
            )
          }
        end
      end
    end
  end

  def standard_response
    {
      "status" => "success",
      "message" => "MY MESSAGE",
      "dedup_key" => "my-dedup-key",
    }
  end

  def min_req_input
    {
      summary: "summary",
      source: "source",
      severity: "critical",
    }
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

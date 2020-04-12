# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pagerduty do
  describe ".build" do
    When(:build) { Pagerduty.build(config) }

    context "given an integration key and API version: `1`" do
      Given(:config) { { integration_key: "test-key", api_version: 1 } }
      Then { expect(build).to be_a(Pagerduty::EventsApiV1) }
    end

    context "given an integration key and API version: `'1'`" do
      Given(:config) { { integration_key: "test-key", api_version: "1" } }
      Then { expect(build).to be_a(Pagerduty::EventsApiV1) }
    end

    context "given an integration key, but no API version" do
      Given(:config) { { integration_key: "test-key" } }
      Then {
        expect(build).to have_raised(ArgumentError,
                                     "api_version not provided")
      }
    end

    context "given an API version, but no integration key" do
      Given(:config) { { api_version: 1 } }
      Then {
        expect(build).to have_raised(ArgumentError,
                                     "integration_key not provided")
      }
    end

    context "given an integration key and an unknown API version" do
      Given(:config) { { integration_key: "test-key", api_version: 0 } }
      Then {
        expect(build).to have_raised(ArgumentError,
                                     "api_version 0 not supported")
      }
    end

    context "given an incident key" do
      Given(:config) {
        { incident_key: "ik", integration_key: "test-key", api_version: 1 }
      }
      Then {
        expect(build).to have_raised(ArgumentError, "incident_key provided")
      }
    end
  end
end

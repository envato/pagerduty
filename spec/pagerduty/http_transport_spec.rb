# encoding: utf-8
require "spec_helper"

describe Pagerduty::HttpTransport do
  Given(:http_transport) { Pagerduty::HttpTransport }

  Given(:http) { double.as_null_object }
  Given { http.stub(:request => standard_response) }
  Given { Net::HTTP.stub(:new => http) }
  Given(:post) { double.as_null_object }
  Given { Net::HTTP::Post.stub(:new => post) }

  describe "::send" do
    Given(:payload) { {
      event_type: "trigger",
      service_key: "test-srvc-key",
      description: "test-desc",
      details: { key: "value" },
    } }

    When(:response) { http_transport.send(payload) }

    describe "provides the correct request" do
      Then {
        expect(post).to have_received(:body=).with(
          '{"event_type":"trigger","service_key":"test-srvc-key","description":"test-desc","details":{"key":"value"}}'
        )
      }
    end

    describe "handles all responses" do

      context "PagerDuty successfully creates the incident" do
        Given { http.stub(:request => response_with_body(<<-JSON)) }
          {
            "status": "success",
            "incident_key": "My Incident Key",
            "message": "Event processed"
          }
        JSON
        Then { expect(response).to include("status" => "success") }
        Then { expect(response).to include("incident_key" => "My Incident Key") }
      end

      context "PagerDuty fails to create the incident" do
        Given { http.stub(:request => response_with_body(<<-JSON)) }
          {
            "status": "failure",
            "message": "Event not processed"
          }
        JSON
        Then { expect(response).to include("status" => "failure") }
        Then { expect(response).to_not include("incident_key") }
      end

      context "PagerDuty responds with HTTP bad request" do
        Given { http.stub(:request => bad_request) }
        Then { expect(response).to have_raised Net::HTTPServerException }
      end
    end

    describe "HTTPS use" do
      Then { expect(http).to have_received(:use_ssl=).with(true) }
      Then { expect(http).to have_received(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER) }
      Then { expect(http).to_not have_received(:ca_path=) }
      Then { expect(http).to_not have_received(:verify_depth=) }
    end

    describe "timeouts" do
      Then { expect(http).to have_received(:open_timeout=).with(60) }
      Then { expect(http).to have_received(:read_timeout=).with(60) }
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

end

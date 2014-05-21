require 'pagerduty/version'
require 'pagerduty/http_transport'

class PagerdutyException < Exception
  attr_reader :pagerduty_instance, :api_response

  def initialize(instance, resp)
    @pagerduty_instance = instance
    @api_response = resp
  end
end

class Pagerduty

  attr_reader :service_key

  def initialize(service_key)
    @service_key = service_key
  end

  def trigger(description, details = {})
    resp = api_call("trigger", :description => description, :details => details)
    ensure_success(resp)
    PagerdutyIncident.new @service_key, resp["incident_key"]
  end

  def get_incident(incident_key)
    PagerdutyIncident.new @service_key, incident_key
  end

protected

  def api_call(event_type, args)
    args = args.merge(
      :service_key => service_key,
      :event_type => event_type,
    )
    Pagerduty.transport.send(args)
  end

  def ensure_success(response)
    unless response["status"] == "success"
      raise PagerdutyException.new(self, response)
    end
  end

  class << self
    def transport
      Pagerduty::HttpTransport
    end
  end
end

class PagerdutyIncident < Pagerduty
  attr_reader :incident_key

  def initialize(service_key, incident_key)
    super service_key
    @incident_key = incident_key
  end

  def acknowledge(description, details = {})
    resp = api_call("acknowledge", :incident_key => @incident_key, :description => description, :details => details)
    ensure_success(resp)
    self
  end

  def resolve(description, details = {})
    resp = api_call("resolve", :incident_key => @incident_key, :description => description, :details => details)
    ensure_success(resp)
    self
  end

end

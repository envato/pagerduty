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

  attr_reader :service_key, :incident_key

  def initialize(service_key, incident_key = nil)
    @service_key = service_key
    @incident_key = incident_key
  end

  def trigger(description, details = {})
    resp = api_call("trigger", :description => description, :details => details)
    raise PagerdutyException.new(self, resp) unless resp["status"] == "success"

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
    args[:incident_key] = @incident_key if @incident_key
    Pagerduty.transport.send(args)
  end

  class << self
    def transport
      Pagerduty::HttpTransport
    end
  end
end

class PagerdutyIncident < Pagerduty

  def initialize(service_key, incident_key)
    super service_key
    @incident_key = incident_key
  end

  def acknowledge(description, details = {})
    resp = api_call("acknowledge", :description => description, :details => details)
    raise PagerdutyException.new(self, resp) unless resp["status"] == "success"

    self
  end

  def resolve(description, details = {})
    resp = api_call("resolve", :description => description, :details => details)
    raise PagerdutyException.new(self, resp) unless resp["status"] == "success"

    self
  end

end

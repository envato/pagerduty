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

  def trigger(description, options = {})
    resp = api_call("trigger", options.merge(:description => description))
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

  def acknowledge(description = nil, details = nil)
    modify_incident("acknowledge", description, details)
  end

  def resolve(description = nil, details = nil)
    modify_incident("resolve", description, details)
  end

private

  def modify_incident(event_type, description, details)
    options = { :incident_key => incident_key }
    options[:description] = description if description
    options[:details] = details if details
    resp = api_call(event_type, options)
    ensure_success(resp)
    self
  end

end

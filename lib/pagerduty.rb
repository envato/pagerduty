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

  # @param [String] service_key The GUID of one of your "Generic API" services.
  #   This is the "service key" listed on a Generic API's service detail page.
  #
  def initialize(service_key)
    @service_key = service_key
  end

  # @param [String] description A short description of the problem that led to
  #   this trigger. This field (or a truncated version) will be used when
  #   generating phone calls, SMS messages and alert emails. It will also appear
  #   on the incidents tables in the PagerDuty UI. The maximum length is 1024
  #   characters.
  #
  # @option options [String] :incident_key Identifies the incident to which
  #   this trigger event should be applied. If there's no open (i.e. unresolved)
  #   incident with this key, a new one will be created. If there's already an
  #   open incident with a matching key, this event will be appended to that
  #   incident's log. The event key provides an easy way to "de-dup" problem
  #   reports. If this field isn't provided, PagerDuty will automatically open a
  #   new incident with a unique key.
  #
  # @option options [String] :client The name of the monitoring client that is
  #   triggering this event.
  #
  # @option options [String] :client_url The URL of the monitoring client that
  #   is triggering this event.
  #
  # @option options [Hash] :details An arbitrary hash containing any data you'd
  #   like included in the incident log.
  #
  def trigger(description, options = {})
    resp = api_call("trigger", options.merge(:description => description))
    ensure_success(resp)
    PagerdutyIncident.new service_key, resp["incident_key"]
  end

  def get_incident(incident_key)
    PagerdutyIncident.new service_key, incident_key
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

  # @api private
  def self.transport
    Pagerduty::HttpTransport
  end
end

class PagerdutyIncident < Pagerduty
  attr_reader :incident_key

  # @param [String] service_key The GUID of one of your "Generic API" services.
  #   This is the "service key" listed on a Generic API's service detail page.
  #
  # @param [String] incident_key The unique identifier for the incident.
  #
  def initialize(service_key, incident_key)
    super service_key
    @incident_key = incident_key
  end

  # @param [String] description Text that will appear in the incident's log
  #   associated with this event.
  #
  # @param [Hash] details An arbitrary hash containing any data you'd like
  #   included in the incident log.
  #
  def acknowledge(description = nil, details = nil)
    modify_incident("acknowledge", description, details)
  end

  # @param [String] description Text that will appear in the incident's log
  #   associated with this event.
  #
  # @param [Hash] details An arbitrary hash containing any data you'd like
  #   included in the incident log.
  #
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

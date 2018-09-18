require "pagerduty/version"
require "pagerduty/http_transport"

class PagerdutyException < StandardError
  attr_reader :pagerduty_instance, :api_response

  def initialize(instance, response, message)
    super(message)
    @pagerduty_instance = instance
    @api_response = response
  end
end

class Pagerduty
  attr_reader :service_key

  # @param [String] service_key The GUID of one of your "Generic API" services.
  #   This is the "service key" listed on a Generic API's service detail page.
  #
  # @option options [String] :proxy_host The DNS name or IP address of the
  #   proxy host. If nil or unprovided a proxy will not be used.
  #
  # @option options [String] :proxy_port The port to use to access the proxy.
  #
  # @option options [String] :proxy_username username if authorization is
  #   required to use the proxy.
  #
  # @option options [String] :proxy_password password if authorization is
  #   required to use the proxy.
  #
  def initialize(service_key, options = {})
    @service_key = service_key
    @transport = transport_from_options(options)
  end

  # Send PagerDuty a trigger event to report a new or ongoing problem. When
  # PagerDuty receives a trigger event, it will either open a new incident, or
  # add a new trigger log entry to an existing incident, depending on the
  # provided incident_key.
  #
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
  # @return [PagerdutyIncident] The triggered incident.
  #
  # @raise [PagerdutyException] If PagerDuty responds with a status that is not
  #   "success"
  #
  def trigger(description, options = {})
    resp = api_call("trigger", options.merge(description: description))
    ensure_success(resp)
    PagerdutyIncident.new(
      service_key,
      resp["incident_key"],
      transport: @transport,
    )
  end

  # @param [String] incident_key The unique identifier for the incident.
  #
  # @return [PagerdutyIncident] The incident referenced by the key.
  #
  # @raise [ArgumentError] If incident_key is nil
  #
  def get_incident(incident_key)
    raise ArgumentError, "incident_key is nil" if incident_key.nil?

    PagerdutyIncident.new(
      service_key,
      incident_key,
      transport: @transport,
    )
  end

protected

  def api_call(event_type, args)
    args = args.merge(
      service_key: service_key,
      event_type: event_type,
    )
    @transport.send_payload(args)
  end

  def ensure_success(response)
    unless response["status"] == "success"
      raise PagerdutyException.new(self, response, response["message"])
    end
  end

private

  # @api private
  def transport_from_options(options = {})
    options[:transport] || Pagerduty::HttpTransport.new(options)
  end
end

class PagerdutyIncident < Pagerduty
  attr_reader :incident_key

  # @param [String] service_key The GUID of one of your "Generic API" services.
  #   This is the "service key" listed on a Generic API's service detail page.
  #
  # @param [String] incident_key The unique identifier for the incident.
  #
  def initialize(service_key, incident_key, options = {})
    super service_key, options
    @incident_key = incident_key
  end

  # @param (see Pagerduty#trigger)
  # @option (see Pagerduty#trigger)
  def trigger(description, options = {})
    super(description, { incident_key: incident_key }.merge(options))
  end

  # Acknowledge the referenced incident. While an incident is acknowledged, it
  # won't generate any additional notifications, even if it receives new
  # trigger events. Send PagerDuty an acknowledge event when you know someone
  # is presently working on the problem.
  #
  # @param [String] description Text that will appear in the incident's log
  #   associated with this event.
  #
  # @param [Hash] details An arbitrary hash containing any data you'd like
  #   included in the incident log.
  #
  # @return [PagerdutyIncident] self
  #
  # @raise [PagerdutyException] If PagerDuty responds with a status that is not
  #   "success"
  #
  def acknowledge(description = nil, details = nil)
    modify_incident("acknowledge", description, details)
  end

  # Resolve the referenced incident. Once an incident is resolved, it won't
  # generate any additional notifications. New trigger events with the same
  # incident_key as a resolved incident won't re-open the incident. Instead, a
  # new incident will be created. Send PagerDuty a resolve event when the
  # problem that caused the initial trigger event has been fixed.
  #
  # @param [String] description Text that will appear in the incident's log
  #   associated with this event.
  #
  # @param [Hash] details An arbitrary hash containing any data you'd like
  #   included in the incident log.
  #
  # @return [PagerdutyIncident] self
  #
  # @raise [PagerdutyException] If PagerDuty responds with a status that is not
  #   "success"
  #
  def resolve(description = nil, details = nil)
    modify_incident("resolve", description, details)
  end

private

  def modify_incident(event_type, description, details)
    options = { incident_key: incident_key }
    options[:description] = description if description
    options[:details] = details if details
    resp = api_call(event_type, options)
    ensure_success(resp)
    self
  end
end

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
  attr_reader :routing_key

  # @param [String] routing_key The GUID of one of your
  #   Events API V3 integrations. This is the "Integration Key" listed on
  #   the Events API V3 integration's detail page.
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
  def initialize(routing_key, options = {})
    @routing_key = routing_key
    @transport = transport_from_options(options)
  end

  # Send PagerDuty a trigger event to report a new or ongoing problem. When
  # PagerDuty receives a trigger event, it will either open a new incident, or
  # add a new trigger log entry to an existing incident, depending on the
  # provided dedup_key.
  #
  # @option options [String] :dedup_key Identifies the incident to which
  #   this trigger event should be applied. If there's no open (i.e. unresolved)
  #   incident with this key, a new one will be created. If there's already an
  #   open incident with a matching key, this event will be appended to that
  #   incident's log. The event key provides an easy way to "de-dup" problem
  #   reports. If this field isn't provided, PagerDuty will automatically open a
  #   new incident with a unique key.
  #
  # @option options [String] :dedup_key Deduplication key for correlating
  #   triggers and resolves. The maximum permitted length of this property
  #   is 255 characters.
  #
  # @option options.payload [String] :summary A brief text summary of the event,
  #   used to generate the summaries/titles of any associated alerts.
  #
  # @option options.payload [String] :source The unique location of the affected
  #   system, preferably a hostname or FQDN.
  #
  # @option options.payload [String] :severity The unique location of the
  #   affected system, preferably a hostname or FQDN.
  #
  # @option options.payload [String] :timestamp The time at which the emitting
  #   tool detected or generated the event.
  #
  # @option options.payload [String] :component Component of the source machine
  #   that is responsible for the event, for example mysql or eth0
  #
  # @option options.payload [String] :group Logical grouping of components of a
  #   service, for example app-stack
  #
  # @option options.payload [String] :class The class/type of the event, for
  #   example ping failure or cpu load
  #
  # @option options.payload [Hash] :custom_details Additional details about the
  #   event and affected system
  #
  # @option options [Array] :images List of images to include.
  #
  # @option options [Array] :links List of links to include.
  #
  # @return [PagerdutyIncident] The triggered incident.
  #
  # @raise [PagerdutyException] If PagerDuty responds with a status that is not
  #   "success"
  #
  # @raise [ArgumentError] If options hash is nil
  #
  def trigger(options)
    raise ArgumentError, "options hash is nil" if options.nil?
    resp = api_call("trigger", options)
    ensure_success(resp)
    PagerdutyIncident.new(
      routing_key,
      resp["dedup_key"],
      transport: @transport,
    )
  end

  # @param [String] dedup_key The unique identifier for the incident.
  #
  # @return [PagerdutyIncident] The incident referenced by the key.
  #
  # @raise [ArgumentError] If dedup_key is nil
  #
  def get_incident(dedup_key)
    raise ArgumentError, "dedup_key is nil" if dedup_key.nil?
    PagerdutyIncident.new(
      routing_key,
      dedup_key,
      transport: @transport,
    )
  end

protected

  def api_call(event_action, args)
    payload = {
      routing_key: routing_key, event_action: event_action,
      dedup_key: args.delete(:dedup_key), payload: args,
      images: args.delete(:images), links: args.delete(:links),
      client: args.delete(:client), client_url: args.delete(:client_url)
    }

    # Necessary since new API V3 does not allow the
    # payload array on 'acknowledge' || 'resolve' events
    payload.delete(:payload) if payload[:payload].empty?

    @transport.send_payload(payload)
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
  attr_reader :dedup_key

  # @param [String] routing_key The GUID of one of your Events API
  #   V2 integrations. This is the "Integration Key" listed on the
  #   Events API V2 integration's detail page.
  #
  # @param [String] dedup_key The unique identifier for the incident.
  #
  def initialize(routing_key, dedup_key, options = {})
    super routing_key, options
    @dedup_key = dedup_key
  end

  # @param (see Pagerduty#trigger)
  # @option (see Pagerduty#trigger)
  def trigger(options)
    super({ dedup_key: dedup_key }.merge(options))
  end

  # Acknowledge the referenced incident. While an incident is acknowledged, it
  # won't generate any additional notifications, even if it receives new
  # trigger events. Send PagerDuty an acknowledge event when you know someone
  # is presently working on the problem.
  #
  # @return [PagerdutyIncident] self
  #
  # @raise [PagerdutyException] If PagerDuty responds with a status that is not
  #   "success"
  #
  def acknowledge
    modify_incident("acknowledge")
  end

  # Resolve the referenced incident. Once an incident is resolved, it won't
  # generate any additional notifications. New trigger events with the same
  # dedup_key as a resolved incident won't re-open the incident. Instead, a
  # new incident will be created. Send PagerDuty a resolve event when the
  # problem that caused the initial trigger event has been fixed.
  #
  # @return [PagerdutyIncident] self
  #
  # @raise [PagerdutyException] If PagerDuty responds with a status that is not
  #   "success"
  #
  def resolve
    modify_incident("resolve")
  end

private

  def modify_incident(event_action)
    options = { dedup_key: dedup_key }
    resp = api_call(event_action, options)
    ensure_success(resp)
    self
  end
end

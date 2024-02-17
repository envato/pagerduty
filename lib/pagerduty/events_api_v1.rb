# frozen_string_literal: true

module Pagerduty
  # Trigger incidents via the PagerDuty Events API version 1.
  #
  # @see https://v2.developer.pagerduty.com/docs/events-api PagerDuty Events
  #   API V1 documentation
  #
  # @see Pagerduty.build
  #
  # @see Pagerduty::EventsApiV1::Incident
  #
  class EventsApiV1
    # Rather than using this directly, use the {Pagerduty.build} method to
    # construct an instance.
    #
    # @option config [String] integration_key Authentication key for connecting
    #   to PagerDuty. A UUID expressed as a 32-digit hexadecimal number.
    #   Integration keys are generated by creating a new service, or creating a
    #   new integration for an existing service in PagerDuty, and can be found
    #   on a service's Integrations tab. This option is required.
    #
    # @option config [String] http_proxy.host The DNS name or IP address of the
    #   proxy host. If nil or unprovided an HTTP proxy will not be used.
    #
    # @option config [String] http_proxy.port The TCP port to use to access the
    #   proxy.
    #
    # @option config [String] http_proxy.username username if authorization is
    #   required to use the proxy.
    #
    # @option config [String] http_proxy.password password if authorization is
    #   required to use the proxy.
    #
    # @see Pagerduty.build
    #
    def initialize(config)
      @config = config
    end

    # Send PagerDuty a trigger event to report a new or ongoing problem.
    #
    # @example Trigger an incident
    #   incident = pagerduty.trigger(
    #     "<A description of the event or outage>"
    #   )
    #
    # @example Trigger an incident, providing more context and details
    #   incident = pagerduty.trigger(
    #     "FAILURE for production/HTTP on machine srv01.acme.com",
    #     client:     "Sample Monitoring Service",
    #     client_url: "https://monitoring.service.com",
    #     contexts:   [
    #       {
    #         type: "link",
    #         href: "http://acme.pagerduty.com",
    #         text: "View the incident on PagerDuty",
    #       },
    #       {
    #         type: "image",
    #         src:  "https://chart.googleapis.com/chart.png",
    #       }
    #     ],
    #     details:    {
    #       ping_time: "1500ms",
    #       load_avg:  0.75,
    #     },
    #   )
    #
    # @param [String] description A short description of the problem that led to
    #   this trigger. This field (or a truncated version) will be used when
    #   generating phone calls, SMS messages and alert emails. It will also
    #   appear on the incidents tables in the PagerDuty UI. The maximum length
    #   is 1024 characters.
    #
    # @option options [String] client The name of the monitoring client that is
    #   triggering this event.
    #
    # @option options [String] client_url The URL of the monitoring client that
    #   is triggering this event.
    #
    # @option options [Array] contexts An array of objects. Contexts to be
    #   included with the incident trigger such as links to graphs or images.
    #
    # @option options [Hash] details An arbitrary hash containing any data you'd
    #   like included in the incident log.
    #
    # @return [Pagerduty::EventsApiV1::Incident] The triggered incident.
    #
    # @raise [PagerdutyException] If PagerDuty responds with a status that is
    #   not "success"
    #
    def trigger(description, options = {})
      config = @config.merge(incident_key: options[:incident_key])
      options = options.reject { |key| key == :incident_key }
      Incident.new(config).trigger(description, options)
    end

    # @param [String] incident_key Identifies the incident to which
    #   this trigger event should be applied. If there's no open (i.e.
    #   unresolved) incident with this key, a new one will be created. If
    #   there's already an open incident with a matching key, this event will be
    #   appended to that incident's log. The event key provides an easy way to
    #   "de-dup" problem reports. If this field isn't provided, PagerDuty will
    #   automatically open a new incident with a unique key. The maximum length
    #   is 255 characters.
    #
    # @return [Pagerduty::EventsApiV1::Incident] The incident referenced by the
    #   key.
    #
    # @raise [ArgumentError] If incident_key is nil
    #
    def incident(incident_key)
      raise ArgumentError, "incident_key is nil" if incident_key.nil?

      Incident.new(@config.merge(incident_key: incident_key))
    end

    class Incident
      attr_reader :incident_key

      # @option (see Pagerduty::EventsApiV1#initialize)
      #
      # @option config [String] incident_key Identifies the incident to which
      #   this trigger event should be applied. If there's no open
      #   (i.e. unresolved) incident with this key, a new one will be created.
      #   If there's already an open incident with a matching key, this event
      #   will be appended to that incident's log. The event key provides an
      #   easy way to "de-dup" problem reports. If this field isn't provided,
      #   PagerDuty will automatically open a new incident with a unique key.
      #   The maximum length is 255 characters.
      #
      def initialize(config)
        @integration_key = config.fetch(:integration_key) do
          raise ArgumentError "integration_key not provided"
        end
        @incident_key = config[:incident_key]
        @transport = Pagerduty::HttpTransport.new(
          path:  "/generic/2010-04-15/create_event.json",
          proxy: config[:http_proxy],
        )
      end

      # Send PagerDuty a trigger event to report a new or ongoing problem. When
      # PagerDuty receives a trigger event, it will either open a new incident,
      # or add a new trigger log entry to an existing incident, depending on the
      # provided incident_key.
      #
      # @example Trigger or update an incident
      #   incident.trigger(
      #     "<A description of the event or outage>"
      #   )
      #
      # @example Trigger or update an incident, providing more context
      #   incident.trigger(
      #     "FAILURE for production/HTTP on machine srv01.acme.com",
      #     client:     "Sample Monitoring Service",
      #     client_url: "https://monitoring.service.com",
      #     contexts:   [
      #       {
      #         type: "link",
      #         href: "http://acme.pagerduty.com",
      #         text: "View the incident on PagerDuty",
      #       },
      #       {
      #         type: "image",
      #         src:  "https://chart.googleapis.com/chart.png",
      #       }
      #     ],
      #     details:    {
      #       ping_time: "1500ms",
      #       load_avg:  0.75,
      #     },
      #   )
      #
      # @param (see Pagerduty::EventsApiV1#trigger)
      # @option (see Pagerduty::EventsApiV1#trigger)
      def trigger(description, options = {})
        raise ArgumentError, "incident_key provided" if options.key?(:incident_key)

        options = options.merge(description: description)
        options[:incident_key] = @incident_key unless @incident_key.nil?
        response = api_call("trigger", options)
        @incident_key = response["incident_key"]
        self
      end

      # Acknowledge the referenced incident. While an incident is acknowledged,
      # it won't generate any additional notifications, even if it receives new
      # trigger events. Send PagerDuty an acknowledge event when you know
      # someone is presently working on the problem.
      #
      # @example Acknowledge the incident
      #   incident.acknowledge
      #
      # @example Acknowledge, providing a description and extra details
      #   incident.acknowledge(
      #     "Engineers are investigating the incident",
      #     {
      #       ping_time: "1700ms",
      #       load_avg:  0.71,
      #     }
      #   )
      #
      # @param [String] description Text that will appear in the incident's log
      #   associated with this event.
      #
      # @param [Hash] details An arbitrary hash containing any data you'd like
      #   included in the incident log.
      #
      # @return [Pagerduty::EventsApiV1::Incident] self
      #
      # @raise [PagerdutyException] If PagerDuty responds with a status that is
      #   not "success"
      #
      def acknowledge(description = nil, details = nil)
        modify_incident("acknowledge", description, details)
      end

      # Resolve the referenced incident. Once an incident is resolved, it won't
      # generate any additional notifications. New trigger events with the same
      # incident_key as a resolved incident won't re-open the incident. Instead,
      # a new incident will be created. Send PagerDuty a resolve event when the
      # problem that caused the initial trigger event has been fixed.
      #
      # @example Resolve the incident
      #   incident.resolve
      #
      # @example Resolve, providing a description and extra details
      #   incident.resolve(
      #     "A fix has been deployed and the service has recovered",
      #     {
      #       ping_time: "130ms",
      #       load_avg:  0.23,
      #     }
      #   )
      #
      # @param [String] description Text that will appear in the incident's log
      #   associated with this event.
      #
      # @param [Hash] details An arbitrary hash containing any data you'd like
      #   included in the incident log.
      #
      # @return [Pagerduty::EventsApiV1::Incident] self
      #
      # @raise [PagerdutyException] If PagerDuty responds with a status that is
      #   not "success"
      #
      def resolve(description = nil, details = nil)
        modify_incident("resolve", description, details)
      end

      private

      def modify_incident(event_type, description, details)
        options = { incident_key: incident_key }
        options[:description] = description if description
        options[:details] = details if details
        api_call(event_type, options)
        self
      end

      def api_call(event_type, args)
        args = args.merge(
          service_key: @integration_key,
          event_type:  event_type,
        )
        response = @transport.send_payload(args)
        raise PagerdutyException.new(self, response, response["message"]) unless response["status"] == "success"

        response
      end
    end
  end
end

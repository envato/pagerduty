# frozen_string_literal: true

# This file contains patches to provide backwards compatibility with version 2
# of the pagerduty gem. On the release of the next major version (4.0) it will
# be deleted, thus breaking backwards compatibility.

PagerdutyIncident = Pagerduty::EventsApiV1::Incident

Pagerduty::EventsApiV1::Incident.class_eval do
  def service_key
    @integration_key
  end
end

Pagerduty::EventsApiV1.class_eval do
  def service_key
    @config[:integration_key]
  end
end

Pagerduty.class_eval do
  def self.new(service_key, options = {})
    build(
      integration_key: service_key,
      api_version:     "1",
      http_proxy:      {
        host:     options[:proxy_host],
        port:     options[:proxy_port],
        username: options[:proxy_username],
        password: options[:proxy_password],
      },
    )
  end
end

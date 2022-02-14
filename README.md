# pagerduty

[![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/envato/pagerduty/blob/HEAD/LICENSE.txt)
[![Gem Version](https://img.shields.io/gem/v/pagerduty.svg?maxAge=2592000)](https://rubygems.org/gems/pagerduty)
[![Gem Downloads](https://img.shields.io/gem/dt/pagerduty.svg?maxAge=2592000)](https://rubygems.org/gems/pagerduty)
[![Build Status](https://github.com/envato/pagerduty/workflows/build/badge.svg?branch=main)](https://github.com/envato/pagerduty/actions?query=workflow%3Abuild+branch%3Amain)

Provides a lightweight Ruby interface for calling the [PagerDuty Events
API][events-v2-docs].

[events-v2-docs]: https://developer.pagerduty.com/docs/ZG9jOjExMDI5NTgw-events-api-v2-overview

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pagerduty'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pagerduty

## Usage

First, obtain an Events API integration key from PagerDuty. Follow the
[instructions][integration-key-documentation] in PagerDuty's documentation to
procure one.

[integration-key-documentation]: https://support.pagerduty.com/docs/services-and-integrations#create-a-generic-events-api-integration


### Events API V2

```ruby
# Instantiate a Pagerduty service object providing an integration key and the
# desired API version: 2
pagerduty = Pagerduty.build(
  integration_key: "<integration-key>",
  api_version:     2
)

# Trigger an incident providing minimal details
incident = pagerduty.trigger(
  summary:  "summary",
  source:   "source",
  severity: "critical"
)

# Trigger an incident providing full context
incident = pagerduty.trigger(
  summary:        "Example alert on host1.example.com",
  source:         "monitoringtool:cloudvendor:central-region-dc-01:852559987:cluster/api-stats-prod-003",
  severity:       %w[critical error warning info].sample,
  timestamp:      Time.now,
  component:      "postgres",
  group:          "prod-datapipe",
  class:          "deploy",
  custom_details: {
                    ping_time: "1500ms",
                    load_avg:  0.75
                  },
  images:         [
                    {
                      src:  "https://www.pagerduty.com/wp-content/uploads/2016/05/pagerduty-logo-green.png",
                      href: "https://example.com/",
                      alt:  "Example text",
                    },
                  ],
  links:          [
                    {
                      href: "https://example.com/",
                      text: "Link text",
                    },
                  ],
  client:         "Sample Monitoring Service",
  client_url:     "https://monitoring.example.com"
)

# Acknowledge and/or resolve the incident
incident.acknowledge
incident.resolve

# Provide a client-defined incident key
# (this can be used to update existing incidents)
incident = pagerduty.incident("<incident-key>")
incident.trigger(
  summary:  "summary",
  source:   "source",
  severity: "critical"
)
incident.acknowledge
incident.resolve
```

See the [PagerDuty Events API V2 documentation][events-v2-docs] for a
detailed description on the parameters you can send when triggering an
incident.

### Events API V1

The following code snippet shows how to use the [Pagerduty Events API version
1](https://v2.developer.pagerduty.com/docs/events-api).

```ruby
# Instantiate a Pagerduty with a service integration key
pagerduty = Pagerduty.build(
  integration_key: "<integration-key>",
  api_version:     1,
)

# Trigger an incident
incident = pagerduty.trigger(
  "FAILURE for production/HTTP on machine srv01.acme.com",
)

# Trigger an incident providing context and details
incident = pagerduty.trigger(
  "FAILURE for production/HTTP on machine srv01.acme.com",
  client:     "Sample Monitoring Service",
  client_url: "https://monitoring.service.com",
  contexts:   [
    {
      type: "link",
      href: "http://acme.pagerduty.com",
      text: "View the incident on PagerDuty",
    },
    {
      type: "image",
      src:  "https://chart.googleapis.com/chart?chs=600x400&chd=t:6,2,9,5,2,5,7,4,8,2,1&cht=lc&chds=a&chxt=y&chm=D,0033FF,0,0,5,1",
    }
  ],
  details:    {
    ping_time: "1500ms",
    load_avg:  0.75,
  },
)

# Acknowledge the incident
incident.acknowledge

# Acknowledge, providing a description and extra details
incident.acknowledge(
  "Engineers are investigating the incident",
  {
    ping_time: "1700ms",
    load_avg:  0.71,
  }
)

# Resolve the incident
incident.resolve

# Resolve, providing a description and extra details
incident.acknowledge(
  "A fix has been deployed and the service has recovered",
  {
    ping_time: "120ms",
    load_avg:  0.23,
  }
)

# Provide a client defined incident key
# (this can be used to update existing incidents)
incident = pagerduty.incident("<incident-key>")
incident.trigger("Description of the event")
incident.acknowledge
incident.resolve
```

See the [PagerDuty Events API V1
documentation](https://v2.developer.pagerduty.com/docs/trigger-events) for a
detailed description of the parameters you can send when triggering an
incident.

### HTTP Proxy Support

One can explicitly define an HTTP proxy like this:

```ruby
pagerduty = Pagerduty.build(
  integration_key: "<integration-key>",
  api_version:     2, # The HTTP proxy settings work with either API version
  http_proxy:      {
    host:     "my.http.proxy.local",
    port:     3128,
    username: "<my-proxy-username>",
    password: "<my-proxy-password>",
  }
)

# Subsequent API calls will then be sent via the HTTP proxy
incident = pagerduty.trigger(
  summary:  "summary",
  source:   "source",
  severity: "critical"
)
```

### Debugging Error Responses

The gem doesn't encapsulate HTTP error responses from PagerDuty. Here's how to
go about debugging these unhappy cases:

```ruby
begin
  pagerduty.trigger(
    summary:  "summary",
    source:   "source",
    severity: "critical"
  )
rescue Net::HTTPClientException => error
  error.response.code    #=> "400"
  error.response.message #=> "Bad Request"
  error.response.body    #=> "{\"status\":\"invalid event\",\"message\":\"Event object is invalid\",\"errors\":[\"Service key is the wrong length (should be 32 characters)\"]}"
end
```

## Contributing

1. Fork it ( https://github.com/envato/pagerduty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

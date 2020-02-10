# pagerduty


[![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/envato/pagerduty/blob/master/LICENSE.txt)
[![Gem Version](https://img.shields.io/gem/v/pagerduty.svg?maxAge=2592000)](https://rubygems.org/gems/pagerduty)
[![Gem Downloads](https://img.shields.io/gem/dt/pagerduty.svg?maxAge=2592000)](https://rubygems.org/gems/pagerduty)
[![Build Status](https://travis-ci.org/envato/pagerduty.svg?branch=master)](https://travis-ci.org/envato/pagerduty)

Provides a lightweight Ruby interface for calling the [PagerDuty
Events API](https://v2.developer.pagerduty.com/docs/events-api).

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

### Events API V1

The following code snippet shows how to use the [Pagerduty Events API version
1](https://v2.developer.pagerduty.com/docs/events-api).

```ruby
# Instantiate a Pagerduty with a service integration key
pagerduty = Pagerduty.build(
  integration_key: "<integration-key>",
  api_version:     "1",
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
incident = pagerduty.get_incident("<incident-key>")
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
  api_version:     "1",
  http_proxy:      {
    host:     "my.http.proxy.local",
    port:     3128,
    username: "<my-proxy-username>",
    password: "<my-proxy-password>",
  }
 )

# Subsequent API calls will then be sent via the HTTP proxy
pagerduty.trigger("incident description")
```

### Debugging Error Responses

The gem doesn't encapsulate HTTP error responses from PagerDuty. Here's how to
go about debugging these unhappy cases:

```ruby
begin
  pagerduty.trigger("incident description")
rescue Net::HTTPServerException => error
  error.response.code    #=> "400"
  error.response.message #=> "Bad Request"
  error.response.body    #=> "{\"status\":\"invalid event\",\"message\":\"Event object is invalid\",\"errors\":[\"Service key is the wrong length (should be 32 characters)\"]}"
end
```

### Legacy Interface

The older Ruby interface from version 2 of the gem is still available.
However, this is deprecated and will be removed in the next major release.

```ruby
# Instantiate a Pagerduty with your specific service key
pagerduty = Pagerduty.new("<my-integration-key>")

# Trigger an incident
incident = pagerduty.trigger("incident description")

# Acknowledge and resolve the incident
incident.acknowledge
incident.resolve
```

## Contributing

1. Fork it ( https://github.com/envato/pagerduty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

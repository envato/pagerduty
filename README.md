# pagerduty


[![License MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/envato/pagerduty/blob/master/LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/pagerduty.svg)](http://badge.fury.io/rb/pagerduty)
[![Build Status](https://travis-ci.org/envato/pagerduty.svg?branch=master)](https://travis-ci.org/envato/pagerduty)

Provides a lightweight Ruby interface for calling the [PagerDuty
Integration API](http://developer.pagerduty.com/documentation/integration/events).

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

```ruby
# Don't forget to require the library
require "pagerduty"

# Instantiate a Pagerduty with your specific service key
pagerduty = Pagerduty.new("<my-service-key>")

# Payload

payload = {
  summary: 'summary',
  source: 'source',
  severity: 'critical'
}

# Trigger an incident
incident = pagerduty.trigger(payload)

# Acknowledge and/or resolve the incident
incident.acknowledge
incident.resolve

# Acknowledge and/or resolve an existing incident
incident = pagerduty.get_incident("<unique-dedup-key>")
incident.acknowledge
incident.resolve
```

There are a whole bunch of properties you can send to PagerDuty when triggering
an incident. See the [PagerDuty
documentation](https://v2.developer.pagerduty.com/docs/trigger-events)
for the specifics.

### HTTP Proxy Support

One can explicitly define an HTTP proxy like this:

```ruby
# Instantiate a Pagerduty with your specific service key and proxy details
pagerduty = Pagerduty.new(
  "<my-service-key>",
  proxy_host: "my.http.proxy.local",
  proxy_port: 3128,
  proxy_username: "<my-proxy-username>",
  proxy_password: "<my-proxy-password>",
)

payload = {
  summary: 'summary',
  source: 'source',
  severity: 'critical'
}

# Then proceed to trigger your incident
# (sends the request to PagerDuty via the HTTP proxy)
incident = pagerduty.trigger(payload)
```

### Debugging Error Responses

The gem doesn't encapsulate HTTP error responses from PagerDuty. Here's how to
go about debugging these unhappy cases:

```ruby
payload = {
  summary: 'summary',
  source: 'source',
  severity: 'critical'
}

begin
  pagerduty.trigger(payload)
rescue Net::HTTPServerException => error
  error.response.code    #=> "400"
  error.response.message #=> "Bad Request"
  error.response.body    #=> "{\"status\":\"invalid event\",\"message\":\"Event object is invalid\",\"errors\":[\"Service key is the wrong length (should be 32 characters)\"]}"
end
```

### Upgrading to Version 2.0.0

The API has changed in three ways that you need to be aware of:

1. `Pagerduty` class initialiser no longer accepts an `incident_key`. This
attribute can now be provided when calling the `#trigger` method (see above).

2. `Pagerduty#trigger` arguments have changed to accept all available options
rather than just details.

    ```ruby
    # This no longer works post v2.0.0. If you're
    # providing details in this form, please migrate.
    pagerduty.trigger("desc", key: "value")

    # Post v2.0.0 this is how to send details (migrate to this please).
    pagerduty.trigger("desc", details: { key: "value" })
    ```

3. `PagerdutyException` now extends from `StandardError` rather than
`Exception`. This may affect how you rescue the error. i.e. `rescue
StandardError` will now rescue a `PagerdutyException` where it did not
before.

### Upgrading to Version 3.0.0

Notes: https://v2.developer.pagerduty.com/docs/trigger-events

1. `Pagerduty` class renamed the instance variable `service_key` to `routing_key`

2. `PagerdutyIncident` class renamed the instance variable `incident_key` to `dedup_key`

3. Both `Pagerduty` and `PagerdutyIncident` no longer require an `incident_key` to `trigger` an event.

4. `PagerdutyIncident` no longer accepts parameters, `description` and `details`, for methods `#acknowledge` and `#resolve`.

5. Both `Pagerduty` and `PagerdutyIncident` only accept an `options` hash for their `#trigger` methods. Below is all acceptable payload options, specified by Pagerduty:
    ```ruby
       pager = Pagerduty.new("xxx")

       payload = {
         summary: 'summary',
         source: 'source',
         severity: %w[critical error warning info].sample,
         timestamp: Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
         component: 'component',
         group: 'group',
         class: 'class',
         custom_details: {
             random: 'random'
         },
         images: [{
           src: "https://www.pagerduty.com/wp-content/uploads/2016/05/pagerduty-logo-green.png",
           href: "https://example.com/",
           alt: "Example text"
         }],
         links: [{
           href: "https://example.com/",
           text: "Link text"
         }],
         client: "Sample Monitoring Service",
         client_url: "https://monitoring.example.com"
       }

       event = pager.trigger(payload)
    ```
## Contributing

1. Fork it ( https://github.com/envato/pagerduty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

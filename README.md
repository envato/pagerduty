# pagerduty

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

# Trigger an incident
incident = pagerduty.trigger("incident description")

# Acknowledge and/or resolve the incident
incident.acknowledge
incident.resolve
```

There are a whole bunch of properties you can send to PagerDuty when triggering
an incident. See the [PagerDuty
documentation](http://developer.pagerduty.com/documentation/integration/events/trigger)
for the specifics.

```ruby
pagerduty.trigger(
  "incident description",
  :incident_key => "my unique incident identifier",
  :client       => "server in trouble",
  :client_url   => "http://server.in.trouble",
  :details      => { :my => "extra details" },
)
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
    pagerduty.trigger("desc", :key => "value")

    # Post v2.0.0 this is how to send details (migrate to this please).
    pagerduty.trigger("desc", :details => { :key => "value" })
    ```

3. `PagerdutyException` now extends from `StandardError` rather than
`Exception`. This may affect how you rescue the error. i.e. `rescue
StandardError` will now rescue a `PagerdutyException` where it did not
before.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pagerduty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

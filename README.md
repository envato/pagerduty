# pagerduty

[![Gem Version](https://badge.fury.io/rb/pagerduty.svg)](http://badge.fury.io/rb/pagerduty)
[![Build Status](https://travis-ci.org/envato/pagerduty.svg?branch=master)](https://travis-ci.org/envato/pagerduty)

Provides a ruby interface for integrating with the PagerDuty
[Integration API](http://developer.pagerduty.com/documentation/integration/events).

## Installation

Add this line to your application's Gemfile:

    gem 'pagerduty'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pagerduty

## Usage

```ruby
# Don't forget to require the library
require "pagerduty"

# Instantiate a Pagerduty with your specific servce key
pagerduty = Pagerduty.new("<my-service-key>")

# Trigger an incident
incident = pagerduty.trigger("incident description")

# Acknowledge and/or resolve the incident
incident.acknowledge
incident.resolve
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pagerduty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

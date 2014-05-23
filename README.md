# pagerduty

[![Gem Version](https://badge.fury.io/rb/pagerduty.svg)](http://badge.fury.io/rb/pagerduty)
[![Build Status](https://travis-ci.org/envato/pagerduty.svg?branch=master)](https://travis-ci.org/envato/pagerduty)

Provides a simple interface for calling into the [Pagerduty](http://pagerduty.com) API.

## Installation

Add this line to your application's Gemfile:

    gem 'pagerduty'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pagerduty

## Usage

Pagerduty exposes three classes, `Pagerduty`, `PagerdutyIncident` and `PagerdutyException`. Instances of `PagerdutyIncident` are created and returned for every API call.

`Pagerduty`'s constructor takes 2 arguments - your `service_key` and an optional argument to set the 'incident_key' You can then use the method `trigger` to trigger a new incident with Pagerduty:

    require 'pagerduty'
    p = Pagerduty.new "your_pagerduty_service_key"
    incident = p.trigger "Everything went down!"

Incidents can be retriggered, acknowledged with the `PagerdutyIncident#acknowledge` method, and resolved with `PagerdutyIncident#resolve`.

Additionally, all API methods (`trigger`, `acknowledge`, `resolve`) take an optional second parameter `details`, which should be a hash containing any extra information that should be recorded with Pagerduty.

If the Pagerduty API does not return success, a `PagerdutyException` will be thrown which has the properties `pagerduty_instance` (the instance of either `Pagerduty` or `PagerdutyException` that caused the exception) and `api_response`, which is a hash representation of the JSON response from the Pagerduty API.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pagerduty/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

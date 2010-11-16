pagerduty
=========

Provides a simple interface for calling into the [Pagerduty](http://pagerduty.com) API.

Installation
------------

Install pagerduty with this command:

    gem install pagerduty

Usage
-----

Pagerduty exposes three classes, `Pagerduty`, `PagerdutyIncident` and `PagerdutyException`. Instances of `PagerdutyIncident` are created and returned for every API call.

`Pagerduty`'s constructor takes a single argument - your `service_key`. You can then use the method `trigger` to trigger a new incident with Pagerduty:

    require 'pagerduty'
    p = Pagerduty.new "your_pagerduty_service_key"
    incident = p.trigger "Everything went down!"

Incidents can be retriggered, acknowledged with the `PagerdutyIncident#acknowledge` method, and resolved with `PagerdutyIncident#resolve`.

Additionally, all API methods (`trigger`, `acknowledge`, `resolve`) take an optional second parameter `details`, which should be a hash containing any extra information that should be recorded with Pagerduty.

If the Pagerduty API does not return success, a `PagerdutyException` will be thrown which has the properties `pagerduty_instance` (the instance of either `Pagerduty` or `PagerdutyException` that caused the exception) and `api_response`, which is a hash representation of the JSON response from the Pagerduty API.

Copyright
---------

Copyright (c) 2010 [Envato](http://envato.com) & [Charlie Somerville](http://charliesomerville.com). See LICENSE.txt for further details.


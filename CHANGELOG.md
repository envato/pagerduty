# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to
[Semantic Versioning].

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

[Unreleased]: https://github.com/envato/pagerduty/compare/v4.0.1...HEAD

## [4.0.1] - 2024-02-17

### Added

- Test on Ruby 3.2, and 3.3 in the CI build ([#84], [#85]).

### Changed

- Updated authorship details ([#82]).
- Bump the Rubocop development dependency to version 1 ([#86]).

[4.0.1]: https://github.com/envato/pagerduty/compare/v4.0.0...v4.0.1
[#82]: https://github.com/envato/pagerduty/pull/82
[#84]: https://github.com/envato/pagerduty/pull/84
[#85]: https://github.com/envato/pagerduty/pull/85
[#86]: https://github.com/envato/pagerduty/pull/86

## [4.0.0] - 2022-02-14

### Removed

- Remove support for Ruby versions lower than 2.3 ([#78]).

- Removed the deprecated way of creating a Pagerduty instance ([#79]).

  ```diff
  - pagerduty = Pagerduty.new("<integration-key>")
  + pagerduty = Pagerduty.build(integration_key: "<integration-key>", api_version: 1)
  pagerduty.trigger("<incident description>")
  incident.acknowledge
  incident.resolve
  ```

- Removed the deprecated `get_incident` and `service_key` methods from the
  `Pagerduty::EventsApiV1::Incident` class ([#79]). `incident` provides a replacement
  for the `get_incident` method. The `service_key` method has no replacement.

  ```diff
  pagerduty = Pagerduty.build(integration_key: "<integration-key>", api_version: 1)
  - incident = pagerduty.get_incident("<incident-key>")
  + incident = pagerduty.incident("<incident-key>")
  incident.trigger("<incident description>")
  incident.acknowledge
  incident.resolve
  ```

- Removed the `PagerdutyIncident` class. Instead, use the
  `Pagerduty::EventsApiV1::Incident` class ([#79]).

### Added

- Test on Ruby 3.0 and 3.1 in CI build ([#74], [#80]).

### Changed

- The explicit `json` gem runtime dependency has been removed ([#78]).
- Use GitHub Actions for CI build instead of TravisCI ([#73]).
- The default git branch has been renamed to `main` ([#77]).

### Fixed

- Resolved `Net::HTTPServerException` deprecation warning in test suite([#75]).

[4.0.0]: https://github.com/envato/pagerduty/compare/v3.0.0...v4.0.0
[#73]: https://github.com/envato/pagerduty/pull/73
[#74]: https://github.com/envato/pagerduty/pull/74
[#75]: https://github.com/envato/pagerduty/pull/75
[#77]: https://github.com/envato/pagerduty/pull/77
[#78]: https://github.com/envato/pagerduty/pull/78
[#79]: https://github.com/envato/pagerduty/pull/79
[#80]: https://github.com/envato/pagerduty/pull/80

## [3.0.0] - 2020-04-20

### Added

- A new mechanism for instantiating a Pagerduty instance ([#64]).

  ```ruby
  pagerduty = Pagerduty.build(integration_key: "<my-integration-key>",
                              api_version:     1)
  ```

  This new method will return an instance that implements requested PagerDuty
  Events API version.

- Support for the [Pagerduty Events API version 2][events-v2-docs] ([#66]).

  ```ruby
  pagerduty = Pagerduty.build(
    integration_key: "<my-integration-key>",
    api_version:     2
  )
  incident = pagerduty.trigger(
    summary:  "summary",
    source:   "source",
    severity: "critical"
  )
  incident.acknowledge
  incident.resolve
  ```

- Added an `incident` method to the Pagerduty Events API V1 instance ([#67]).
  This is intended as a drop-in replacement for the now-deprecated
  `get_incident` method.

  ```ruby
  pagerduty = Pagerduty.build(
    integration_key: "<integration-key>",
    api_version:     1
  )
  incident = pagerduty.incident("<incident-key>")
  ```

### Deprecated

- Using `new` on `Pagerduty` ([#64]). This works, but will be removed in the
  next major version.

  ```diff
  - pagerduty = Pagerduty.new("<integration-key>")
  + pagerduty = Pagerduty.build(integration_key: "<integration-key>", api_version: 1)
  pagerduty.trigger("<incident description>")
  incident.acknowledge
  incident.resolve
  ```

  Instead, use the new `Pagerduty.build` method (see above).

- The `get_incident` method is now deprecated ([#67]). It still works, but
  will be removed in the next major release. Please migrate to the new
  `incident` method, that works in exactly the same way.

  ```diff
  pagerduty = Pagerduty.new("<integration-key>")
  - incident = pagerduty.get_incident("<incident-key>")
  + incident = pagerduty.incident("<incident-key>")
  incident.trigger("<incident description>")
  incident.acknowledge
  incident.resolve
  ```

### Changed

- `Pagerduty` is no longer a class. It's now a Ruby module ([#64]). This will
  break implementations that use `Pagerduty` in their inheritance tree.

- `PagerdutyIncident` no-longer inherits from `Pagerduty` and its initializer
  parameters have changed ([#64]). Actually, it's now an alias of the
  `Pagerduty::EventsApiV1:Incident` class.

### Removed

- Can no longer specify a new incident key when triggering from an `Incident`
  object ([#64]).

  This will now raise an `ArgumentError`. eg.

  ```ruby
  incident1 = pagerduty.trigger('first incident', incident_key: 'one') # this'll work fine
  incident2 = incident1.trigger('second incident', incident_key: 'two') # this no-longer works.
  ```

  The difference is in the object we're calling the method on.

  Instead always use the pagerduty object when triggering new incidents (with
  new incident keys).

  This works with the Events API V1:

  ```ruby
  incident1 = pagerduty.trigger('first incident', incident_key: 'one')
  incident2 = pagerduty.trigger('second incident', incident_key: 'two')
  ```

  And this is even better, as it works with both the Events API V1 and V2:

  ```ruby
  incident1 = pagerduty.incident('one').trigger('first incident')
  incident2 = pagerduty.incident('two').trigger('second incident')
  ```

[3.0.0]: https://github.com/envato/pagerduty/compare/v2.1.3...v3.0.0
[events-v2-docs]: https://developer.pagerduty.com/docs/ZG9jOjExMDI5NTgw-events-api-v2-overview
[#64]: https://github.com/envato/pagerduty/pull/64
[#66]: https://github.com/envato/pagerduty/pull/66
[#67]: https://github.com/envato/pagerduty/pull/67

## [2.1.3] - 2020-02-10

### Added

- Test against Ruby 2.6 and 2.7 in CI ([#55], [#63]).

- Add project metadata to the gemspec ([#57]).

- A downloads badge to the readme ([#58]).

- This changelog document ([#59]).

### Fixed

- Realign with latest Rubocop style ([#54], [#62]).

### Removed

- Test files are no longer included in the gem file ([#60]).

[2.1.3]: https://github.com/envato/pagerduty/compare/v2.1.2...v2.1.3
[#54]: https://github.com/envato/pagerduty/pull/54
[#55]: https://github.com/envato/pagerduty/pull/55
[#57]: https://github.com/envato/pagerduty/pull/57
[#58]: https://github.com/envato/pagerduty/pull/58
[#59]: https://github.com/envato/pagerduty/pull/59
[#60]: https://github.com/envato/pagerduty/pull/60
[#62]: https://github.com/envato/pagerduty/pull/62
[#63]: https://github.com/envato/pagerduty/pull/63

## [2.1.2] - 2018-09-18

### Fixed

- Remove leading and trailing whitespace in the gem post-install message
  ([#53]).

- Realign with latest Rubocop style ([#53]).

- Update the links to Pagerduty official API documentation.

- Don't specify Ruby patch versions in Travis CI build configuration. Remove
  the toil involved in keeping these up to date.

### Removed

- Remove gem post-install message.

[2.1.2]: https://github.com/envato/pagerduty/compare/v2.1.1...v2.1.2
[#53]: https://github.com/envato/pagerduty/pull/53

## [2.1.1] - 2018-03-06

### Added

- Test against Ruby 2.4 and 2.5 in CI ([#51]).

### Fixed

- Removed version restrictions on the `rubocop` development dependency, and
  realigned code with the latest version. ([#51]).

### Removed

- Ruby 1.9.3 and Ruby 2.0.0 from the CI build ([#51]).

[2.1.1]: https://github.com/envato/pagerduty/compare/v2.1.0...v2.1.1
[#51]: https://github.com/envato/pagerduty/pull/51

## [2.1.0] - 2016-01-19

### Added

- Rubocop configuration and align syntax ([#32], [#35], [#38], [#43]).

- Documentation describing how to resolve an existing incident ([#34]).

- Print Ruby warnings during the CI build ([#36]).

- Remove restrictions on `bundler` development dependency ([#37]).

- Test against Ruby 2.3 in CI ([#41]).

- Add support for HTTP proxy ([#47]).

### Fixed

- `Pagerduty#get_incident` raises `ArgumentError` if the provided incident key
  is `nil` ([#46]).

[2.1.0]: https://github.com/envato/pagerduty/compare/v2.0.1...v2.1.0
[#32]: https://github.com/envato/pagerduty/pull/32
[#34]: https://github.com/envato/pagerduty/pull/34
[#35]: https://github.com/envato/pagerduty/pull/35
[#36]: https://github.com/envato/pagerduty/pull/36
[#37]: https://github.com/envato/pagerduty/pull/37
[#38]: https://github.com/envato/pagerduty/pull/38
[#41]: https://github.com/envato/pagerduty/pull/41
[#43]: https://github.com/envato/pagerduty/pull/43
[#46]: https://github.com/envato/pagerduty/pull/46
[#47]: https://github.com/envato/pagerduty/pull/47

## [2.0.1] - 2015-03-29

### Added

- Moved specs to RSpec 3.0 ([#30]).

- Test against Ruby 2.2 in CI ([#31]).

### Changed

- Rename `HttpTransport#send` to `httpTransport#send_payload`. This avoids
  shawdowing `Object#send` ([#29]).

[2.0.1]: https://github.com/envato/pagerduty/compare/v2.0.0...v2.0.1
[#29]: https://github.com/envato/pagerduty/pull/29
[#30]: https://github.com/envato/pagerduty/pull/30
[#31]: https://github.com/envato/pagerduty/pull/31

## [2.0.0] - 2014-05-26

### Added

 - The `description` argument in the `PagerdutyIncident#acknowledge` and
   `PagerdutyIncident#resolve` methods is now optional. As specified by the
   API ([#19]).

 - YARD class and method documentation. In addition to updating the readme
   ([#20]).

### Changed

- `Pagerduty#trigger` arguments have changed to accept all available options
  provided by the API, rather than just `details` ([#19]).

    ```ruby
    pagerduty.trigger(
      "incident description",
      incident_key: "my unique incident identifier",
      client:       "server in trouble",
      client_url:   "http://server.in.trouble",
      details:      {my: "extra details"},
    )
    ```

  This is breaking in the case where providing a `details` hash:

    ```ruby
    # This no longer works post v2.0.0. If you're
    # providing details in this form, please migrate.
    pagerduty.trigger("desc", key: "value")

    # Post v2.0.0 this is how to send details (migrate to this please).
    pagerduty.trigger("desc", details: {key: "value"})
    ```

- `Pagerduty` class initialiser no longer accepts an `incident_key`. This
  attribute can now be provided when calling the `#trigger` method (see above)
  ([#19]).

- `PagerdutyException` now extends from `StandardError` rather than
  `Exception`. This may affect how you rescue the error. i.e. `rescue
  StandardError` will now rescue a `PagerdutyException` where it did not
  before ([#21]).

[2.0.0]: https://github.com/envato/pagerduty/compare/v1.4.1...v2.0.0
[#19]: https://github.com/envato/pagerduty/pull/19
[#20]: https://github.com/envato/pagerduty/pull/20
[#21]: https://github.com/envato/pagerduty/pull/21

## [1.4.1] - 2014-05-21

### Added

- Set HTTP open and read timeouts to 60 seconds ([#16]).

- Add tests and a CI build (TravisCI) ([#17]).

- Add `bundler`, `rake` and `rspec-given` as development dependencies ([#17]).

- Extract (private) `HttpTransport` class, for single responsibility and ease
  of testing ([#18]).

### Changed

- Raise errors instead of throwing them ([#17]).

### Fixed

- Use the OS default `CA path` rather than explicitly setting one ([#18]).

[1.4.1]: https://github.com/envato/pagerduty/compare/v1.4.0...v1.4.1
[#16]: https://github.com/envato/pagerduty/pull/16
[#17]: https://github.com/envato/pagerduty/pull/17
[#18]: https://github.com/envato/pagerduty/pull/18

## [1.4.0] - 2014-04-02

### Added

- Support TLS to the Pagerduty API ([#14]).

[1.4.0]: https://github.com/envato/pagerduty/compare/v1.3.4...v1.4.0
[#14]: https://github.com/envato/pagerduty/pull/14

## [1.3.4] - 2013-02-12

### Fixed

- Update `Rakefile` to word with recent versions of RDoc

### Changed

- Enforce `json` gem to versions 1.7.7 and above.

[1.3.4]: https://github.com/envato/pagerduty/compare/v1.3.3...v1.3.4

## [1.3.3] - 2012-12-12

### Changed

- Allow `json` gem versions 1.5 and above.

[1.3.3]: https://github.com/envato/pagerduty/compare/v1.3.2...v1.3.3

## [1.3.2] - 2012-10-31

### Fixed

- `details` are now correctly passed in the API call.

[1.3.2]: https://github.com/envato/pagerduty/compare/v1.3.1...v1.3.2

## [1.3.1] - 2012-10-19

### Fixed

- Consolidated all Pagerduty definitions to be a `class`.

[1.3.1]: https://github.com/envato/pagerduty/compare/v1.3.0...v1.3.1

## [1.3.0] - 2012-10-18

### Added

- Add ability to set the incident key via the initializer.

### Changed

- Perform release with `bundler` instead of `jeweller`.
- Manage all gem dependencies in the gemspec file.
- Remove dependency on `curb`.

[1.3.0]: https://github.com/envato/pagerduty/compare/v1.1.1...v1.3.0

## [1.1.1] - 2010-11-17

### Fixed

- Specify `json` and `curb` gems as dependencies in the default gem group.

### Added

- Prevent the `.bundle` directory from being added to the git repository.

[1.1.1]: https://github.com/envato/pagerduty/compare/v1.1.0...v1.1.1

## [1.1.0] - 2010-11-16

### Added

- New `Pagerduty#get_incident` method.

[1.1.0]: https://github.com/envato/pagerduty/compare/v1.0.1...v1.1.0

## [1.0.1] - 2010-11-16

### Fixed

- Specify `json` and `curb` gems as dependencies.

[1.0.1]: https://github.com/envato/pagerduty/compare/v1.0.0...v1.0.1

## [1.0.0] - 2010-11-16

### Added

- Library released as Open Source!

[1.0.0]: https://github.com/envato/pagerduty/releases/tag/v1.0.0

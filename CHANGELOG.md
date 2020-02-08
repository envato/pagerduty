# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to
[Semantic Versioning].

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

### Added

- Test against Ruby 2.6 and 2.7 in CI ([#55], [#63]).

- Add project metadata to the gemspec ([#57]).

- A downloads badge to the readme ([#58]).

- This changelog document ([#59]).

### Fixed

- Realign with latest Rubocop style ([#54], [#62]).

### Removed

- Test files are no longer included in the gem file ([#60]).

[Unreleased]: https://github.com/envato/pagerduty/compare/v2.1.2...HEAD
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

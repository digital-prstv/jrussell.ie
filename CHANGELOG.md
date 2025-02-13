# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- 🔧 chore(ci): update CircleCI configuration for IAC deployment(pr [#70])
- 👷 ci(circleci): update CircleCI configuration for modular workflow(pr [#71])

## [1.1.1] - 2025-02-12

### Changed

- 🔧 chore(gitmodules): update submodule configuration(pr [#64])
- ✨ feat(config): update configuration settings to support webmentions(pr [#66])
- 👷 ci(circleci): update orb versions(pr [#67])

### Security

- Dependencies: update dependency aws-cli to v5.2.0(pr [#65])

## [1.1.0] - 2025-02-05

### Added

- Rebuild with tabi theme(pr [#58])

### Changed

- ci(circleci)-remove fixed version from workflow configuration(pr [#55])
- chore-update zola orb version and remove build job from CircleCI config(pr [#56])
- chore-update build-site recipe to sync and update submodules(pr [#57])
- 🔧 chore(circleci): update circleci-toolkit orb version(pr [#61])

### Security

- Dependencies: update dependency zola to v1.2.2(pr [#60])
- ✨ feat(blog): add technology series(pr [#59])
- Dependencies: update cimg/base docker tag to v2025.02(pr [#62])
- Dependencies: update dependency aws-cli to v5.1.3(pr [#63])

## [1.0.0] - 2025-01-14

### Added

- add output_directory parameter for custom build directory(pr [#54])

### Changed

- ci-add AWS configuration path to cache paths in CircleCI config(pr [#44])
- ci-remove branch filters from CircleCI config(pr [#46])
- ci(circleci)-reorder jobs and remove unnecessary workspace persistence(pr [#47])
- ci-update CircleCI config to add end_success step for main branch only(pr [#48])
- ci(circleci)-update workflow dependencies from authorise_aws to zola/build(pr [#50])
- ci(circleci)-remove unnecessary checkout step in deploy job(pr [#51])
- chore(ci)-update CircleCI config to use aws-cli executor(pr [#52])
- ci(circleci)-refactor build and deployment jobs, deprecate zola orb usage(pr [#53])

### Fixed

- circleci: update job dependencies in config file(pr [#49])

[#44]: https://github.com/digital-prstv/jrussell.ie/pull/44
[#46]: https://github.com/digital-prstv/jrussell.ie/pull/46
[#47]: https://github.com/digital-prstv/jrussell.ie/pull/47
[#48]: https://github.com/digital-prstv/jrussell.ie/pull/48
[#49]: https://github.com/digital-prstv/jrussell.ie/pull/49
[#50]: https://github.com/digital-prstv/jrussell.ie/pull/50
[#51]: https://github.com/digital-prstv/jrussell.ie/pull/51
[#52]: https://github.com/digital-prstv/jrussell.ie/pull/52
[#53]: https://github.com/digital-prstv/jrussell.ie/pull/53
[#54]: https://github.com/digital-prstv/jrussell.ie/pull/54
[#55]: https://github.com/digital-prstv/jrussell.ie/pull/55
[#56]: https://github.com/digital-prstv/jrussell.ie/pull/56
[#57]: https://github.com/digital-prstv/jrussell.ie/pull/57
[#58]: https://github.com/digital-prstv/jrussell.ie/pull/58
[#59]: https://github.com/digital-prstv/jrussell.ie/pull/59
[#60]: https://github.com/digital-prstv/jrussell.ie/pull/60
[#61]: https://github.com/digital-prstv/jrussell.ie/pull/61
[#62]: https://github.com/digital-prstv/jrussell.ie/pull/62
[#63]: https://github.com/digital-prstv/jrussell.ie/pull/63
[#64]: https://github.com/digital-prstv/jrussell.ie/pull/64
[#65]: https://github.com/digital-prstv/jrussell.ie/pull/65
[#66]: https://github.com/digital-prstv/jrussell.ie/pull/66
[#67]: https://github.com/digital-prstv/jrussell.ie/pull/67
[#70]: https://github.com/digital-prstv/jrussell.ie/pull/70
[#71]: https://github.com/digital-prstv/jrussell.ie/pull/71
[Unreleased]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.1...HEAD
[1.1.1]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/digital-prstv/jrussell.ie/releases/tag/v1.0.0

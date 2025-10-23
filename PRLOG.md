# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2025-10-23

### Added

- ✨ add serve-ip and serve-ip-no-draft commands(pr [#160])

### Changed

- 💄 style(cull-gmail)-correct typo in dry-run mode description(pr [#158])
- 📝 docs(blog)-add blog post about the Irish presidential election(pr [#161])

### Security

- Dependencies: update dependency toolkit to v2.13.5(pr [#159])

## [1.3.0] - 2025-10-17

### Added

- ✨ add documentation for cull-gmail project(pr [#157])

### Security

- Dependencies: update dependency toolkit to v2.13.2(pr [#152])
- Dependencies: update dependency toolkit to v2.13.4(pr [#153])
- Dependencies: update cimg/base docker tag to v2025.10(pr [#155])
- Dependencies: update dependency path-filtering to v2.1.0(pr [#156])

## [1.2.0] - 2025-09-23

### Added

- ✨ add gen-changelog project documentation(pr [#150])

### Changed

- 📝 docs(blog)-add description to influences post(pr [#134])
- 📝 docs(blog)-update description and fix typos in blog post(pr [#135])
- 📝 docs(blog)-add description to introduction post(pr [#136])
- 💄 style(blog)-correct grammatical errors in introduction(pr [#137])
- 📝 docs(blog)-update blog post title and add description(pr [#138])
- 📝 docs(blog)-update blog description and correct grammar(pr [#139])
- 📝 docs(blog)-add description to update-and-release post(pr [#140])
- 📝 docs(blog)-add overview of workflow blog post(pr [#141])
- 🔧 chore(ci)-update pcu configuration in release workflow(pr [#151])

### Security

- Dependencies: update cimg/base docker tag to v2025.08(pr [#143])
- Dependencies: update dependency terraform to v3.7.0(pr [#144])
- Dependencies: update dependency path-filtering to v2.0.3(pr [#145])
- Dependencies: update dependency path-filtering to v2.0.4(pr [#146])
- Dependencies: update cimg/base docker tag to v2025.09(pr [#147])
- Dependencies: update dependency toolkit to v2.13.0 - abandoned(pr [#148])

## [1.1.9] - 2025-07-28

### Changed

- 🔧 chore(ci)-remove obsolete SSH check job from CircleCI config(pr [#133])

## [1.1.8] - 2025-07-28

### Changed

- 📝 docs(blog)-update DeepSeek series description(pr [#131])
- 📝 docs(blog)-update blog description for clarity(pr [#132])
- 🔧 chore(ci)-remove obsolete SSH check job from CircleCI config(pr [#133])

## [1.1.7] - 2025-07-25

### Changed

- 🔧 chore(githooks): add pre-commit hook script(pr [#81])
- 👷 ci(circleci)-update toolkit orb version(pr [#84])
- 👷 ci(circleci)-update toolkit orb version(pr [#85])
- 🔧 chore(ci)-separate deploy-iac workflow into its own file(pr [#86])
- 👷 ci(circleci)-add IaC validation pipeline(pr [#87])
- 👷 ci(circleci)-add bluesky toolkit configuration to workflows(pr [#88])
- 📝 docs(blog)-add new blog posts on DeepMind conversation(pr [#89])
- 🔧 chore(ci)-separate release website workflow configuration(pr [#91])
- 👷 ci(circleci)-update release workflow dependencies(pr [#92])
- 👷 ci(circleci)-remove unused parameters from release_website.yml(pr [#93])
- 🔧 chore(ci)-update toolkit orb version in CircleCI config(pr [#94])
- 🔧 chore(ci)-remove unnecessary rust version parameter(pr [#95])
- 👷 ci(circleci)-update circleci-toolkit orb version(pr [#96])
- 👷 ci(circleci)-enable bluesky job in release workflow(pr [#97])
- 👷 ci(circleci)-enhance verbosity for release workflow(pr [#98])
- 👷 ci(circleci)-add bluesky commands and pcu installation(pr [#99])
- 👷 ci(circleci)-update cargo installation command(pr [#100])
- 👷 ci(circleci)-update toolkit orb version(pr [#101])
- 🔧 chore(ci)-remove commented out bluesky commands(pr [#102])
- 👷 ci(circleci)-add when_update_pcu parameter to release workflow(pr [#103])
- 👷 ci(circleci)-add pcu-app context to release workflow(pr [#104])
- 👷 ci(circleci)-update release_website workflow(pr [#105])
- 🔧 chore(ci)-update SSH verification steps in release workflow(pr [#106])
- 🔧 chore(blog)-update tags and references from deepmind to deepseek(pr [#117])
- 👷 ci(circleci)-update toolkit orb version to 2.11.0(pr [#118])
- 🔧 chore(blog)-rename deepmind to deepseek(pr [#120])
- 📝 docs(blog)-add guide on integrating AI in project management(pr [#125])
- 📝 docs(blog)-add new blog post on initial request to Claude(pr [#126])

### Security

- Dependencies: update cimg/base docker tag to v2025.03(pr [#82])
- Dependencies: update dependency aws-cli to v5.3.1(pr [#90])
- Dependencies: update dependency aws-cli to v5.3.2(pr [#107])
- Dependencies: update dependency path-filtering to v1.3.0(pr [#108])
- Dependencies: update cimg/base docker tag to v2025.05(pr [#109])
- Dependencies: update dependency aws-cli to v5.3.3(pr [#110])
- Dependencies: update dependency path-filtering to v2(pr [#111])
- Dependencies: update dependency aws-cli to v5.3.4(pr [#112])
- Dependencies: update dependency aws-cli to v5.3.5(pr [#113])
- Dependencies: update cimg/base docker tag to v2025.06(pr [#114])
- Dependencies: update dependency aws-cli to v5.4.0(pr [#115])
- Dependencies: update dependency path-filtering to v2.0.1(pr [#116])
- Dependencies: update cimg/base docker tag to v2025.07(pr [#121])
- Dependencies: update dependency aws-cli to v5.4.1(pr [#122])
- Dependencies: update dependency toolkit to v2.12.1(pr [#123])

## [1.1.2] - 2025-02-20

### Changed

- 🔧 chore(ci): update CircleCI configuration for IAC deployment(pr [#70])
- 👷 ci(circleci): update CircleCI configuration for modular workflow(pr [#71])
- 👷 ci(circleci): remove unused orbs and streamline workflows(pr [#73])
- ♻️ refactor(iac): modularize s3 bucket configuration(pr [#74])
- ♻️ refactor(iac): update S3 bucket configurations(pr [#75])
- 🐛 fix(sec-headers): comment out Content-Security-Policy header(pr [#76])
- 💄 style(resources): fix typo in CloudFront comment(pr [#77])
- ✨ feat(styles): add comprehensive SCSS structure for styling(pr [#79])
- Stuck(pr [#80])

### Security

- Dependencies: update dependency terraform to v3.6.0(pr [#78])

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
[#73]: https://github.com/digital-prstv/jrussell.ie/pull/73
[#74]: https://github.com/digital-prstv/jrussell.ie/pull/74
[#75]: https://github.com/digital-prstv/jrussell.ie/pull/75
[#76]: https://github.com/digital-prstv/jrussell.ie/pull/76
[#77]: https://github.com/digital-prstv/jrussell.ie/pull/77
[#78]: https://github.com/digital-prstv/jrussell.ie/pull/78
[#79]: https://github.com/digital-prstv/jrussell.ie/pull/79
[#80]: https://github.com/digital-prstv/jrussell.ie/pull/80
[#81]: https://github.com/digital-prstv/jrussell.ie/pull/81
[#82]: https://github.com/digital-prstv/jrussell.ie/pull/82
[#84]: https://github.com/digital-prstv/jrussell.ie/pull/84
[#85]: https://github.com/digital-prstv/jrussell.ie/pull/85
[#86]: https://github.com/digital-prstv/jrussell.ie/pull/86
[#87]: https://github.com/digital-prstv/jrussell.ie/pull/87
[#88]: https://github.com/digital-prstv/jrussell.ie/pull/88
[#89]: https://github.com/digital-prstv/jrussell.ie/pull/89
[#89]: https://github.com/digital-prstv/jrussell.ie/pull/89
[#89]: https://github.com/digital-prstv/jrussell.ie/pull/89
[#89]: https://github.com/digital-prstv/jrussell.ie/pull/89
[#91]: https://github.com/digital-prstv/jrussell.ie/pull/91
[#92]: https://github.com/digital-prstv/jrussell.ie/pull/92
[#93]: https://github.com/digital-prstv/jrussell.ie/pull/93
[#90]: https://github.com/digital-prstv/jrussell.ie/pull/90
[#94]: https://github.com/digital-prstv/jrussell.ie/pull/94
[#95]: https://github.com/digital-prstv/jrussell.ie/pull/95
[#96]: https://github.com/digital-prstv/jrussell.ie/pull/96
[#97]: https://github.com/digital-prstv/jrussell.ie/pull/97
[#98]: https://github.com/digital-prstv/jrussell.ie/pull/98
[#99]: https://github.com/digital-prstv/jrussell.ie/pull/99
[#100]: https://github.com/digital-prstv/jrussell.ie/pull/100
[#101]: https://github.com/digital-prstv/jrussell.ie/pull/101
[#102]: https://github.com/digital-prstv/jrussell.ie/pull/102
[#103]: https://github.com/digital-prstv/jrussell.ie/pull/103
[#104]: https://github.com/digital-prstv/jrussell.ie/pull/104
[#105]: https://github.com/digital-prstv/jrussell.ie/pull/105
[#106]: https://github.com/digital-prstv/jrussell.ie/pull/106
[#107]: https://github.com/digital-prstv/jrussell.ie/pull/107
[#108]: https://github.com/digital-prstv/jrussell.ie/pull/108
[#109]: https://github.com/digital-prstv/jrussell.ie/pull/109
[#110]: https://github.com/digital-prstv/jrussell.ie/pull/110
[#111]: https://github.com/digital-prstv/jrussell.ie/pull/111
[#112]: https://github.com/digital-prstv/jrussell.ie/pull/112
[#113]: https://github.com/digital-prstv/jrussell.ie/pull/113
[#114]: https://github.com/digital-prstv/jrussell.ie/pull/114
[#115]: https://github.com/digital-prstv/jrussell.ie/pull/115
[#116]: https://github.com/digital-prstv/jrussell.ie/pull/116
[#117]: https://github.com/digital-prstv/jrussell.ie/pull/117
[#118]: https://github.com/digital-prstv/jrussell.ie/pull/118
[#120]: https://github.com/digital-prstv/jrussell.ie/pull/120
[#121]: https://github.com/digital-prstv/jrussell.ie/pull/121
[#122]: https://github.com/digital-prstv/jrussell.ie/pull/122
[#123]: https://github.com/digital-prstv/jrussell.ie/pull/123
[#125]: https://github.com/digital-prstv/jrussell.ie/pull/125
[#126]: https://github.com/digital-prstv/jrussell.ie/pull/126
[#131]: https://github.com/digital-prstv/jrussell.ie/pull/131
[#132]: https://github.com/digital-prstv/jrussell.ie/pull/132
[#133]: https://github.com/digital-prstv/jrussell.ie/pull/133
[#134]: https://github.com/digital-prstv/jrussell.ie/pull/134
[#135]: https://github.com/digital-prstv/jrussell.ie/pull/135
[#136]: https://github.com/digital-prstv/jrussell.ie/pull/136
[#137]: https://github.com/digital-prstv/jrussell.ie/pull/137
[#138]: https://github.com/digital-prstv/jrussell.ie/pull/138
[#139]: https://github.com/digital-prstv/jrussell.ie/pull/139
[#140]: https://github.com/digital-prstv/jrussell.ie/pull/140
[#141]: https://github.com/digital-prstv/jrussell.ie/pull/141
[#143]: https://github.com/digital-prstv/jrussell.ie/pull/143
[#144]: https://github.com/digital-prstv/jrussell.ie/pull/144
[#145]: https://github.com/digital-prstv/jrussell.ie/pull/145
[#146]: https://github.com/digital-prstv/jrussell.ie/pull/146
[#147]: https://github.com/digital-prstv/jrussell.ie/pull/147
[#148]: https://github.com/digital-prstv/jrussell.ie/pull/148
[#150]: https://github.com/digital-prstv/jrussell.ie/pull/150
[#151]: https://github.com/digital-prstv/jrussell.ie/pull/151
[#152]: https://github.com/digital-prstv/jrussell.ie/pull/152
[#153]: https://github.com/digital-prstv/jrussell.ie/pull/153
[#155]: https://github.com/digital-prstv/jrussell.ie/pull/155
[#156]: https://github.com/digital-prstv/jrussell.ie/pull/156
[#157]: https://github.com/digital-prstv/jrussell.ie/pull/157
[#158]: https://github.com/digital-prstv/jrussell.ie/pull/158
[#159]: https://github.com/digital-prstv/jrussell.ie/pull/159
[#160]: https://github.com/digital-prstv/jrussell.ie/pull/160
[#161]: https://github.com/digital-prstv/jrussell.ie/pull/161
[1.4.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.9...v1.2.0
[1.1.9]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.8...v1.1.9
[1.1.8]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.7...v1.1.8
[1.1.7]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.2...v1.1.7
[1.1.2]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/digital-prstv/jrussell.ie/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/digital-prstv/jrussell.ie/releases/tag/v1.0.0

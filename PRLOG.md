# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- add blog post introducing gen-circleci-orb(pr [#224])

### Changed

- ci-GitHub Pages migration — Phase 0 (workflow + DNS plan)(pr [#245])
- docs-record DKIM off; add email-auth (DKIM+DMARC) as Phase 2b(pr [#251])
- ci(pages)-auto-deploy on push to main (fix stale asset URLs)(pr [#252])
- ci-remove jerusdataprotection.ie deploy(pr [#254])
- ci-remove AWS deploy and IaC wiring (AWS exit)(pr [#255])
- chore-remove dead IaC state backend (zero AWS)(pr [#256])

### Fixed

- pages: derive base_url from configure-pages (fix unstyled deploy)(pr [#249])
- pages: emit https URLs (use config.toml base_url)(pr [#253])

### Security

- Dependencies: update terraform hashicorp/terraform to >= 1.14.9(pr [#223])
- Dependencies: update terraform aws to >= 6.42.0(pr [#225])
- Dependencies: update terraform aws to >= 6.43.0(pr [#227])
- Dependencies: update terraform hashicorp/terraform to >= 1.15.0(pr [#226])
- Dependencies: update terraform hashicorp/terraform to >= 1.15.1(pr [#228])
- Dependencies: update terraform aws to >= 6.44.0(pr [#230])
- Dependencies: update terraform hashicorp/terraform to >= 1.15.2(pr [#229])
- Dependencies: update terraform hashicorp/terraform to >= 1.15.3(pr [#231])
- Dependencies: update terraform external to >= 2.4.0(pr [#232])
- Dependencies: update terraform aws to >= 6.45.0(pr [#233])
- Dependencies: update terraform hashicorp/terraform to >= 1.15.4(pr [#234])
- Dependencies: update terraform aws to >= 6.46.0(pr [#235])
- Dependencies: update hashicorp terraform(pr [#238])
- Dependencies: update hashicorp terraform to >= 6.49.0(pr [#239])
- Dependencies: update dependency toolkit to v6.3.0(pr [#240])
- Dependencies: update hashicorp terraform to >= 1.15.6(pr [#241])
- Dependencies: update actions/upload-pages-artifact action to v5(pr [#248])
- Dependencies: update hashicorp terraform(pr [#242])
- Dependencies: update dependency toolkit to v6.6.0(pr [#244])
- Dependencies: update dependency aws-cli to v5.4.2(pr [#243])
- Dependencies: update actions/checkout action to v7(pr [#246])
- Dependencies: update actions/deploy-pages action to v5(pr [#247])
- Dependencies: update actions/configure-pages action to v6(pr [#250])
- Dependencies: update dependency toolkit to v6.6.1(pr [#257])

## [1.9.7] - 2026-04-19

### Changed

- chore-inject RUST_LOG for gen_linkedin diagnostics(pr [#222])

## [1.9.6] - 2026-04-19

### Changed

- chore-set linkedin_post to -vvv for diagnostics(pr [#221])

## [1.9.5] - 2026-04-19

### Changed

- chore-remove prototype CI commands(pr [#220])

## [1.9.4] - 2026-04-17

### Changed

- chore-increase linkedin post verbosity for diagnostics(pr [#218])

## [1.9.3] - 2026-04-17

### Fixed

- use absolute URL in linkedin draft(pr [#217])

## [1.9.2] - 2026-04-16

### Fixed

- config: migrate Renovate config(pr [#211])
- ci: add missing contexts to bluesky_post and re-enable linkedin_post(pr [#216])

### Security

- Dependencies: update terraform aws to >= 6.41.0(pr [#215])

## [1.9.1] - 2026-04-15

### Fixed

- 🐛 config: correct footer menu link name(pr [#214])

## [1.9.0] - 2026-04-15

### Added

- add LinkedIn promotion and update publish date(pr [#210])

### Changed

- chore-3-file CI migration to toolkit 6.0.0(pr [#189])
- ci-remove redundant validation workflow when condition(pr [#193])
- chore-extend shared renovate config for CircleCI orb tracking(pr [#194])
- docs-add gen-orb-mcp project documentation and blog post(pr [#203])
- docs-add [linkedin] frontmatter to gen-orb-mcp blog post(pr [#205])
- chore-stage LinkedIn draft for gen-orb-mcp post(pr [#212])
- Jdp privacy statement(pr #213)

### Fixed

- skip push if bsky draft made no new commits(pr [#190])
- suppress empty pipeline on main branch pushes(pr [#191])
- pass deploy-iac parameter in API trigger(pr [#192])
- use global pipeline endpoint for definition_id trigger(pr [#199])
- use custom webhook to trigger IaC deploy(pr [#200])
- ci: break bluesky_draft push loop(pr [#204])

### Security

- Dependencies: update cimg/base docker tag to v2026.03(pr [#186])
- Dependencies: update terraform aws to v6(pr [#198])
- Dependencies: update terraform external to >= 2.3.5(pr [#196])
- Dependencies: update terraform hashicorp/terraform to >= 1.14.8(pr [#197])
- Dependencies: update terraform aws to >= 6.39.0(pr [#201])
- Dependencies: update dependency toolkit to v6.1.0(pr [#188])
- Dependencies: update dependency toolkit to v6.1.1(pr [#206])
- Dependencies: update terraform aws to >= 6.40.0(pr [#207])
- Dependencies: update dependency toolkit to v6.1.2(pr [#208])
- Dependencies: update dependency toolkit to v6.1.4(pr [#209])

## [1.8.0] - 2026-02-10

### Added

- serve jrussell.ie content on jerusdataprotection.ie(pr [#184])

### Fixed

- pass role_arn for AWS OIDC auth(pr [#185])

### Security

- Dependencies: update cimg/base docker tag to v2026.02(pr [#183])

## [1.7.0] - 2026-02-01

### Added

- ✨ Add AI Transition blog series(pr [#182])

### Security

- Dependencies: update cimg/base docker tag to v2026(pr [#177])
- Dependencies: update dependency toolkit to v4(pr [#178])
- Dependencies: update dependency toolkit to v4.0.2(pr [#179])
- Dependencies: update dependency toolkit to v4.1.0(pr [#180])

## [1.6.2] - 2025-12-16

### Changed

- 📝 docs(blog)-update engineering-critical blog details(pr [#175])

## [1.6.1] - 2025-12-15

### Changed

- Engineering-critical(pr [#174])
- 💄 style(blog)-fix gantt chart date format spacing(pr [#142])

### Security

- Dependencies: update dependency toolkit to v3(pr [#173])

## [1.6.0] - 2025-12-04

### Added

- ✨ add initial blog post about politicians(pr [#169])

## [1.5.0] - 2025-12-03

### Added

- ✨ add dark-versailles post(pr [#170])

### Security

- Dependencies: update dependency toolkit to v2.15.0(pr [#163])
- Dependencies: update dependency toolkit to v2.15.1(pr [#164])
- Dependencies: update dependency toolkit to v2.16.0(pr [#165])
- Dependencies: update cimg/base docker tag to v2025.11(pr [#166])
- Dependencies: update dependency path-filtering to v3(pr [#167])
- Dependencies: update cimg/base docker tag to v2025.12(pr [#168])

## [1.4.1] - 2025-10-23

### Fixed

- 🐛 blog: correct spelling errors in presidential election post(pr [#162])

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
[#162]: https://github.com/digital-prstv/jrussell.ie/pull/162
[#163]: https://github.com/digital-prstv/jrussell.ie/pull/163
[#164]: https://github.com/digital-prstv/jrussell.ie/pull/164
[#165]: https://github.com/digital-prstv/jrussell.ie/pull/165
[#166]: https://github.com/digital-prstv/jrussell.ie/pull/166
[#167]: https://github.com/digital-prstv/jrussell.ie/pull/167
[#168]: https://github.com/digital-prstv/jrussell.ie/pull/168
[#170]: https://github.com/digital-prstv/jrussell.ie/pull/170
[#169]: https://github.com/digital-prstv/jrussell.ie/pull/169
[#174]: https://github.com/digital-prstv/jrussell.ie/pull/174
[#142]: https://github.com/digital-prstv/jrussell.ie/pull/142
[#173]: https://github.com/digital-prstv/jrussell.ie/pull/173
[#175]: https://github.com/digital-prstv/jrussell.ie/pull/175
[#177]: https://github.com/digital-prstv/jrussell.ie/pull/177
[#178]: https://github.com/digital-prstv/jrussell.ie/pull/178
[#179]: https://github.com/digital-prstv/jrussell.ie/pull/179
[#180]: https://github.com/digital-prstv/jrussell.ie/pull/180
[#182]: https://github.com/digital-prstv/jrussell.ie/pull/182
[#183]: https://github.com/digital-prstv/jrussell.ie/pull/183
[#184]: https://github.com/digital-prstv/jrussell.ie/pull/184
[#185]: https://github.com/digital-prstv/jrussell.ie/pull/185
[#186]: https://github.com/digital-prstv/jrussell.ie/pull/186
[#189]: https://github.com/digital-prstv/jrussell.ie/pull/189
[#190]: https://github.com/digital-prstv/jrussell.ie/pull/190
[#191]: https://github.com/digital-prstv/jrussell.ie/pull/191
[#192]: https://github.com/digital-prstv/jrussell.ie/pull/192
[#193]: https://github.com/digital-prstv/jrussell.ie/pull/193
[#194]: https://github.com/digital-prstv/jrussell.ie/pull/194
[#198]: https://github.com/digital-prstv/jrussell.ie/pull/198
[#196]: https://github.com/digital-prstv/jrussell.ie/pull/196
[#199]: https://github.com/digital-prstv/jrussell.ie/pull/199
[#197]: https://github.com/digital-prstv/jrussell.ie/pull/197
[#200]: https://github.com/digital-prstv/jrussell.ie/pull/200
[#201]: https://github.com/digital-prstv/jrussell.ie/pull/201
[#203]: https://github.com/digital-prstv/jrussell.ie/pull/203
[#204]: https://github.com/digital-prstv/jrussell.ie/pull/204
[#205]: https://github.com/digital-prstv/jrussell.ie/pull/205
[#188]: https://github.com/digital-prstv/jrussell.ie/pull/188
[#206]: https://github.com/digital-prstv/jrussell.ie/pull/206
[#207]: https://github.com/digital-prstv/jrussell.ie/pull/207
[#208]: https://github.com/digital-prstv/jrussell.ie/pull/208
[#209]: https://github.com/digital-prstv/jrussell.ie/pull/209
[#210]: https://github.com/digital-prstv/jrussell.ie/pull/210
[#212]: https://github.com/digital-prstv/jrussell.ie/pull/212
[#214]: https://github.com/digital-prstv/jrussell.ie/pull/214
[#211]: https://github.com/digital-prstv/jrussell.ie/pull/211
[#216]: https://github.com/digital-prstv/jrussell.ie/pull/216
[#215]: https://github.com/digital-prstv/jrussell.ie/pull/215
[#217]: https://github.com/digital-prstv/jrussell.ie/pull/217
[#218]: https://github.com/digital-prstv/jrussell.ie/pull/218
[#220]: https://github.com/digital-prstv/jrussell.ie/pull/220
[#221]: https://github.com/digital-prstv/jrussell.ie/pull/221
[#222]: https://github.com/digital-prstv/jrussell.ie/pull/222
[#223]: https://github.com/digital-prstv/jrussell.ie/pull/223
[#225]: https://github.com/digital-prstv/jrussell.ie/pull/225
[#227]: https://github.com/digital-prstv/jrussell.ie/pull/227
[#226]: https://github.com/digital-prstv/jrussell.ie/pull/226
[#228]: https://github.com/digital-prstv/jrussell.ie/pull/228
[#230]: https://github.com/digital-prstv/jrussell.ie/pull/230
[#229]: https://github.com/digital-prstv/jrussell.ie/pull/229
[#231]: https://github.com/digital-prstv/jrussell.ie/pull/231
[#232]: https://github.com/digital-prstv/jrussell.ie/pull/232
[#233]: https://github.com/digital-prstv/jrussell.ie/pull/233
[#234]: https://github.com/digital-prstv/jrussell.ie/pull/234
[#235]: https://github.com/digital-prstv/jrussell.ie/pull/235
[#238]: https://github.com/digital-prstv/jrussell.ie/pull/238
[#239]: https://github.com/digital-prstv/jrussell.ie/pull/239
[#240]: https://github.com/digital-prstv/jrussell.ie/pull/240
[#241]: https://github.com/digital-prstv/jrussell.ie/pull/241
[#245]: https://github.com/digital-prstv/jrussell.ie/pull/245
[#249]: https://github.com/digital-prstv/jrussell.ie/pull/249
[#248]: https://github.com/digital-prstv/jrussell.ie/pull/248
[#242]: https://github.com/digital-prstv/jrussell.ie/pull/242
[#244]: https://github.com/digital-prstv/jrussell.ie/pull/244
[#243]: https://github.com/digital-prstv/jrussell.ie/pull/243
[#246]: https://github.com/digital-prstv/jrussell.ie/pull/246
[#247]: https://github.com/digital-prstv/jrussell.ie/pull/247
[#250]: https://github.com/digital-prstv/jrussell.ie/pull/250
[#251]: https://github.com/digital-prstv/jrussell.ie/pull/251
[#252]: https://github.com/digital-prstv/jrussell.ie/pull/252
[#253]: https://github.com/digital-prstv/jrussell.ie/pull/253
[#254]: https://github.com/digital-prstv/jrussell.ie/pull/254
[#255]: https://github.com/digital-prstv/jrussell.ie/pull/255
[#256]: https://github.com/digital-prstv/jrussell.ie/pull/256
[#257]: https://github.com/digital-prstv/jrussell.ie/pull/257
[#224]: https://github.com/digital-prstv/jrussell.ie/pull/224
[Unreleased]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.7...HEAD
[1.9.7]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.6...v1.9.7
[1.9.6]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.5...v1.9.6
[1.9.5]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.4...v1.9.5
[1.9.4]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.3...v1.9.4
[1.9.3]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.2...v1.9.3
[1.9.2]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.1...v1.9.2
[1.9.1]: https://github.com/digital-prstv/jrussell.ie/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.6.2...v1.7.0
[1.6.2]: https://github.com/digital-prstv/jrussell.ie/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/digital-prstv/jrussell.ie/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/digital-prstv/jrussell.ie/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/digital-prstv/jrussell.ie/compare/v1.4.0...v1.4.1
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

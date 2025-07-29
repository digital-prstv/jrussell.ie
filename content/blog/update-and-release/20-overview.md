+++
title = "Overview of Our Workflow"
description = "We’ll kick things off with a detailed overview of the dependency update and release workflow. We’ll cover the key steps involved, from identification of updates through automated testing and release."
date = 2025-01-17
updated = 2025-01-16
draft = false

[taxonomies]
topic = ["Technology"]
tags = ["devsecops", "software", "circleci", "security", "practices"]
+++
<!-- markdownlint-disable MD003 MD024 MD033-->

## Inputs to a release

{% mermaid() %}
---

config:
  look: handDrawn
  theme: forest
  displayMode: compact
---

graph LR
    A["Development<br/>Process"] --> C["Pull<br/>Request"]
    B["Dependency<br/>Check Process"] --> C
    C --> D["CI<br/>Testing"]
    C --> E["Code<br/>Review"]
    D --> F{"Tests<br/>Pass?"}
    E --> G{"Review<br/>Approved?"}
    F -->|Yes| H["Ready to<br/>Merge"]
    G -->|Yes| H
    F -->|No| I["Fix<br/>Issues"]
    G -->|No| I
    I --> C
    H --> J["Merge to<br/>Main Branch"]
    J --> K["CircleCI<br/>Periodic Trigger"]
    K --> L["Release<br/>Process"]
    L --> M["Update Version<br/>Numbers"]
    M --> N["Publish<br/>Release"]
{% end %}

The diagram describes the processes, outputs and inputs through the release process that contribute to building and, ultimately, releasing a new version of the software.

The development and dependency check processes create pull requests to facilitate the CI testing and review. Once passed, the changes are merged into the main branch.

CircleCI triggers the release process weekly on the main branch, updates the version numbers, and publishes the release.

## Schedule of release workflow

{% mermaid() %}
---
config:
  look: handDrawn
  theme: forest
  displayMode: compact
---
gantt
    title Release Cycle Schedule
    dateFormat  X
    axisFormat %s
    Today : vert, v1, 12, 1
    
    section Standard Libraries/Tools
    Development Phase           :done, dev1, 1, 8
    Dependency Updates          :done, dep1, 6, 9
    Release Workflow            :done, rel1, 9, 10
    Rest/Buffer Period          :done, rest1, 10, 11
    
    section Docker Container (Offset)
    Development Phase           :done, docker-dev1, 1, 2
    Dependency Updates          :done, docker-dep1, 1, 3
    Release Workflow            :done, docker-rel1, 3, 4
    Rest/Buffer Period          :done, docker-rest1, 4, 6
    Development Phase           :active, docker-dev2, 6, 13
    Dependency Updates          :active, docker-dep2, 11, 14
    Release Workflow            :docker-rel2, 14, 15
    Rest/Buffer Period          :docker-rest2, 15, 16


{% end %}

The Gantt chart displays the release cycle schedule. Development occupies most of the cycle, dependency updates run in parallel with the end of development, and the release workflow executes in the final phase.

The cycle concludes with a rest period or buffer time for remediation if issues arise.

Most libraries and tools follow a standard release schedule. However, some schedules are offset to accommodate dependencies. For example, the Docker container's dependency updates begin after the development cycles of its underlying tools are complete, allowing it to incorporate newly released versions.

Release cycle duration varies between libraries and tools based on security requirements and customer expectations. Components with frequently updated dependencies may require patch releases on a similar cadence to maintain currency.
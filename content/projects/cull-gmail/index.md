+++
title = "cull-gmail"
description = "Trash or delete gmail messages that have passed their data retention period."
weight = 20

[taxonomies]
tags = ["Rust", "gmail", "data protection", "CLI", "Automation"]

[extra]
pinned = true
quick_navigation_buttons = true

local_image = "projects/cull-gmail/cull-gmail-logo.webp"
+++

**cull-gmail** is a command-line tool for automated email retention management in Gmail. The tool can be periodically executed to apply retention rules to remove emails that have exceeded their specified retention period. Emails are identified by Gmail labels, which can be either dedicated retention labels created specifically for this purpose or existing custom labels already used to organize your mailbox.

The tool supports both planning and execution workflows. In planning mode, it can be used to list all labels in your mailbox along with message summaries showing dates and partial subjects, helping you design an effective the retention rules. For rule configuration, you can define retention periods for specific labels using flexible time units including days, weeks, months, or years. Once configured, the tool can be run periodically to automatically enforce these policies and remove emails that have passed their retention threshold.

[Cull-gmail CLI Documentation](main)

[Cull-gmail Library Documentation](lib)

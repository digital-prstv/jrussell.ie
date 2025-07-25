+++
title = "Update and Release"
template = "series.html"
sort_by = "slug"
transparent = true

[extra]
series = true

# Introduction.
[extra.series_intro_templates]
next_only = """
Welcome to $SERIES_HTML_LINK! 
$SERIES_PAGES_OLIST

This $SERIES_PAGES_NUMBER-part series covers the workflow and tools I use to maintain updates and releases for my open-source software, including prompt security patches for any dependency vulnerabilities.

Next: $NEXT_HTML_LINK - $NEXT_DESCRIPTION
"""

middle = """
📚 Part $SERIES_PAGE_INDEX of $SERIES_PAGES_NUMBER in $SERIES_HTML_LINK

$SERIES_PAGES_OLIST

- Previous: $PREV_HTML_LINK
- Next: $NEXT_HTML_LINK
"""

prev_only = """
Welcome to the final part of $SERIES_HTML_LINK!

New here? Start with $FIRST_HTML_LINK to build a strong foundation.

$SERIES_PAGES_OLIST

- Previous: $PREV_HTML_LINK
"""

# Fallback template.
default = "This article is part of the $SERIES_HTML_LINK series."

# Outro.
[extra.series_outro_templates]
next_only = """
$SERIES_PAGES_OLIST

Thanks for reading! 🙌

Continue your journey with $NEXT_HTML_LINK, where $NEXT_DESCRIPTION
Or check out the complete [$SERIES_TITLE]($SERIES_PERMALINK) series outline.
"""

middle = """
---
📝 Series Navigation

- Previous: $PREV_HTML_LINK
- Next: $NEXT_HTML_LINK
- [Series Overview]($SERIES_PERMALINK)
"""

prev_only = """
🎉 Congratulations! You've completed $SERIES_HTML_LINK.

Want to review? Here's where we started: $FIRST_HTML_LINK
Or check what we just covered in $PREV_HTML_LINK.
"""

# Fallback.
default = """
---
This article is part $SERIES_PAGE_INDEX of $SERIES_PAGES_NUMBER in $SERIES_HTML_LINK.
"""


+++

Every week, your dependencies release new versions. Some fix critical security vulnerabilities. Others introduce breaking changes that could crash your application. Most developers handle this reactively—updating when something breaks or when they remember to check. But what if you could automate the entire process while maintaining quality and reliability?

This series documents the complete workflow and toolchain I've built to automatically update, test, and release my open-source projects every week. Over the past two years, this system has processed hundreds of dependency updates across multiple projects, catching security issues within days of disclosure and preventing the technical debt that comes from delayed updates.

You'll learn how to build a system that monitors your dependencies, automatically creates pull requests with updates, runs comprehensive tests, and releases new versions—all while giving you control over what gets deployed to production. Whether you maintain a single library or manage multiple interconnected projects, this workflow will help you stay current without the constant manual overhead.

What makes this different? This isn't theoretical advice. Every tool, script, and configuration shown here is running in production, managing real projects with real users. You'll see the actual implementation, including the failures and iterations that led to the current system.

Ready to never manually chase dependency updates again? Let's build something that works.

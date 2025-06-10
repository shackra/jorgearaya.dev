---
title: 'Goimapnotify'
slug: goimapnotify
description: run scripts on your machine upon IMAP events
project_description: Execute scripts on IMAP mailbox changes (new/deleted/updated messages) using IDLE
started: 2017
stopped: ""
relationship: author
cover: "/images/portfolio/goimapnotify/cover.jpg"
images: ["/images/portfolio/goimapnotify/cover.jpg"]
topics: [Golang]
programming_langs: [Golang]
tech: [IMAP, IMAP IDLE]
draft: false
git: https://gitlab.com/shackra/goimapnotify/
---

I started `goimapnotify` back in 2017 because at the time (and currently) did most of my email inside GNU Emacs, my text editor of choice. What `goimapnotify` does is connect with your email server through the IMAP protocol, observe when a new email arrive or was deleted, and execute a script so that your computer does something when something happens in your mailbox.

When I started my project, the existing offering did not handle bad Internet connection well, so I could spent hours not knowing somebody sent me an email! This is were `goimapnotify` excels. In the Arch Linux Wiki, at the [entry for Isync](https://web.archive.org/web/20250514051418/https://wiki.archlinux.org/title/Isync#With_imapnotify) you can read the following:

> **IMAP IDLE** is a way to get **push notifications** to download new email, rather than polling the server intermittently. This has the advantage of saving bandwidth and delivering your mail as soon as it's available. Isync does not have native IDLE support, but we can use a program like imapnotify to call mbsync when you receive new email. **For this example we will use the goimapnotify package which is reported to work better with frequent network interruptions.**

This project is mention in other peoples' comments and blog posts:
- [A comment in Hacker News](https://news.ycombinator.com/item?id=42367084)
- [Another comment in Hacker News regarding the user's workflow](https://news.ycombinator.com/item?id=30934275)
- [Email in the terminal: a complete guide to the unix way of email](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/#automation)
- [Doom Emacs Configuration](https://pratikvn.github.io/my-emacs-config/#fetching)

## This project is available in the following GNU/Linux repositories

[![Packaging status](https://repology.org/badge/vertical-allrepos/goimapnotify.svg)](https://repology.org/project/goimapnotify/versions)

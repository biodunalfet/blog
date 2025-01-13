---
title: "database internals: the parser"
date: 2024-11-19T01:01:57+01:00
draft: true
tags:
    - database
---

In the last post, I described how H2's tokeniser works and the role in play in a sql engine. 
This post is about how a parser interprets the tokens and converts them into executable commands.

In most descriptions of databases, the tokeniser is a part of the parser.
---
title: "hebrew name validation with regex"
date: 2023-03-26T09:01:25+01:00
draft: false
tags:
    - regex
---

Recently, I encountered an interesting problem which involved validating if a string 
is a valid Hebrew name. The basic requirement was that it must contain all Hebrew characters.

Immediately, I knew regex was the way to go! I started thinking of what unicode character 
range I’d need to check for. However, after some digging, I realised that [most popular regex 
engines](https://www.regular-expressions.info/unicode.html#script:~:text=The%20JGsoft%20engine%2C%20Perl%2C%20PCRE%2C%20PHP%2C%20Ruby%201.9%2C%20Delphi%2C%20and%20XRegExp%20can%20match%20Unicode%20scripts)
support [unicode scripts](https://www.regular-expressions.info/unicode.html#script). I could use a unicode
grouping (like `{InHebrew}`) which nicely curates the unicode characters for non-Latin character based languages. Other examples of this 
are `{InArabic}` and `{InGreek}` which work for Arabic and Greek characters. My first solution to 
this problem was to use this pattern. Nice and simple!

```kotlin 
^\\p{InHebrew}+\$".toRegex().matches(name)
```

About a month after deploying this, I encountered a bug. Someone with a valid Hebrew name couldn't 
use this flow. I dug deeper only to realise that I didn't account for 'special' characters. After 
some conversations with a number of Hebrew speakers I know, I discovered that Hebrew names could 
contain an apostrophe. Not only that, the apostrophe could only be either in the middle or the end of 
the string, not both.

I went ahead to modify the regex and ended up with this.

```kotlin
"^\\p{InHebrew}+'?\\p{InHebrew}+|\\p{InHebrew}+'?\$".toRegex().matches(name)
```

…and that my friends brings us to the end of my occasional but always fun ride to regex-land.

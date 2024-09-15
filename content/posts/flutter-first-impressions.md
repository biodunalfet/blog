---
title: "flutter: first impressions"
date: 2023-04-17T09:01:25+01:00
draft: false
tags:
    - flutter
---


I've been doing mobile development for almost a decade now. In that time, I've encountered and work with all sorts of patterns, IDEs, libraries and so on, Flutter being one of them. Since I first came across it, I'd wanted to try it out but never got the time. I thought Flutter's approach to cross-platform development was interesting. It felt 'correct' compared to the likes of React Native or NativeScript.
Decided to give it a run with a pet project I had started working on. I had already built the entire UI on android but switched the entire thing to Flutter. 

### Things that impressed me
- Speed of development: Live reloads, no long gradle/xcode build waits
- Dart feels all too familiar. It felt like a pleasant mix of TypeScript, Kotlin and Java. And I love types, I can't lie
- It's native and as a result fast! 
- Lots of useful libraries for commonly done tasks like networking, dependency injection/service location. Many of these libraries where heavily inspired by their time-tested, well-developed equivalents in other languages
- I liked that it had support for meta programming using annotation processing unlike Swift
- Lots of architectural options to pick from. I tried Mobx initially, but it didn't seem to work for me. It depended too heavily on codegen. I immediately fell in love with Bloc because it was very similar to MVVM using Viewmodels with some bits of reactive programming. Bloc's documentation was also pretty good. I particularly like how Bloc handles scoping. I found it very simple and straightforward
- UI design is extremely simple. The APIs are well-structured and reusability is strongly emphasised.
- The interface for calling native android/iOS apis is clear and straightforward
- Flutter's APIs are generally unpretentious compared to native android and iOS.

### What I didn't like
The pubsec/library ecosystem has a couple of minor problems. For eg. I was surprised that GetX in its current form is as popular as it is because of how much that single library does! I'm used to smaller dedicated libraries instead of bloated complicated ones. Also, a number of fairly popular community built library seemed to not get regular updates, especially those that involve some form of communication with android & iOS interfaces.

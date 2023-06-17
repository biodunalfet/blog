---
title: "jetpack navigation: pitfalls and recommendations"
date: 2023-01-21T09:01:25+01:00
draft: false
tags:
- jetpack-compose
- android
- navigation
---

I've used Jetpack Compose in a production app for about 4 months now, and in that time, I've experienced all manner of emotions.
Most times, it's relief and excitement at how fast it is to create views and reuse components. On the other hand, it is pain, and one of the main sources other than how slow 
and resource intensive the preview rendering is, has been the Jetpack navigation library.


Don't get me wrong, it's not all gloom and doom. I genuinely love how simple navigation is in Compose.
It's just that the pitfalls are unforgiving and hard to predict without prior experience.


In the post, I'll be outlining some of the common pitfalls, how to solve them and some other interesting tips 
I've come and across or used in my projects.

#### Save your routes as constants.

You can do this with an `object` and group them with a `sealed class`. Why? Not doing this exposes one to the
risk of misspelling the routes and causing this exception to be thrown.

```java
java.lang.IllegalArgumentException: Navigation destination that matches request cannot be 
found in the navigation graph
```

In addition, a sealed class can help with grouping related destination routes for clarity. You can also add a 
prefix to your routes to distinguish routes with similar names or use-cases.

```kotlin
const val SALES_DETAILS = "sales.detailsPage"
const val SPEND_DETAILS = "spend.detailsPage"

composable("$SALES_DETAILS") {
...
}

navController.navigate("$SALES_DETAILS")

```

#### Be wary of `?` and `&` when passing parameters via the routes
I've found myself using the `?` multiple times in the same route for more than 1 parameter, causing an error to 
occur. You can create a route Builder class or use a library that safely generates routes.

#### You should URLEncode any parameter you are passing via the routes.
This is important because, if your route contains `?`, `&`, `/` or any other URL related special characters, your 
route will interpret them not as mere strings but as route delimiters. This can cause the navigation to break.
If you pass non-primitive parameters by serialising to JSON Strings, then you have to do this. Don't forget to 
URLDecode the parameters when you extract them.

#### Use subgraphs as much as you can, for your sanity.
With a single, flat graph, your files can get really large, making it difficult to find stuff.
Subgraphs are nice and with Hilt, you can create ViewModels scoped to your subgraphs in case you need to share
data across its destinations. [Ian Lake](https://twitter.com/ianhlake) explains how [here](https://stackoverflow.com/a/64961032/2643382).

#### Use Jetpack Compose Navigation Material
Using the [Jetpack Compose Navigation Material](https://google.github.io/accompanist/navigation-material/) library
simplifies your graph by making your BottomSheets mere destinations like your other 'full screen' destinations 
(s/o [Jossi Wolf](https://twitter.com/jossiwolf) for this one). The [original way](https://developer.android.com/reference/kotlin/androidx/compose/material/package-summary#BottomSheetScaffold(kotlin.Function1,androidx.compose.ui.Modifier,androidx.compose.material.BottomSheetScaffoldState,kotlin.Function0,kotlin.Function1,kotlin.Function0,androidx.compose.material.FabPosition,kotlin.Boolean,androidx.compose.ui.graphics.Shape,androidx.compose.ui.unit.Dp,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.ui.unit.Dp,kotlin.Function1,kotlin.Boolean,androidx.compose.ui.graphics.Shape,androidx.compose.ui.unit.Dp,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,kotlin.Function1))
works, but it makes the graph clunky, especially when you have to display multiple BottomSheets in the same root. Your graph gets longer and you
have to write extra code to manage the state of your many BottomSheets.

Subscribe to [Mark Murphy's JetC's newsletter](https://jetc.dev/)
Lastly, I'd recommend you subscribe to Mark Murphy's JetC newsletter. It contains a lot of useful information 
about Jetpack Compose from all over the internet, especially the #kotlinlang Slack channel. 
Trust me, you won't regret it.

#### Use local storage to pass data between destinations
The default way of passing data between destinations works fine in most cases 
(i.e. using query parameters). However, if you need to pass medium to large amounts
of data or data whose content isn't guaranteed to be URL-safe (perhaps due to
encoding), it's advisable to store the data locally via shared preferences,
data stores, or any other key-value-based storage mechanism. This way, you can
assign a simple, unique, URL-safe key to the data and pass it between destinations
without any concerns about data size or URL safety.

--- Updated 17th June 2023
---
title: "learning react and building svgDashboard"
date: 2021-04-07T01:27:00+01:00
draft: false
tags:
  - react
  - frontend
---

I needed to add [this feature](https://www.notion.so/New-Feature-Alert-Converting-tweets-to-beautiful-images-ff758d5297d64ea7828a8a79ca7e7211?pvs=4) 
(TODO: change link to blog link) to Quoted Replies and that required me to 'templatize' svg pattern backgrounds.

By templatize, I mean generating [mustache templates](http://mustache.github.io/) for svg images for easy color substitution. To explain further,
the image below is made up of 4 different colors but really, it's just one main color and 3 variants of it.

<center><img src="/svg-dash-img.png" height="300"></center>

I needed to replace the colors in the svg code with 4 variables and define how the variable were related. For example,

- variable 1 = `#291b2b`,
- variables 2 to 4 = variable 1 but with different lightness values on the [hsl color scale](https://en.wikipedia.org/wiki/HSL_and_HSV).

The tool then generates a json representation of the image and its variables.

```json
{
   "name":"2am27s",
   "abs":[
      {
         "name":"main",
         "default":"#291b2b"
      }
   ],
   "rel":[
      {
         "name":"rel1",
         "base":"main",
         "intensity":-17
      },
      {
         "name":"rel2",
         "base":"main",
         "intensity":-30
      },
      {
         "name":"rel3",
         "base":"main",
         "intensity":-40
      }
   ],
   "code":"<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:svgjs=\"http://svgjs.com/svgjs\" width=\"500\" height=\"560\" preserveAspectRatio=\"none\" viewBox=\"0 0 500 560\"><g mask=\"url(&amp;quot;#SvgjsMask1000&amp;quot;)\" fill=\"none\"><rect width=\"500\" height=\"560\" x=\"0\" y=\"0\" fill=\"{{main}}\"/><path d=\"M250 681.57C350.23 676.54 422.04 593.92 491.2 521.2 557.87 451.05 629.34 376.73 631.82 280 634.34 181.54 575.55 93.68 503.84 26.16 434.45-39.19 345-72.07 250-79.58 145.04-87.88 26.01-92.91-47.4-17.4-120.33 57.61-105.23 175.55-99.55 280-94.28 376.63-80.21 473.66-16.66 546.66 51.34 624.79 146.57 686.78 250 681.57\" fill=\"{{rel1}}\"/><path d=\"M250 539.84C314.86 536.59 361.32 483.13 406.07 436.07 449.21 390.68 495.45 342.59 497.06 280 498.69 216.29 460.65 159.44 414.25 115.75 369.35 73.46 311.47 52.19 250 47.33 182.09 41.96 105.06 38.7 57.57 87.57 10.38 136.1 20.14 212.42 23.82 280 27.23 342.52 36.34 405.31 77.45 452.55 121.45 503.1 183.08 543.21 250 539.84\" fill=\"{{rel2}}\"/><path d=\"M250 398.11C279.48 396.63 300.6 372.33 320.94 350.94 340.55 330.31 361.57 308.45 362.3 280 363.04 251.04 345.75 225.2 324.66 205.34 304.25 186.12 277.94 176.45 250 174.24 219.13 171.8 184.12 170.32 162.53 192.53 141.08 214.59 145.52 249.28 147.19 280 148.74 308.42 152.88 336.96 171.57 358.43 191.57 381.41 219.58 399.64 250 398.11\" fill=\"{{rel3}}\"/></g><defs><mask id=\"SvgjsMask1000\"><rect width=\"500\" height=\"560\" fill=\"#ffffff\"/></mask></defs></svg>"
}
```

_You might need to view the json in a json viewer to see how the colors are referenced._

I tried to do all of this manually but as you can imagine, it was super painful. From detecting the pattern's constituent 
colors and their formats (which are often different), to viewing the detected colors all at a glance and discerning which are related,
and finally working out how they're related. I decided I was going to build a web app for to easen the process.

However, I didn't know how to build web apps. Decided to take a react course on [frontendmasters.com](http://frontendmasters.com) 
and speak to a few of my React friends. After a couple of weeks, I gained some level of proficiency enough to *automate* the 
flow I outlined above. But really, what gave me the confidence to start building ––after days of watching videos and boringly
coding along–– was [this talk](https://youtu.be/dpw9EHDh2bM?t=1579) by Dan Abramov at React Conf '18

### **Introducing [SvgDashboard](https://svgdashboard.web.app/) (yeah, boring name)**

There really isn't much to say here. The video below describes what it does.

<iframe width="560" height="315" src="https://www.youtube.com/embed/guD-AFRNa_Y" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Here's a [link](https://github.com/biodunalfet/svg-dashboard) to the repo, in case you're wondering what my code looks like or would like to comment/contribute.

### **My Experience with React**

Going to do bullet points here

- It didn't take too long to gain some level of proficiency
- To my utter surprise, I absolutely enjoyed working with JavaScript and React. The only thing I missed was the presence of a robust standard library like we have on Kotlin and Java, but [lodash](https://lodash.com/) came to the rescue here.
- Developing with React is blazingly fast compared to working with native Android where you have to wait for builds to compile and install on a device just to view changes. *Super green with envy about this one!*
- Another thing that surprised me was how much I enjoyed working without ***strong** types*. The flexibility was somewhat refreshing. Or could it be that I didn't miss types because it was a small project? 🤔
- There are lots of similarities between modern native app development and web app development with React. That helped me a lot. For example, even though I didn't use Redux, I immediately understood it when I came across it.
- The docs are amazing especially Mozilla's MDN and the official React docs.
- The tooling is also great. Shout out to the Chrome React Dev Tools and IntelliJ React Plugin
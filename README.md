# Presidential Forecast Analysis: User Manual
#### Kayla Manning
*I am a junior in Adams House pursuing a joint concentration in Statistics and Government.*

You can view the published app [here]( https://kayla-manning.shinyapps.io/presidential-forecast-reflection/), and a video walkthrough [here](https://youtu.be/fa94svSKCz4). While not necessary to view the finished product, you can also view the code on your own computer as well. If you wish to run the code yourself, I recommend that you fork and clone my [Github repository](https://github.com/kayla-manning/presidential-forecast-analysis) and open it as a new project in Rstudio. 

For all code necessary to run the app, open the `shiny` folder within the project. First, ensure that you have installed all packages loaded at the top of the `helper.R` file. To do that, run `install.packages("package_name_here")` in your RStudio console for all packages that you do not already have. Then, open the `subset_app.Rmd` file. From there, all that you need to do is knit the document. To knit, you may either click the "Run Document" button on the top toolbar of your Rstudio window or you can type Cmd + Shift + K if you are on a Mac. This file uses a random selection of my simulation data from my original forecast. There are still 10,000 simulations for each state, so it still has representative sample of my total forecast. The original dataset exceeded Shiny's memory capabilities, and the app runs much quicker with this subset data.

If you are feeling extra curious, you can view the source code for how I created my original forecast or any of my other [blog](https://kayla-manning.github.io/gov1347/) posts in [this](https://github.com/kayla-manning/gov1347) repository. The code for the final model is under `scripts/final.Rmd`.
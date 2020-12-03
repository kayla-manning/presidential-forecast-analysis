# Presidential Forecast Analysis: User Manual
## CS50 Final Project
### Kayla Manning
### Joint Concentration in Statistics and Government
### Adams House, 2022

You can view the published app [here]( https://kayla-manning.shinyapps.io/presidential-forecast-reflection/). While not necessary to view the finished product, you can also view the code on your own computer as well. If you wish to run the code yourself, I recommend that you fork and clone my [Github repository](https://github.com/kayla-manning/presidential-forecast-analysis) and open it as a new project in Rstudio. 

For all code necessary to run the app, open the `shiny` folder within the project. First, ensure that you have installed all packages loaded at the top of the `helper.R` file. To do that, run `install.packages("package_name_here")` in your Rstudio console for all packages that you do not already have. Then, open the `presidential-forecast-reflection.Rmd` file. From there, all that you need to do is knit the document. To knit, you may either click the "Run Document" button on the top toolbar of your Rstudio window or you can type Cmd + Shift + K if you are on a Mac. This file uses all simulation data. If you would like a file that runs quicker, then `subset_app.R` is for you, as it deals with 1/10 of the simulations data as the full reflection file. The published app uses this subset information since the original dataset exceeded shiny's memory capabilities.

If you are feeling extra curious, you can view the source code for how I created my original forecast or any of my other [blog](https://kayla-manning.github.io/gov1347/) posts in [this](https://github.com/kayla-manning/gov1347) repository. The code for the final model is under `scripts/final.Rmd`.

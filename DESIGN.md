# Project Design

I created a new repository for this project separate from my forecast model for housekeeping reasons. That original repository if very built-out, and I did not want the additional files required for the project specifications to cloud my professional environment in the other repository.

Prior to the election, I anticipated that I would want my CS50 final project to incorporate my simulation data, so I saved a .csv file of the dataframe with my simulations results from November 1, 2020 at 3 PM. This file is located at `shiny/app-data/election_simulation_results.csv` I knew I wanted those exact simulations because rerunning the code at a later date would incorporate poll numbers from after making my final forecast.

This file with the simulation data is extremely large to say the least. While this might be a bit excessive in hindsight, I ran 100,000 election simulations for each state, which amounted to a .csv with 5 million rows. Of course, the size of this file (651.7 MB!) exceeded GitHub's storage limits and I had to push it using their large file storage feature.

My goal with this project was to create a more visual, interactive counterpart for my [blog](https://kayla-manning.github.io/gov1347/), which contains more technical and descriptive analyses of the election and my model. For that reason, I wanted to minimize the amount of text on this site to avoid distracting from the visualizations.

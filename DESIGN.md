# Presidential Forecast Analysis: Design
#### Kayla Manning
*I am a junior in Adams House pursuing a joint concentration in Statistics and Government.*

My goal with this project was to create a more visual, interactive counterpart for my [blog](https://kayla-manning.github.io/gov1347/), which contains more technical and descriptive analyses of the election and my model. In contrast to my blog, which contains plenty of text and in-depth explanations, I wanted the graphics to sit front and center in this project.

For housekeeping reasons, I elected to create a new repository for this project, separate from that of my original blog. My blog's repository is very organized, structured, and built-out, and I felt that adding the additional files required of this project would cloud its professional environment. Not only that, but I also knew that I would have to submit this project separately and I did not want to make the CS50 teaching staff comb through all of the files and data for my blog.

Prior to the election, I saved a .csv file of the dataframe with my simulations results from November 1, 2020 at 3 PM. Unfortunately, I ran into some issues with trying to publish my Shiny app with this data.

This original simulation data is massive: I ran 100,000 election simulations for each state, which amounted to a .csv with 5 million rows. Of course, the size of this file (651.7 MB!) exceeded GitHub's storage limits and I had to take advantage of the large file storage feature.

Memory constraints through Shiny prohibited me from publishing my app online using the whole dataset. As I result, I made an alternative app with a subset of the simulation data so that I could publish it. For this, I randomly selected 10,000 simulations out of the 100,000 simulations for each state. This subset of the original simulation data is located at `shiny/app-data/simulations_subset.csv`. To keep my app code readable and more organized, I created a separate helper file under `shiny/subset_helper.R` that loaded the shortened data for this modified app and all necessary packages for the app.


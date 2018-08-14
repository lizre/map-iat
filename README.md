# Data and code used to map Implicit Association Test (IAT) Scores

These maps were made using the publicly-available Project Implicit <a href = "https://osf.io/y9hiq/">demo website datasets</a>. SPSS syntax was used to clean this publicly-available dataset; it was partly developed to clean the Project Implicit datasets as part of a <a href = "https://osf.io/rfzhu/">project*</a> led by Kate Ratliff. Much of the syntax was developed by Jenny Howell, and it was used and vetted by Calvin Lai and Liz Redford.

race_clean_sample.R was used to create a dataset small enough to be handled by R. This smaller dataset is the one posted here in this repo (raceiatdat.csv).

map_raceiat.R imports raceiatdat.csv from this repo. It was developed by Nick Ungson and modified by Liz Redford. It creates the following maps:

<img src="https://github.com/lizredford/map-iat/raw/master/race_bycounty.png" width="850">

<img src="https://github.com/lizredford/map-iat/raw/master/race_bystate.png" width="850">

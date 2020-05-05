tuesdata <- tidytuesdayR::tt_load(2019, week = 51)

dog_moves <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-12-17/dog_moves.csv')
dog_travel <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-12-17/dog_travel.csv')
dog_descriptions <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-12-17/dog_descriptions.csv')

tuesdata$dog_moves <- dog_moves
tuesdata$dog_travel <- dog_travel
tuesdata$dog_descriptions <- dog_descriptions

write_rds_bak(tuesdata, here::here("content", "post", "2019-12-16-adoptable-dogs", "tuesdata.rds"))

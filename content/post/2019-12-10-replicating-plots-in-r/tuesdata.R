
tuesdata <- tidytuesdayR::tt_load("2019-12-10")
tuesdata <- tidytuesdayR::tt_load(2019, week = 50)

write_rds_bak(tuesdata, here::here("content", "post", "2019-12-10-replicating-plots-in-r", "tuesdata.rds"))

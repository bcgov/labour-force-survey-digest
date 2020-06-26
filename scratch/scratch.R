# Copyright 2020 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


## libraries  ------------------------------------------------------------------
library(cansim)
library(dplyr)
library(ggplot2)
library(janitor)
library(lubridate)


## Exploratory visualizations --------------------------------------------------

## load cached /tmp/*.rds data files
lf_character <- readRDS("tmp/lf_character.rds")


## tidy data
lfc_tidy <- lf_character %>%
  clean_names() %>%
  filter(
    geo == "British Columbia",
    labour_force_characteristics %in% c("Unemployment rate",
                                        "Employment rate",
                                        "Employment"),
    data_type == "Seasonally adjusted",
    statistics %in% c("Estimate", "Standard error of estimate")
  ) %>%
  select("date",
         "geo",
         "labour_force_characteristics",
         "sex",
         "age_group",
         "statistics",
         "vector",
         "value")


## plotting
lfc_tidy %>%
  filter(statistics == "Estimate",
        labour_force_characteristics == "Employment") %>%
  ggplot() +
  geom_point(aes(date, value, group = sex)) +
  facet_wrap(facets = vars(age_group))


lfc_tidy %>%
  filter(statistics == "Estimate",
        labour_force_characteristics == "Employment",
        sex == "Both sexes",
        age_group == "15 years and over",
        date > "2019-12-01" ) %>%
  mutate(month_change = value - lag(value),
         month_change_percent = round((value/lag(value) - 1) * 100, digits = 1))

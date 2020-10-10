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


rmarkdown::render(input = here::here("scratch/lfs-text-highlights.Rmd"),
                  output_file = paste0("lfs-text-highlights_",
                                       Sys.Date(),
                                      ".pdf"),
                  output_dir = here::here("scratch"))

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


## ---------------------------------------------------------------------------
### Monthly Change in B.C. Unemployment in `r report_year`

p5 <- lfc_province_tidy %>%
  filter(vector == "v2064704",
         date > "2019-12-01") %>%
  ggplot(aes(
    x = date,
    y = value,
    text = paste(
      "Month-Over-Month Change in Unemployment:",
      signs(month_change,
            format = comma,
            add_plusses = TRUE),
      "<br>",
      "% Month-Over-Month Change:",
      signs(
        month_change_percent,
        format = percent,
        add_plusses = TRUE,
        accuracy = 0.1
      )
    )
  )) +
  geom_col(fill = main_colour,
           alpha = 0.6) +
  geom_text(
    aes(label = signs(
      month_change,
      format = comma,
      add_plusses = TRUE
    )),
    nudge_y = -9000,
    colour = "grey20",
    size = 2.5
  ) +
  labs(x = NULL,
       y = NULL) +
  scale_y_continuous(labels = comma,
                     expand = c(0, 0),
                     breaks = breaks_pretty(n = 6)) +
  scale_x_date(breaks = breaks_pretty(n = 6)) +
  theme_minimal() +
  theme_vert_bar


ggplotly_lfs(p5)


### Year Change in Unemployment {.value-box}

year_change_unemployment <- lfc_province_tidy %>%
  filter(vector == "v2064704",
         date %in% c(max(date) - months(12), max(date))) %>%
  mutate(
    year_change = value - lag(value),
    year_change_percent = value / lag(value) - 1
  ) %>%
  filter(date == max(date))

#year over year change employment
valueBox(value = year_change_unemployment %>%
  pull(year_change) %>%
  signs(format = comma,
        add_plusses = TRUE),
         icon = "fa-users-cog",
         caption = paste("Year-Over-Year Change in B.C. Unemployment"))


### Month-Over-Month Change in Number of Jobs by Province in `r report_month`

# lim_mom_jobs_can <- c(
#   0,
#   lfc_province_tidy %>%
#     ungroup() %>%
#     filter(
#       labour_force_characteristics == "Employment",
#       sex == "Both sexes",
#       age_group == "15 years and over",
#       date == max(date),
#       geo != "Canada"
#     ) %>%
#     slice_max(month_change, n = 1) %>%
#     pull(month_change) + 30000
# )

mom_change_employment_provinces <- lfc_province_tidy %>%
  filter(
    labour_force_characteristics == "Employment",
    sex == "Both sexes",
    age_group == "15 years and over",
    date == max(date),
    geo != "Canada") %>%
  mutate(fill_col = ifelse(geo == "British Columbia", "bc", "other")) %>%
  ggplot(aes(x = reorder(geo, -month_change), y = month_change)) +
  geom_col(aes(fill = fill_col,
              text = paste(
      "Month-Over-Month Change:",
      signs(
       month_change,
       format = comma,
       add_plusses = TRUE),
      "<br>",
      "% Month-Over-Month Change:",
      signs(
        month_change_percent,
        format = percent,
        add_plusses = TRUE,
        accuracy = 0.1
      )
    )), alpha = 0.6) +
  coord_flip() +
  geom_text(
    aes(
      label = signs(
        month_change_percent,
        format = percent,
        add_plusses = TRUE,
        accuracy = 0.1
      )
    ),
    nudge_y = 8000,
    colour = "grey20",
    size = 2.5
  ) +
  labs(x = NULL,
       y = NULL) +
  scale_y_continuous(
    labels = comma,
    expand = c(0, 0),
    # limits = lim_mom_jobs_can,
    breaks = breaks_pretty(n = 6)
  ) +
  scale_fill_manual(guide = FALSE,
                    values = c(bc = "#440154FF",
                               other = main_colour)) +
  theme_minimal() +
  theme_horiz_bar +
  theme(legend.position = "none")

ggplotly_lfs(mom_change_employment_provinces)

# mom_change_employment_ag <- lfc_province_tidy %>%
#   filter(
#     date >= paste0(report_year, "-01-01"),
#     geo == "British Columbia",
#     labour_force_characteristics == "Employment",
#     age_group %in% c("15 to 24 years",
#                      "25 to 54 years",
#                      "55 years and over")
#   ) %>%
#   mutate(sex = recode(sex, "Both sexes" = "All")) %>%
#   filter(sex != "All") %>%
#   ggplot(aes(
#     x = date,
#     y = month_change,
#     text = paste(
#       "Month-Over-Month Change:",
#       signs(month_change,
#             format = comma,
#             add_plusses = TRUE),
#       "<br>",
#       "% Month-Over-Month Change:",
#       signs(
#         month_change_percent,
#         format = percent,
#         add_plusses = TRUE,
#         accuracy = 0.1
#       )
#     )
#   )) +
#   geom_col(fill = main_colour,
#            alpha = 0.6) +
#   facet_grid(sex ~ age_group) +
#   geom_text(
#     aes(
#       label = signs(
#         month_change_percent,
#         format = percent,
#         add_plusses = TRUE,
#         accuracy = 0.1
#       )
#     ),
#     nudge_y = -5000,
#     colour = "grey20",
#     size = 2
#   ) +
#   labs(x = NULL,
#        y = NULL) +
#   scale_y_continuous(labels = comma,
#                      breaks = breaks_pretty(5)) +
#   scale_x_date(breaks = breaks_pretty(n = 4)) +
#   theme_minimal() +
#   theme_facet_bar
# # theme(strip.text.y = element_text(angle = 0))
#
# ggplotly_lfs(mom_change_employment_ag)

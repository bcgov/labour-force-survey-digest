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


## load libraries in setup.R   -------------------------------------------------
source("setup.R")


## get spatial data ------------------------------------------------------------

#economic regions spatial data from the B.C. Data Catalogue using the bcdata package
# https://catalogue.data.gov.bc.ca/dataset/1aebc451-a41c-496f-8b18-6f414cde93b7
economic_regions <-
  bcdc_get_data("1aebc451-a41c-496f-8b18-6f414cde93b7") %>%
  clean_names()


#get Canadian & Province/Territory spatial data using the cancensus package
can_provinces <- cancensus::get_census(
    "CA16",
    regions = list(C = "01"),
    level = "PR",
    use_cache = FALSE,
    geo_format = "sf"
  )

## get raw Statistics Canada Tables --------------------------------------------

#list of all cansim tables
sc_tables <- list_cansim_tables(refresh = FALSE)

#get all tables
#labour force characteristics by province, monthly, seasonally adjusted
lfc_province_raw <- get_cansim("14-10-0287-03") %>% normalize_cansim_values()

#labour force characteristics by territory, three-month moving average, seasonally adjusted
lfc_territories_raw <- get_cansim("14-10-0292-02") %>% normalize_cansim_values()

#labour force characteristics by economic region, three-month moving average, unadjusted for seasonality
lfc_region_raw <- get_cansim("14-10-0293-02") %>% normalize_cansim_values()

#employment by class of worker, monthly, seasonally adjusted and unadjusted, last 5 months
employment_by_class_raw <- get_cansim("14-10-0288-01") %>% normalize_cansim_values()

#employment by industry, monthly, seasonally adjusted
employment_by_industry_raw <- get_cansim("14-10-0355-02") %>% normalize_cansim_values()

#labour force characteristics by industry, monthly, unadjusted for seasonality
lfs_industry_unadjusted_raw <- get_cansim("14-10-0022-01") %>% normalize_cansim_values()

#labour force characteristics by immigrant status, three-month moving average, unadjusted for seasonality
# lfs_immigrant_status_raw <- get_cansim("14-10-0082-01") %>% normalize_cansim_values()

#reason for not looking for work, monthly, unadjusted for seasonality
# reasons_not_working_raw <- get_cansim("14-10-0127-01") %>% normalize_cansim_values()


## cache raw Statistics Canada Tables to /tmp ----------------------------------

#cache data to /tmp
saveRDS(economic_regions, "tmp/economic_regions.rds")
saveRDS(can_provinces, "tmp/can_provinces.rds")
saveRDS(lfc_province_raw, "tmp/lfc_province_raw.rds")
saveRDS(lfc_territories_raw, "tmp/lfc_territories_raw.rds")
saveRDS(lfc_region_raw, "tmp/lfc_region_raw.rds")
saveRDS(employment_by_class_raw, "tmp/employment_by_class_raw.rds")
saveRDS(employment_by_industry_raw, "tmp/employment_by_industry_raw.rds")
saveRDS(lfs_industry_unadjusted_raw, "tmp/lfs_industry_unadjusted_raw.rds")
# saveRDS(lfs_immigrant_status_raw, "tmp/lfs_immigrant_status_raw.rds")
# saveRDS(reasons_not_working_raw, "tmp/reasons_not_working_raw.rds")


## tidy Statistics Canada Tables -----------------------------------------------

#load & tidy cached /tmp/*.rds data files
economic_regions <- readRDS("tmp/economic_regions.rds")
can_provinces <- readRDS("tmp/can_provinces.rds")
lfc_province_raw <- readRDS("tmp/lfc_province_raw.rds")
lfc_region_raw <- readRDS("tmp/lfc_region_raw.rds")
employment_by_class_raw <- readRDS("tmp/employment_by_class_raw.rds")
employment_by_industry_raw <- readRDS("tmp/employment_by_industry_raw.rds")
lfs_industry_unadjusted_raw <- readRDS("tmp/lfs_industry_unadjusted_raw.rds")
# lfs_immigrant_status_raw <- readRDS("tmp/lfs_immigrant_status_raw.rds")
# reasons_not_working_raw <- readRDS("tmp/reasons_not_working_raw.rds")


#labour force characteristics by province, month & season
lfc_province_tidy <- lfc_province_raw %>%
  clean_names() %>%
  filter(
    labour_force_characteristics %in% c(
      "Population",
      "Unemployment",
      "Unemployment rate",
      "Employment rate",
      "Employment",
      "Full-time employment",
      "Part-time employment"
    ),
    data_type == "Seasonally adjusted",
    statistics == "Estimate"
  ) %>%
  select(
    "date",
    "geo",
    "labour_force_characteristics",
    "sex",
    "age_group",
    "statistics",
    "vector",
    "value"
  ) %>%
  # filter(date >  Sys.Date() - months(14)) %>%
  group_by(vector) %>%
  mutate(
    month_change = value - lag(value),
    month_change_percent = value / lag(value) - 1
  )



#labour force characteristics by economic region
lfc_region_tabular_tidy <- lfc_region_raw %>%
  clean_names() %>%
  filter(
    str_detect(geo, "British Columbia"),
    labour_force_characteristics %in% c(
      "Population",
      "Unemployment",
      "Unemployment rate",
      "Employment rate",
      "Employment"
    ),
    statistics %in% c("Estimate")
  ) %>%
  select(
    "date",
    "geo",
    "labour_force_characteristics",
    "statistics",
    "vector",
    "value",
    "geo_uid"
  ) %>%
  filter(date >  Sys.Date() - months(14)) %>%
  group_by(vector) %>%
  mutate(
    month_change = value - lag(value),
    month_change_percent = value / lag(value) - 1,
    polygon_code = ifelse(
      geo == "North Coast and Nechako, British Columbia",
      "5960-70",
      geo_uid
    )
  )

economic_regions_tidy <- economic_regions %>%
  mutate(group_var = case_when(
    economic_region_id %in% c("5960", "5970") ~ "5960-70",
    TRUE ~ economic_region_id
  )) %>%
  group_by(group_var) %>%
  summarise() %>%
  rmapshaper::ms_clip(bcmaps::bc_bound(class = "sf"))


lfc_region_tidy <- economic_regions_tidy %>%
  left_join(lfc_region_tabular_tidy,
            by = c("group_var" = "polygon_code"))


#employment by class of worker
employment_by_class_tidy <- employment_by_class_raw %>%
 clean_names() %>%
  filter(
    geo == "British Columbia",
    data_type == "Seasonally adjusted",
    statistics %in% c("Estimate")
  ) %>%
  select(
    "date",
    "geo",
    "class_of_worker",
    "sex",
    "statistics",
    "vector",
    "value"
  ) %>%
  filter(date > Sys.Date() - months(14)) %>%
  group_by(vector) %>%
  mutate(
    month_change = value - lag(value),
    month_change_percent = value / lag(value) - 1
  )


#cache tidy data to /tmp  ------------------------------------------------------
saveRDS(lfc_province_tidy, "tmp/lfc_province_tidy.rds")
saveRDS(lfc_region_tidy, "tmp/lfc_region_tidy.rds")
saveRDS(employment_by_class_tidy, "tmp/employment_by_class_tidy.rds")


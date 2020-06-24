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

## libraries
library(cansim)
library(dplyr)


## get StatsCanada Cansim Tables -----------------------------------------------

lf_character <- get_cansim("14-10-0287-03")
reasons_not_working <- get_cansim("14-10-0127-01")
employment_by_class <- get_cansim("14-10-0288-01")

#cache data to /tmp
saveRDS(lf_character, "tmp/lf_character.rds")
saveRDS(reasons_not_working, "tmp/reasons_not_working.rds")
saveRDS(employment_by_class, "tmp/employment_by_class.rds")

#load cached .rds data files
lf_character <- readRDS("tmp/lf_character.rds")
reasons_not_working <- readRDS("tmp/reasons_not_working.rds")
employment_by_class <- readRDS("tmp/employment_by_class.rds")

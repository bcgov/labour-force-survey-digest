[![Lifecycle:Dormant](https://img.shields.io/badge/Lifecycle-Dormant-ff7f2a)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## labour-force-survey-digest

A mvp/prototype implementation of a summary dashboard for some key [Statistics Canada Labour Force Survey](https://www.statcan.gc.ca/eng/survey/household/3701) measures&mdash;Statistics Canada's Labour Force Survey is a monthly survey which measures the current state of the Canadian labour market. 


### Data

**Statistics Canada Labour Force Survey**

Labour Force Survey data are sourced from the [Statistics Canada Labour Force Survey](https://www.statcan.gc.ca/eng/survey/household/3701), released under the [Statistics Canada Open Licence](https://www.statcan.gc.ca/eng/reference/licence), using the [`cansim` R package](https://mountainmath.github.io/cansim/index.html):
  
 - [Statistics Canada Table **14-10-0287-03**: Labour force characteristics by province, monthly, seasonally adjusted](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410028703)
 - [Statistics Canada Table **14-10-0293-02**: Labour force characteristics by economic region, three-month moving average, unadjusted for seasonality](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410029302)
 - [Statistics Canada Table **14-10-0288-01**: Employment by class of worker, monthly, seasonally adjusted and unadjusted, last 5 months](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410028801) 
 
 <!--
 - [Statistics Canada Table **14-10-0127-01**: Reason for not looking for work, monthly, unadjusted for seasonality](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410012701&pickMembers%5B0%5D=1.11&pickMembers%5B1%5D=3.1&pickMembers%5B2%5D=4.1) 
 -->
 
**British Columbia Census Economic Regions**

[Current Census Economic Regions](https://catalogue.data.gov.bc.ca/dataset/1aebc451-a41c-496f-8b18-6f414cde93b7) geospatial data, released under the [Statistics Canada Open Licence](https://www.statcan.gc.ca/eng/reference/licence), are sourced from the B.C. Data Catalogue using the [`bcdata` R package](https://bcgov.github.io/bcdata/).



### Usage

This report is built with the [`flexdashboard` R package](https://rmarkdown.rstudio.com/flexdashboard/) using the `lfs-prototype.Rmd` script. Data are sourced and tidied in the `get-data.R` script. Required R packages are listed (and loaded) with the `setup.R` script.


### Project Status
In progress

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/labour-force-survey-digest/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

```
Copyright 2020 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```
---
*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.* 

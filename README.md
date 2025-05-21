# Background

Scripts in this repository produce figures to describe current impacts of wildfire in California in support of the Wildfire and Forest Resilience Task Force. 

Figures produced were based on those published in “California’s Year in Fire 2021 Report”. 

Most recent csv files available used to create figures is stored in “Data” folder. This does not include any raster files because of file size. Links to download raw data are available in descriptions of figures below.

Script to produce each figure is listed below the figure name. Authorship of script is included within file. Descriptions of figures, data sources, and workflows were written by Lauren Cox and Yihong Zhu.

# Figures

## Total acres burned by wildfire 

**Script:** TF_acres_cause_structures.R

**Data Source:** https://data.ca.gov/dataset/california-fire-perimeters-all

**Earliest Data Available:** 1878

**Most Recent Update:** 2024 (uploaded May 2025)

**Format of Data:** Attribute table of GIS layer

**Downloading Data:**

Click “Map”
Click “Download”
Select “csv” to download
Read .csv file into R

**Data Concerns:** NA

**Data Cleaning/Processing:** 
1.	Group by “YEAR_” and calculate the sum of acres burned every year;
2.	5-year average is calculated using zoo::rollmean with align=”right”. For example, the 5-year average in 2010 is the average of 2016-2010.
3.	Large fire is defined by >10k acres; Megafire is defined by >100k acres
4.	To calculate number of large fire, the dataset was first filtered by GIS_ACRES>10K, and then group by YEAR_ to count the number of entries (each entry is a fire)
5.	To calculate number of megafire, the dataset was first filtered by GIS_ACRES>100K, and then group by YEAR_ to count the number of entries (each entry is a fire)
6.	To calculate the acres burned, each filtered data frame was grouped by YEAR_ and summed to get the total acres burned.

## Total acres burned by cause by year

**Script:** TF_acres_cause_structures.R

**Data Source:** https://data.ca.gov/dataset/california-fire-perimeters-all

**Earliest Data Available:** 1878

**Most Recent Update:** 2024 (uploaded May 2025)

**Format of data:** Attribute table of GIS layer

**Downloading Data:**

Click “Map”
Click “Download”
Select “csv” to download
Read .csv file into R

**Data Concerns:** NA

**Data Cleaning/Processing:**
1.	The initial CAUSE column only has numbers, so creates a new cause_type column based on the data dictionary (e.g 1=Lightning).
2.	We classify the 20 causes into 4 main categories: Lightning, Electric Power (=Powerline in the dataset), Undetermined (=Unknown/Undefined); Human (the rest of causes that do not belong to above 3 causes)
3.	The data frame is grouped by cause_group and YEAR, and then calculate the acres burned by each cause_group in each year.
4.	To ease interpretation, 2004-2013 and 2014-2024 are plotted separately in two figures.

## Residential Structures Damaged or Destroyed

**Script:** TF_acres_cause_structures.R

**Data Sources:** https://data.ca.gov/dataset/cal-fire-damage-inspection-dins-data
https://data.ca.gov/dataset/california-fire-perimeters-all

**Earliest Data Available:** DINS data = 2014

**Most Recent Update:** 2024 (uploaded May 2025)

**Format of data:** Attribute table of GIS layer

**Downloading Data:**

Click “Map”
Click “Download”
Select “csv” to download
Read .csv file into R

**Data Concerns:** 
Fire perimeter data and damage data both appear to be reported by calendar year.
Is Task Force usually reporting their data by calendar year? If not, do we need to change?

**Data Cleaning/Processing:**
1.	Convert the column of Incident.Start.Date to date format
2.	Classify structures into Residential ("Single Residence", "Mixed Commercial/Residential", "Multiple Residence" and Non-Residential (all the rest structure types)
3.	Filter the “Damage” column and remove “No Damage” entries.
4.	Group by structure type and year of incident start date, and then calculate the number of entries of each type in each year.

## Fatalities

**Script:** TF_fatalities.R

**Data Source:** CALFIRE Fire Season Incident Archives (https://www.fire.ca.gov/incidents/2024)

**Earliest Data Available:** 2012

**Most Recent Update:** 2025 (stays current)

**Format of data:** Available online, transferred data to csv file manually. 

**Downloading data:** NA

**Data Concerns:** This only includes fatalities recorded by CALFIRE. There is uncertainty to the number of firefighter fatalities - data before 2021 do not differentiate between civilian and firefighter fatalities. 

**Data Cleaning/Processing:** Data used as presented for the figure. 

## Acres burned in broadcast burning (prescribed fire)

**Script:** TF_rxfire.R
 
**Data Sources:** https://www.fire.ca.gov/what-we-do/fire-resource-assessment-program/fire-perimeters
		https://wildfiretaskforce.org/treatment-dashboard/ (GDB download available at bottom of page)

**Earliest Data Available:** 1908 for CALFIRE prescribed fire perimeters; 2021 for ITS prescribed fire footprint acres

**Most Recent Update:** 2024 data available for CALFIRE as of May 2025; 2024 data for ITS should be available in 2025; Because ITS data for 2024 is currently unavailable, figure only reflects through 2023. 

**Downloading Data:** 

CALFIRE perimeters:
Download Fire Perimeter Data (all data GDB). 
 
Load geodatabase into ArcGIS Pro and select rxfire_24_1 layer.
 
Export attribute table to csv to use in R.

**Data Concerns:**

From CALFIRE Data Dictionary:
Collection criteria for CAL FIRE units has changed over time as follows:

	~1991: ≥10 acres timber, ≥30 acres brush, ≥300 acres grass, damages or destroys three residence or one commercial structure or does $300,000 worth of damage, or results in loss of life.

	~2002: ≥10 acres timber, ≥50 acres brush, ≥300 acres grass, damages or destroys three or more residential or commercial structures (doesn’t include outbuildings, sheds, chicken coops, etc.), or results in loss of life.

	~2008-present: ≥10 acres timber, ≥50 acres brush, ≥300 acres grass, damages or destroys three or more structures or does $300,000 worth of damage, or results in loss of life.

Prescribed fires are given a treatment and agency category. Prior to 1970, the state was the only mentioned agency. Treatment categories include: broadcast burning, jackpot burning, pile and burn (hand and mechanical), and “fire use”. For consistency between the CALFIRE and ITS datasets, we only used the “broadcast burning” acres reported. 

Note that there are differences in the total acres burned using prescribed fire from 2021-2023 between the CALFIRE and ITS datasets. 

**Data Cleaning/Processing for Figure:** 

For consistency between the CALFIRE and ITS datasets, we only used the “broadcast burning” acres reported.

## Footprint Acres Treated

**Script:** TF_footprintacres.R
 
**Data Source:** https://wildfiretaskforce.org/treatment-dashboard/ (GDB download available at bottom of page)

**Earliest Data Available:** 2021

**Most Recent Update:** 2023 (updated Dec. 2024). 2024 data for ITS should be available in 2025

**Downloading Data:**
ITS footprint acres:

Download GDB. 
 
Load geodatabase into ArcGIS Pro.
 
Export attribute table to csv to use in R.

**Data Concerns:**

**Data Cleaning/Processing for Figure:** Data used as presented. 

## Acres Burned by Severity

**Script:** TF_severity.R (figure)
mtbs_ownership_yearly.R (analysis of raw rasters to create csv for figure)
 
**Data Source:** https://www.mtbs.gov/direct-download

**Earliest Data Available:** 1984

**Most Recent Update:** 2022 is the most recent complete dataset. 2023 dataset expected in August 2025 (based on previous year updates)

**Downloading Data:**
Download the Burn Severity Mosaics for (region = California) for the desired years. 
Use information in the mtbs_ownership_yearly.R script to extract information about burn severity. 
Use TF_severity.R to plot figure.

**Data Cleaning/Processing for Figure:** MTBS data used as downloaded. For ownership information, file from SIG (link provided in mtbs_ownership_yearly.R script) is used. 

## Fire Return Interval Departure

**Script:** TF_FRID.R (includes script for condition class figure and surplus/deficit figure)
 
**Data Source:** https://www.fs.usda.gov/detail/r5/landmanagement/gis/?cid=STELPRDB5327836

**Earliest Data Available:** NA

**Most Recent Update:** 2022 is the most recent complete dataset. 

**Downloading Data:** Download 12 datasets from Region 5 Spatial Geodata website: https://www.fs.usda.gov/detail/r5/landmanagement/gis/?cid=STELPRDB5327836

**Data Cleaning/Processing for Figure:** Note Some FRID datasets extend to outside the state of California – must clip to state boundaries.

Use the clip (analysis) function in ArcGIS pro to clip the NorthSierra22_1, NorthCoast22_1_East, and GreatBasin22_1 shapefiles to be within the state of California. 

Clip (analysis) > Input Features = NorthSierra22_1, NorthCoast22_1_East, and GreatBasin22_1. 
Clip Features = CA_State. 
Output Features = NorthCoast22_1_East_Clip (saved in project gdb). 

Calculate area using “Calculate Geometry” Tool. 

Save each shapefile’s attribute table as csv. Use the clipped ones so that it does not exceed state boundaries.

Note: The Central Coast subregion has slightly different column names than the other subregions and must be changed before having a completely merged dataset. 

COMPLETE merged attribute table saved as FRID_merge_complete.xlsx.

Using this dataset, created stacked bar figures in R (TF_FRID.R for script). 

# Script for calculating areas at each fire severity (MTBS)
#  by ownership class 
#  using MTBS CA mosaics, by year 

# Author: Dawn Nekorchuk dnekorchuk@sig-gis.com
# Date: 2024-12-02

# In general, we will be calculating the pixel counts of 
#  combinations of MTBS severity category & agency ownership information.
# First we will need to rasterize the ownership information. 
# Then we will loop over the years, and calculate crosstabs 
#  for each year with the ownership raster. 
# Finally we will append all years together, and calculate
#  areas from the pixel counts. 


### Library ------------------------------------------------

#pacman to load packages as it will autoinstall missing ones
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  #general data science packages
  tidyverse,
  #for rasters
  terra,
  #for shapefiles/vector data
  sf,
  #for nice colors in plots
  viridis) 

### User settings ---------------------------------------------

#just a date text string to use for versions (if run multiple times)
stamp <- format(Sys.time(), "%Y%m%d")

#** ADJUST THE FOLDER AS NEEDED ** 
folder_out <- file.path("phase2", "data", "tx_criteria", "mtbs", 
                        paste0("areas_own_", stamp))
dir.create(folder_out, recursive = TRUE)

#1 meter = 0.000247105 acre
conversion_m2_acres <- 0.000247105

### Data import ----------------------------------------------

## Fire Severity data source
# https://mtbs.gov/direct-download
# "Burn Severity Mosaics" tab
# Select "California" for region

#Severity label descriptions
mtbs_labels <- tibble(mtbs_severity = 1:6, 
                      severity_desc = c("unburned_low", "low", 
                                        "moderate", "high", 
                                        "increased_greenness", "nonprocessing"))


#**FOLDER WHERE THE DOWNLOADED MTBS RASTERS ARE**
folder_mtbs <- file.path("phase2", "data", "spatial", "fromMTBS_originals")

files_mtbs <- list.files(folder_mtbs,
                         #files like "mtbs_CA_{YEAR}.tif"
                         pattern = "mtbs_CA_\\d*\\.tif$",
                         full.names = TRUE,
                         recursive = FALSE)

files_mtbs
# [1] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2014.tif"
# [2] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2015.tif"
# [3] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2016.tif"
# [4] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2017.tif"
# [5] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2018.tif"
# [6] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2019.tif"
# [7] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2020.tif"
# [8] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2021.tif"
# [9] "phase2/data/spatial/fromMTBS_originals/mtbs_CA_2022.tif"

targets_mtbs <- as_tibble_col(files_mtbs, "mtbs_filepath") %>% 
  mutate(filename = tools::file_path_sans_ext(basename(mtbs_filepath)),
         #programmatically pull year value from filename
         year = as.numeric(str_split_i(filename, "_", 3)))


# Note: CRS is ESRI:102039 - USA_Contiguous_Albers_Equal_Area_Conic_USGS_version
# This is a custom ESRI coordinate reference system
# (but is equivalent to EPSG:5070 NAD83 / Conus Albers). 
# As most of our data is in this coordinate reference system,
#  this is what we will use. 
# Note: The extents of each file differ year to year 
#  (depending on where the fires were).

mtbs_eg <- terra::rast(files_mtbs[[1]])
#will use this to set ownership projection below
crs_mtbs <- crs(mtbs_eg)


## Ownership data source:
# https://gsal.sig-gis.com/portal/apps/mapviewer/index.html?layers=a24e5cc165c54ba48d38557495b73a7b

#**FILE PATH FOR OWNERSHIP SHAPEFILE**
own_v <- sf::st_read(file.path("phase2", "data", "spatial", "fromSIG_originals",
                               "CalFire_Ownership_Update",
                               "CalFire_Ownership_Update.shp"))

# After running 'rasterize ownership' section, 
#  can load that result directly instead 
# own <- terra::rast(file.path("phase2", "data", "tx_criteria", "mtbs", 
#                              "areas",
#                              "own_all_20241127.tif"))

# Note: CRS is EPSG:3310 - NAD83 / California Albers
# We will project to the MTBS raster data CRS so that they are the same. 

own_proj <- sf::st_transform(own_v, crs=crs_mtbs)

### Rasterize ownership -----------------------------------------

# Note: the vector ownership data is slow to work with. 
# Do not plot directly, it will take a long time to return. 
# If you want to view it directly, I suggest using QGIS or similar tool. 

# There are a couple of ways that this could have been done. 
# I am choosing to rasterize the ownership information and 
#   overlay that with the MTBS rasters at a pixel level. 
# You could also try to have done zonal extractions with the ownership data, 
#   but I found this to be much much slower, and you have to account or acknowledge
#   zonal summary functions that do or do not have partial pixel coverage support. 

# "agncy_lev" is the field that has Agency-level ownership categories (e.g. "FEDERAL")
own_proj$agncy_lev %>% unique() %>% sort()
# [1] "FEDERAL"              "LOCAL"                "NGO"                  "PRIVATE_INDUSTRY"    
# [5] "PRIVATE_NON-INDUSTRY" "STATE"                "TRIBAL"  

# Make a category levels table. Rasters can only be numeric values
own_levels <- tibble(agency = own_proj$agncy_lev %>% unique() %>% sort()) %>% 
  mutate(agency_id = row_number())
# agency               agency_id
# <chr>                   <int>
# 1 FEDERAL                     1
# 2 LOCAL                       2
# 3 NGO                         3
# 4 PRIVATE_INDUSTRY            4
# 5 PRIVATE_NON-INDUSTRY        5
# 6 STATE                       6
# 7 TRIBAL                      7                     

# Add numeric value to ownership data
own_proj <- own_proj %>% 
  left_join(own_levels, 
            by = join_by(agncy_lev==agency))

# Rasterize
# Based on pixel locations in an MTBS raster to align pixels, 
#  but with full extent of agency data
mtbs_eg_ag <- terra::extend(mtbs_eg, own_proj)

own_r <- terra::rasterize(x=own_proj, 
                          y=mtbs_eg_ag, 
                          field="agency_id", # our new agency id number
                          background=NA) # no data

#add category information to raster
levels(own_r) <- own_levels %>% dplyr::select(agency_id, agency)

plot(own_r)

#optional saving out of ownership raster
terra::writeRaster(own_r,
                   file.path(folder_out,
                             paste0("own_all_", stamp, ".tif")))


### MTBS severity classes by Ownership -----------------------------------

# Note: some fires extend past CA borders into neighboring states
# The full fire footprint in included in the MTBS data. 
# However, the ownership data is limited to CA, so this excess fire data
#  will fall out of the pixels counts (no ownership info). 
# IF you were doing this straight from MTBS rasters, you'd either need
#  to clip to CA boundaries first, or acknowledge that the data includes
#  full fire perimeters of any fire that was partially in CA. 

## Loop per MTBS file (year)
(start_time <- Sys.time())

#initialize collector
all_results <- list()
for (i in (1:nrow(targets_mtbs))){
  
  this_row <- targets_mtbs[i,]
  
  this_mtbs <- terra::rast(this_row[["mtbs_filepath"]])
  #for easier column names later
  # otherwise it has the filename with year in it, 
  # which is more difficult to uniformly/programmatically handle
  names(this_mtbs) <- "mtbs_severity"
  
  this_year <- this_row[["year"]]
  
  #to stack, the extents must match, 
  # so we will match on the (smaller) mtbs file for this year
  this_own <- terra::crop(own_r, this_mtbs)
  
  #stack ownership with the this year mtbs raster
  this_stack <- c(this_own, this_mtbs)
  
  #~15 min per year on a high powered machine
  #calculate cross raster frequencies (cell counts)
  this_ct <- terra::crosstab(this_stack, long=TRUE) %>% as_tibble()
  
  #add year as column
  this_results <- this_ct %>%
    mutate(year = this_year) %>%
    rename(pixel_count = n) %>% 
    #reorder columns
    dplyr::select(year, mtbs_severity, agency, pixel_count)
  
  all_results[[i]] <- this_results
}

all_pixel_counts <- do.call(bind_rows, all_results)

#calculate areas
all_areas <- all_pixel_counts %>%
  #a pixel here is 30m by 30m; this is the resolution of mtbs rasters
  mutate(area_m2 = pixel_count * 30 * 30,
         area_ac = area_m2 * conversion_m2_acres) %>% 
  #add MTBS descriptions
  left_join(mtbs_labels, by = join_by("mtbs_severity")) %>% 
  #arrange columns
  dplyr::select(year, mtbs_severity, severity_desc, 
                agency, area_ac,
                area_m2, pixel_count)

(end_time <- Sys.time())
(end_time-start_time)

#save results in desired format
saveRDS(all_areas, file.path(folder_out,
                             paste0("mtbs_severity_acres_ownership_2014_2022_", stamp, ".RDS")))

write_csv(all_areas, file.path(folder_out,
                               paste0("mtbs_severity_acres_ownership_2014_2022_", stamp, ".csv")))


### Year summary ----------------------------------------
#If you also wanted a summary by year without ownership information
# we can group and summarize the data by year

yr_summary <- all_areas %>% 
  group_by(year, mtbs_severity, severity_desc) %>% 
  summarize(tot_acres = sum(area_ac), 
            .groups = "drop") %>% 
  #remove not-relevant mtbs categories (inc green, nonprocessing)
  filter(!mtbs_severity %in% c(5, 6))

write_csv(all_areas, file.path(folder_out,
                               paste0("mtbs14_severity_acres_2014_2022_", stamp, ".csv")))

### Graphing ------------------------------------------

# Year summary first

# Make severity desc a factor with the order we want on the graph
yr_summary <- yr_summary %>% 
  mutate(severity_desc = factor(severity_desc, 
                                levels=c("unburned_low", #1
                                         "low", #2
                                         "moderate",#3
                                         "high"))) #4


#plot yearly bar chart 
p_yr <- ggplot() + 
  geom_col(data=yr_summary,
           mapping=aes(x=as.factor(year), y=tot_acres,
                       fill=severity_desc, group=severity_desc),
           position = position_dodge()) + 
  scale_fill_viridis("MTBS Severity", discrete=TRUE, 
                     #use plasma colors, but truncate color range to 
                     # end in orange (0.9) not yellow (1)
                     # because it's too light. 
                     option="plasma", end = 0.9) + 
  theme_bw() + 
  labs(title="Total burned acres by year by MTBS severity class",
       x="Year", y="Acres")
p_yr

ggsave(plot=p_yr, 
       filename=file.path(folder_out, 
                          paste0("severity_acres_yearly_", stamp, ".jpg")),
       height=4.5, width=6.5, units=c("in"))


# Facet graph by ownership
own_summary <- all_areas %>% 
  #remove not-relevant mtbs categories (inc green, nonprocessing)
  filter(!mtbs_severity %in% c(5, 6)) %>% 
  mutate(severity_desc = factor(severity_desc, 
                                levels=c("unburned_low", #1
                                         "low", #2
                                         "moderate",#3
                                         "high"))) #4

p_own_yr <- ggplot() + 
  geom_col(data=own_summary,
           mapping=aes(x=as.factor(year), y=area_ac,
                       fill=severity_desc, group=severity_desc),
           position = position_dodge()) + 
  scale_fill_viridis("MTBS Severity", discrete=TRUE, 
                     #use plasma colors, but truncate color range to 
                     # end in orange (0.9) not yellow (1)
                     # because it's too light. 
                     option="plasma", end = 0.9) + 
  theme_bw() + 
  labs(title="Yearly burned acres by MTBS severity class and land ownership",
       x="Year", y="Acres") + 
  #a facet for each ownership group
  facet_wrap(~agency, ncol=4) + 
  #a lot more adjustment for nicer graph
  theme(
    plot.title = element_text(size=9),
    strip.text = element_text(size=7),
    axis.title = element_text(size=8),
    axis.text.y = element_text(size=7),
    axis.text.x = element_text(size=7, angle=-45, hjust=0.3, vjust=0),
    legend.title = element_text(size=8),
    legend.text = element_text(size=8))
p_own_yr

ggsave(plot=p_own_yr, 
       filename=file.path(folder_out, 
                          paste0("severity_acres_yearly_ownership_", stamp, ".jpg")),
       height=4, width=8, units=c("in"))


#######################
# Radiance data processing
######################
# libraries
library(raster)

######################
# directory locations (some files outside of github due to size)
out_dir = "/Users/cfaust/Documents/workspace/pageocov_large_files/output"
shp_dir = '/Users/cfaust/Documents/workspace/pageocov_large_files/shapefiles'
large_dir = '/Users/cfaust/Documents/workspace/pageocov_large_files'

# importing geotiffs
# these can be generated from raw data using 'radiance_*.py'  scripts
daily_files = list.files(file.path(large_dir, 'confident_clear_only/vnp46a1'), pattern = ".tif", full.names = TRUE)
daily_data = lapply(daily_files, raster) # raster list

#####################
# population centres - identified with population densities from WorldPop
# bellefonte and state college
centre_focal = raster(file.path(shp_dir, "bellefonte_statecollege_raster.tif")) 
centre_focal2 = resample(centre_focal, daily_data[[1]], method = 'bilinear') #
bellefonte = calc(centre_focal2,
                  fun=function(x){ x[x >  1.1] <- NA ; return(x)} )
state = calc(centre_focal2,
             fun=function(x){ x[x <  1.1] <- NA ; return(x)} )

# cropping, masking and stacking
daily_masked = lapply(daily_data, raster::crop, centre_focal2) 
daily_masked = lapply(daily_masked, raster::mask, centre_focal2) 
raw_maskedst = stack(daily_masked)


bellefonte_stack = raster::mask(raw_maskedst, bellefonte)
state_stack = raster::mask(raw_maskedst, state)

writeRaster(raw_maskedst,file.path(out_dir,"daily_stacked_wmoon.grd"), format="raster")
writeRaster(state_stack,file.path(out_dir,"state_daily_stack_wmoon.grd"), format="raster")
writeRaster(bellefonte_stack,file.path(out_dir,"bellefonte_daily_stack_wmoon.grd"), format="raster")



quarts <- c(0,0.25, 0.5, 0.75,1)
p_names <- purrr::map_chr(quarts, ~paste0(.x*100, "%"))
p_funs <- purrr::map(p, ~partial(quartile, probs = .x, na.rm = TRUE)) %>% 
  set_names(nm = p_names)
quartiles_df = summary_df %>% 
  group_by(phase_year, area) %>% 
  summarize_at(vars(radiance), funs(!!!p_funs))


#adjusting dataframe 
quarts$year = gsub(".*_", "", quarts$phase_year)
quarts$year_fac = as.factor(quarts$year)
quarts$phase = gsub("_.*", "", quarts$phase_year)
quarts$phase = as.factor(quarts$phase)
quarts$phase = factor(quarts$phase,  levels =c('red', 'yellow','green'))
quarts$quartile = as.factor(quarts$quartile)
quarts$quartile = factor(quarts$quartile,
                         levels = c('first', 'second','third','fourth'))
quarts$area = as.factor(quarts$area)
quarts$area = factor(quarts$area, levels = c('state college', 'bellefonte'))

write.csv(quartiles_df,'output/quartiles.csv')
quarts = read.csv('output/quartiles_annotated.csv')




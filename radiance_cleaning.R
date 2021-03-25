

# importing geotiffs 
daily_files = list.files(file.path(large_dir, 'confident_clear_only/vnp46a1'), pattern = ".tif", full.names = TRUE)
daily_data = lapply(daily_files, raster) # raster list

# bellefonte and state college
centre_focal = raster(file.path(shp_dir, "bellefonte_statecollege_raster.tif")) 
centre_focal2 = resample(centre_focal, daily_data[[1]])

# cropping, masking and stacking
daily_masked = lapply(daily_data, raster::crop, centre_focal2) 
daily_masked = lapply(daily_masked, raster::mask, centre_focal2) 
raw_maskedst = stack(daily_masked)

# phase - year summaries 
target_phases = c('red_2016','yellow_2016', 'green_2016',
                  'red_2017','yellow_2017', 'green_2017',
                  'red_2018','yellow_2018', 'green_2018',
                  'red_2019','yellow_2019', 'green_2019',
                  'red_2020','yellow_2020', 'green_2020')

stacked_raw_mean = stack()
for (i in 1: length(target_phases)){
  #i = 1
  x = calc(raster::subset(raw_maskedst, which(daily_df$phase_yr2 %in% target_phases[i])), mean, na.rm = TRUE)
  stacked_raw_mean = stack(stacked_raw_mean, x)
}
names(stacked_raw_mean) = target_phases

bellefonte = calc(centre_focal2,
                  fun=function(x){ x[x >  1.1] <- NA ; return(x)} )
bellefonte_stack = raster::mask(stacked_raw_mean, bellefonte)

state = calc(centre_focal2,
             fun=function(x){ x[x <  1.1] <- NA ; return(x)} )
state_stack = raster::mask(stacked_raw_mean, state)

writeRaster(state_stack,file.path(out_dir,"bellefonte_mean_phases_womoon.grd"), format="raster")
writeRaster(bellefonte_stack,file.path(out_dir,"bellefonte_mean_phases_womoon.grd"), format="raster")

quarts <- c(0,0.25, 0.5, 0.75,1)
p_names <- purrr::map_chr(quarts, ~paste0(.x*100, "%"))
p_funs <- purrr::map(p, ~partial(quartile, probs = .x, na.rm = TRUE)) %>% 
  set_names(nm = p_names)
quartiles_df = summary_df %>% 
  group_by(phase_year, area) %>% 
  summarize_at(vars(radiance), funs(!!!p_funs))
write.csv(quartiles_df,'output/quartiles.csv')
quarts = read.csv('output/quartiles_annotated.csv')

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

bellefonte_df = as.data.frame(rasterToPoints(bellefonte_stack))
state_df = as.data.frame(rasterToPoints(state_stack))

bellefonte_long <- melt(bellefonte_df, id.vars=c("x", "y"),
                        variable.name="phase_year", value.name="radiance")
state_long <- melt(state_df, id.vars=c("x", "y"),
                   variable.name="phase_year", value.name="radiance")
bellefonte_long$area = 'bellefonte'
state_long$area = 'state college'
summary_df = rbind(state_long, bellefonte_long)
summary_df$year = gsub(".*_", "", summary_df$phase_year)
summary_df$year_fac = as.factor(summary_df$year)
summary_df$phase = gsub("_.*", "", summary_df$phase_year)
summary_df$phase = as.factor(summary_df$phase)
summary_df$phase = factor(summary_df$phase, 
                          levels =c('red', 'yellow','green'))


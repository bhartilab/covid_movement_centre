#######################
# Radiance Analysis
######################
# libraries
library(raster)
library(reshape2)
library(ggplot2)
library(purrr)
library(dplyr)

######################
# directory locations (some files outside of github due to size)
out_dir = "/Users/cfaust/Documents/workspace/pageocov_large_files/output"
shp_dir = '/Users/cfaust/Documents/workspace/pageocov_large_files/shapefiles'
large_dir = '/Users/cfaust/Documents/workspace/pageocov_large_files'

#####################
# importing geotiffs 
raw_maskedst = stack(file.path(out_dir,"stack_vnp46a1_confident_clear_masked.gri"))
daily_df = read.csv('output/radiance_index_dataframe.csv', header = TRUE)


state_stack = stack(file.path(out_dir,"state_college_mean_phases_womoon.grd"))
bellefonte_stack = stack(file.path(out_dir,"bellefonte_mean_phases_womoon.grd"))


########################
# quartiles

ggplot(quarts, aes(x =phase, max, col = quartile, group = year_fac, fill = year_fac))+ 
  geom_crossbar(aes(ymin=min, ymax=max ), position=position_dodge(0.9)) +
  theme_classic()+
  scale_y_continuous(breaks = seq(0,110,by=10), expand = c(0,0))+#limits = c(0,110),
  facet_wrap(area~.,  scales = 'free_y')+ #scales = 'free_y',ncol = 1
  scale_fill_manual(values = yr_col)+
  scale_color_manual(values = c('grey70','grey50','grey30', 'grey10'))+
  labs(y = 'radiance (nW/cm2)', x = 'restriction phases', 
       fill = 'year')

##
# This scripts extracts visit, visitor, and device data for Centre County, PA CBG tractcodes from SafeGraph datasets.
#
# Instructions for acquiring the datasets are available here:
# https://catalog.safegraph.io/app/browse
#
# Datasets are divided, presently, into datasets which backfill prior to December 2020, and datasets for which 
# collection is on-going from December 2020.  
#
# SafeGraph delivers these datasets with slightly different directory structures, which requires that we process them
# separately.  Plausible examples of the strings that will be needed to glob all needed data files follow, but will need
# to be changed to match the precise directory locations to which the SafeGraph datasets have been downloaded.
# 
# Specifically, the backfilled data must glob three subpaths, and on-going data must glob four subpaths.
#
# After successfully executing this script, extracted visit data files will all have the following format:
# '*-centre-cbg.csv' and extracted 'devices residing' data files will have the format:
# '*-centre-cbg-home_panel_summary.csv'
#
# Executing 'create_centre_county_dataframes.py' will summarize data across all CBG tractcodes to produce sums of visits,
# visitors, and devices for all of Centre County.

# Glob String for Weekly Patterns Backfill:
WEEKLY_PATTERNS_BACKFILL_ROOT_GLOB = "/Volumes/ELEMENTS/safegraph/weeklyPlacesDec2020BackFill/patterns_backfill/2020/12/14/21/*/*/*/*.gz"

# Glob String for Weekly Patterns On-Going:
WEEKLY_PATTERNS_ONGOING_ROOT_GLOB = "/Volumes/ELEMENTS/safegraph/weeklyPlaces20201130toPresent/patterns/*/*/*/*/*.gz"


# Glob String for Home Panel Summary files from Backfill:
HOME_PANEL_BACKFILL_ROOT_GLOB = "/Volumes/ELEMENTS/safegraph/weeklyPlacesDec2020BackFill/home_panel_summary_backfill/2020/12/14/21/*/*/*/home_panel_summary.csv"

# Glob String for Home Panel Summary files, On-Going:
HOME_PANEL_ONGOING_ROOT_GLOB = "/Volumes/ELEMENTS/safegraph/weeklyPlaces20201130toPresent/home_panel_summary/*/*/*/*/home_panel_summary.csv"



# Eleven-digit census tractcodes that cover Centre County, PA
centre_tractcodes=[
"42027010100",
"42027010200",
"42027010300",
"42027010400",
"42027010500",
"42027010600",
"42027010700",
"42027010800",
"42027010900",
"42027011000",
"42027011100",
"42027011201",
"42027011300",
"42027011400",
"42027011501",
"42027011502",
"42027011600",
"42027011702",
"42027011800",
"42027011901",
"42027011902",
"42027012000",
"42027012100",
"42027012200",
"42027012300",
"42027012400",
"42027012500",
"42027012600",
"42027012700",
"42027012800",
"42027981202"]

## 
#
# Extract visit data from raw SafeGraph-delivered datasets 
#
# ==== Parameters
#
# * +globstring+ - A glob string which matches all needed gzipped data files 
# * +type+ - A string, if "backfill" we make an assumption about directory structure 
# * +tractcodes+ - An array of strings, each an 11-digit CBG tract code 
#
def selectCentreCountyEntriesFromWeeklyPatterns(globstring,type,tractcodes)

  files = Dir.glob(globstring)

  files.each{|f|

    t = f.split("/")
    ts = t.size
    gzipped_visit_file = File.basename(f)
    unzipped_visit_file = gzipped_visit_file.gsub(/.gz/,'')

    centre_cbgfn = ""
    # for BACKFILL:
    if(type=="backfill") then
      # Need last three subpaths to determine date of data
      centre_cbgfn += t[(ts-4),(ts-2)].join('-')
    else
      centre_cbgfn += t[(ts-5),(ts-2)].join('-')
    end 

    centre_cbgfn += "-centre-cbg-#{unzipped_visit_file}"
    centre_cbgfn_final = centre_cbgfn.gsub(/-patterns-part\d.csv.gz/,'')


    if File.exist?(centre_cbgfn_final) then
      puts("#{centre_cbgfn_final} already exists; skipping")
    else
      system("cp #{f} .")
      puts("unzipping #{gzipped_visit_file}")
      system("gunzip #{gzipped_visit_file}")

      centre_cbgs = ""

      puts("Opening #{unzipped_visit_file}")

      File.open(unzipped_visit_file).each_line{|n|
        if n =~/,PA,/ then
          tractcodes.each{|z|
            if n =~/,#{z}\d,/ then
              centre_cbgs << n
            end
          }
        end
      }
      puts("Writing #{centre_cbgfn_final}")
      File.open(centre_cbgfn_final,'w').write(centre_cbgs)
      system("rm #{unzipped_visit_file}")
    end
  }
end

## 
#
# Extract device residing data from raw SafeGraph-delivered datasets 
#
# ==== Parameters
#
# * +globstring+ - A glob string which matches all needed home panel summary data files 
# * +type+ - A string, if "backfill" we make an assumption about directory structure 
# * +tractcodes+ - An array of strings, each an 11-digit CBG tract code 
def selectCentreCountyEntriesHomePanel(globstring,type,tractcodes)

  files = Dir.glob(globstring)

  files.each{|f|

    puts(f)

    t = f.split("/")
    ts = t.size
    homepanel_file = File.basename(f)
    puts(homepanel_file)

    centre_cbgfn = ""
    # for BACKFILL:
    if(type=="backfill") then
      # Need last three subpaths to determine date of data
      centre_cbgfn += t[(ts-4),(ts-4)].join('-')
    else
      centre_cbgfn += t[(ts-5),(ts-2)].join('-')
    end 

    centre_cbgfn.gsub!(/#{homepanel_file}/,"centre-cbg-#{homepanel_file}")


    if File.exist?(centre_cbgfn) then
      puts("#{centre_cbgfn} already exists; skipping")
    else

      centre_cbgs = ""

      puts("opening #{f}")

      File.open(f).each_line{|n|
        if n =~/,pa,/ then
          tractcodes.each{|z|
            if n =~/,#{z}\d,/ then
              centre_cbgs << n
            end
          }
        end
      }
      puts("Writing #{centre_cbgfn}")
      File.open(centre_cbgfn,'w').write(centre_cbgs)
    end
  }
end



# Extract Centre County POI visits from backfill:
selectCentreCountyEntriesFromWeeklyPatterns(WEEKLY_PATTERNS_BACKFILL_ROOT_GLOB,"backfill",centre_tractcodes)

# Extract Centre County POI visits from on-going data:
selectCentreCountyEntriesFromWeeklyPatterns(WEEKLY_PATTERNS_ONGOING_ROOT_GLOB,"ongoing",centre_tractcodes)

# Join components from each weekly dataset:
files = Dir.glob("*-centre-cbg-patterns-part1.csv")
files.each{|f|
  x = f.gsub(/part1/,"part*")
  puts(x)
  dx = f.gsub(/-patterns-part1/,"")
  system("cat #{x} > #{dx}")
}



# Extract Centre County POI visits from backfill:
selectCentreCountyEntriesHomePanel(HOME_PANEL_BACKFILL_ROOT_GLOB,"backfill",centre_tractcodes)

# Extract Centre County POI visits from on-going data:
selectCentreCountyEntriesHomePanel(HOME_PANEL_ONGOING_ROOT_GLOB,"ongoing",centre_tractcodes)

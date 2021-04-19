getphase <- function(dates) { # function for assigning dates to phase
  # dates = as.Date("2020-03-05")
  #dates =  as.Date(indexing$date)
  years = 2018:2020
  y = strftime(dates, format="%Y")
  i = match(y, years)
  
  snow = c(as.Date("2020-02-09",  format = "%Y-%m-%d"),
           as.Date("2020-02-08",  format = "%Y-%m-%d"),
           as.Date("2020-02-14",  format = "%Y-%m-%d")) #2020
  students = c(as.Date("2020-03-02",  format = "%Y-%m-%d"),
               as.Date("2020-03-01",  format = "%Y-%m-%d"),
               as.Date("2020-03-06",  format = "%Y-%m-%d")) #2020
  local = c(as.Date("2020-03-12",  format = "%Y-%m-%d"),
            as.Date("2020-03-11",  format = "%Y-%m-%d"),
            as.Date("2020-03-18",  format = "%Y-%m-%d")) #2020
  red = c(as.Date("2020-03-23",  format = "%Y-%m-%d"),
          as.Date("2020-03-22",  format = "%Y-%m-%d"),
          as.Date("2020-03-27",  format = "%Y-%m-%d")) #2020
  yellow = c(as.Date("2020-05-04",  format = "%Y-%m-%d"),
             as.Date("2020-05-03",  format = "%Y-%m-%d"),
             as.Date("2020-05-08",  format = "%Y-%m-%d")) #2020
  green = c(as.Date("2020-05-25",  format = "%Y-%m-%d"),
            as.Date("2020-05-24",  format = "%Y-%m-%d"),
            as.Date("2020-05-29",  format = "%Y-%m-%d")) #2020
  return = c(as.Date("2020-08-14",  format = "%Y-%m-%d"),
               as.Date("2020-08-20",  format = "%Y-%m-%d"),
               as.Date("2020-08-14",  format = "%Y-%m-%d")) #2020 # matched to friday
  
  d = as.Date(strftime(dates, format="2020-%m-%d"))   # convert dates from any year to 2020 dates (b/c of leap year)
  
  ifelse (d < snow[i], "base1",
          ifelse (d >= snow[i] & d < students[i], "base",
                  ifelse (d >= students[i] & d < local[i], "pop",
                      ifelse (d >= local[i] & d < red[i], "local",
                          ifelse (d >= red[i] & d < yellow[i], "red",
                            ifelse (d >= yellow[i] & d < green[i], "yellow", 
                                    ifelse (d >= green[i] & d < return[i], "green", "return")))))))
}


getphase3 <- function(dates) { # function for assigning dates to phase
  #equal spring breaks
  years = 2016:2020
  y = strftime(dates, format="%Y")
  i = match(y, years)
  
  snow = c(as.Date("2020-02-12",  format = "%Y-%m-%d"), 
           as.Date("2020-02-10",  format = "%Y-%m-%d"),
           as.Date("2020-02-09",  format = "%Y-%m-%d"),
           as.Date("2020-02-08",  format = "%Y-%m-%d"),
           as.Date("2020-02-14",  format = "%Y-%m-%d")) 
  students = c(as.Date("2020-03-04",  format = "%Y-%m-%d"), # 2016 spring break
               as.Date("2020-03-03",  format = "%Y-%m-%d"),
               as.Date("2020-03-02",  format = "%Y-%m-%d"),
               as.Date("2020-03-01",  format = "%Y-%m-%d"),
               as.Date("2020-03-06",  format = "%Y-%m-%d")) #2020
  local = c(as.Date("2020-03-14",  format = "%Y-%m-%d"), # 2016 spring break
            as.Date("2020-03-13",  format = "%Y-%m-%d"),
            as.Date("2020-03-12",  format = "%Y-%m-%d"),
            as.Date("2020-03-11",  format = "%Y-%m-%d"),
            as.Date("2020-03-16",  format = "%Y-%m-%d")) #2020
  red = c(as.Date("2020-03-26",  format = "%Y-%m-%d"), # 2016 spring break
          as.Date("2020-03-25",  format = "%Y-%m-%d"),
          as.Date("2020-03-24",  format = "%Y-%m-%d"),
          as.Date("2020-03-23",  format = "%Y-%m-%d"),
          as.Date("2020-03-28",  format = "%Y-%m-%d")) #2020
  yellow = c(as.Date("2020-05-06",  format = "%Y-%m-%d"), # 2016 spring break
             as.Date("2020-05-05",  format = "%Y-%m-%d"),
             as.Date("2020-05-04",  format = "%Y-%m-%d"),
             as.Date("2020-05-03",  format = "%Y-%m-%d"),
             as.Date("2020-05-08",  format = "%Y-%m-%d")) #2020
  green = c(as.Date("2020-05-27",  format = "%Y-%m-%d"), # 2016 spring break
            as.Date("2020-05-26",  format = "%Y-%m-%d"),
            as.Date("2020-05-25",  format = "%Y-%m-%d"),
            as.Date("2020-05-24",  format = "%Y-%m-%d"),
            as.Date("2020-05-29",  format = "%Y-%m-%d")) #2020
  return = c(as.Date("2020-08-12",  format = "%Y-%m-%d"), # 2016 spring break
             as.Date("2020-08-11",  format = "%Y-%m-%d"),
             as.Date("2020-08-10",  format = "%Y-%m-%d"),
             as.Date("2020-08-09",  format = "%Y-%m-%d"),
             as.Date("2020-08-14",  format = "%Y-%m-%d")) #2020 # matched to friday
  
  d = as.Date(strftime(dates, format="2020-%m-%d"))   # convert dates from any year to 2020 dates (b/c of leap year)
  
  ifelse (d < snow[i], "base1",
          ifelse (d >= snow[i] & d < students[i], "base",
                  ifelse (d >= students[i] & d < local[i], "pop",
                          ifelse (d >= local[i] & d < red[i], "local",
                                  ifelse (d >= red[i] & d < yellow[i], "red",
                                          ifelse (d >= yellow[i] & d < green[i], "yellow", 
                                                  ifelse (d >= green[i] & d < return[i], "green", "return")))))))
}
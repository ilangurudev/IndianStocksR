check_market <- function(market = c("nse", "bse"), include_both = TRUE){
  if(!include_both){
    if(length(market) >= 2){
      if(all(market %in% c("nse", "bse"))){
        message("Downloading from NSE. Market option not specified.")
        "nse"
      } else {
        stop("The specified option for market is not valid.")
      }
    } else if(!market %in% c("nse", "bse")){
      stop("The specified option for market is not valid.")
    } else {
      "nse"
    }
  } else {

  }
}


make_date_url <- function(date, market = c("nse", "bse")){
  if(market == "nse"){
    download_name <- paste0("cm", toupper(as.character(date, "%d%b%Y")), "bhav.csv")

    paste0("https://www.nseindia.com/content/historical/EQUITIES/",
           as.character(date, "%Y"), "/",
           toupper(as.character(date, "%b")), "/",
           download_name, ".zip")
  } else {
    paste0("https://www.bseindia.com/download/BhavCopy/Equity/EQ",
           as.character(date, "%d%m%y"),
           "_CSV.ZIP")
  }
}

download_stocks_nse_bse <- function(date = lubridate::today(), ...){

  download_stocks(date = date, market = "nse", ...)
  download_stocks(date = date, market = "bse", ...)
}

date_validation <- function(date){
  date <- lubridate::as_date(date) %>% suppressWarnings() %>% suppressMessages()

  if((!lubridate::is.Date(date)) | is.na(date)){
    e <- simpleError("Date failed to parse")
    stop(e)
  }

  date
}

date_filename_pattern <- function(date){
  paste0(lubridate::year(date), "_",
  lubridate::month(date) %>% stringr::str_pad(width = 2, side = "left", pad = "0"), "_",
  lubridate::mday(date) %>% stringr::str_pad(width = 2, side = "left", pad = "0"))
}

download_stocks <- function(date = lubridate::today(), market = c("nse", "bse"), dest_path = "./data"){

  date <- try(date_validation(date))
  market <- check_market(market, include_both = FALSE)

  if(dest_path != "./data" & !dir.exists(dest_path)){
    stop("The path you specified does not exist.")
  }

  if(dest_path == "./data" & !dir.exists("./data")){
    dir.create("./data")
  }


  file_name <- paste0(market, "_", date_filename_pattern(date))

  file_name <- paste0(file_name, ".zip")
  dest_file <- paste0(dest_path, "/", file_name)
  url <- make_date_url(date = date, market = market)

  tryCatch(
    {
      download.file(url = url, destfile = dest_file, quiet = TRUE) %>% suppressWarnings()
    },
    error = function(e){
      file.remove(dest_file)
      stop(paste0("No download data available for ",
                     date %>% as.character("%d %b %Y"),
                     ". Either the data is not available yet or the market did not function on that day."))
    },
    warning = function(w){
      file.remove(dest_file)
      stop(paste0("No download data available for ",
                     date %>% as.character("%d %b %Y"),
                     ". Either the data is not available yet or the market did not function on that day."))
    }
  )

  df_download <- suppressWarnings(suppressMessages(readr::read_csv(dest_file)))
  if(market == "nse") df_download$X14 <- NULL
  readr::write_csv(df_download, dest_file %>% stringr::str_replace("zip", "csv"))
  file.remove(dest_file)

  message(paste0("Dowloaded stocks data from ", toupper(market), " on ", toupper(as.character(date, "%d %b %Y"))))
}

download_stocks_period <- function(start = lubridate::today() - 8,
                                   end = lubridate::today(),
                                   market = c("both", "nse", "bse"),
                                   dest_path = "./data",
                                   compile = TRUE,
                                   delete_component_files = TRUE){

  start <- date_validation(start)
  end <- date_validation(end)

  stopifnot(start < end)

  if(market == "both"){
    purrr::walk(start:end, function(x){
      tryCatch(download_stocks_nse_bse(date = x, dest_path),
               error = function(e){
                 message(paste0("No download data available for ",
                                lubridate::as_date(x) %>% as.character("%d %b %Y"),
                                ". Either the data is not available yet or the market did not function on that day."))
                 NULL
               })
    })
  } else {
    purrr::walk(start:end, function(x){
      tryCatch(download_stocks(date = x, market = market, dest_path),
               error = function(e){
                 message(paste0("No download data available for ",
                                lubridate::as_date(x) %>% as.character("%d %b %Y"),
                                ". Either the data is not available yet or the market did not function on that day."))
                 NULL
               })
    })
  }

  if(compile){
    compile_market_data(data_path = dest_path, market = market, delete_component_files)
  }

  message("Stock data downloaded for date range")

}


extract_date <- function(x) stringr::str_extract(x, "[\\d]+_[\\d]+_[\\d]+") %>% lubridate::ymd()


compile_market_data <- function(data_path = "./data",
                                market = c("both", "nse", "bse"),
                                delete_component_files =  TRUE){

  stopifnot(any(market %in% c("nse", "bse", "both")))

  if(length(market) > 1){
    market = "both"
  }

  if(market == "both"){

    df_bse <- compile_market_data(data_path = data_path, market = "bse")
    df_bse$market <- "bse"

    df_nse <- compile_market_data(data_path = data_path, market = "bse")
    df_bse$market <- "nse"

    rbind(df_bse, df_nse)

  } else {

    message(paste("Compiling all and only the available files in the specified directory.",
                  "If the available files contain gaps, then the compiled file will too."))

    files <- paste0(data_path, "/", dir(data_path, pattern = market))

    df_market_compiled <- purrr::map_dfr(files, function(x){

      date <- extract_date(x)
      df_x <- readr::read_csv(x) %>% suppressMessages() %>% suppressWarnings()
      df_x$date <- date
      df_x
    }) %>%
    dplyr::distinct()

    max_date <- dir("./data", pattern = market) %>% extract_date() %>% max()

    if(delete_component_files){
      file.remove(files)
    }

    readr::write_csv(df_market_compiled, paste0(data_path, "/", market, "_compiled_", date_filename_pattern(max_date), ".csv"))

    df_market_compiled
  }

}


update_stocks <- function(data_path = "./data",
                          till = lubridate::today(),
                          market = c("both", "nse", "bse"),
                          compile = TRUE,
                          delete_component_files = TRUE){

  # browser()
  if(market == "both"){
    update_stocks(data_path = data_path,
                  till = till,
                  market = "nse",
                  compile = compile,
                  delete_component_files = delete_component_files)

    update_stocks(data_path = data_path,
                  till = till,
                  market = "bse",
                  compile = compile,
                  delete_component_files = delete_component_files)

  } else {

    files <- dir(path = data_path,
                 pattern = market)
    max_date <- files %>% extract_date() %>% max()
    download_stocks_period(start = max_date + 1,
                           end = till,
                           market = market,
                           dest_path = data_path,
                           compile = compile,
                           delete_component_files = delete_component_files)

  }

}


`%>%` <- function(...){
  purrr::`%>%`(...)
}


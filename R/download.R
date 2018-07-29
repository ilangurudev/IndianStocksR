check_exchange <- function(exchange = c("nse", "bse"), include_both = TRUE){

    if(include_both){
      exchanges <- c("both", "nse", "bse")
    } else{
      exchanges <- c("nse", "bse")
    }

    if(all(exchange %in% exchanges)){
      if(length(exchange) > 1){
        exchange <- ifelse(include_both, "both", "nse")
        message("Downloading from '", exchange, "' as exchange not clearly specified.")
      }
      return(exchange[1])
    } else {
      stop("At least one of the specified options for exchange are not valid.")
    }

}


make_date_url <- function(date, exchange = c("nse", "bse")){
  if(exchange == "nse"){
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

download_stocks_both <- function(date = lubridate::today(), ...){

  download_stocks(date = date, exchange = "nse", ...)
  download_stocks(date = date, exchange = "bse", ...)
}

date_validation <- function(date){
  date <- lubridate::as_date(date) #%>% suppressWarnings() %>% suppressMessages()

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

download_stocks <- function(date = lubridate::today(), exchange = c("nse", "bse"), dest_path = "./data"){

  date <- try(date_validation(date))

  exchange <- check_exchange(exchange, include_both = FALSE)

  if(dest_path != "./data" & !dir.exists(dest_path)){
    stop("The path you specified does not exist.")
  }

  if(dest_path == "./data" & !dir.exists("./data")){
    dir.create("./data")
  }


  file_name <- paste0(exchange, "_", date_filename_pattern(date))

  file_name <- paste0(file_name, ".zip")
  dest_file <- paste0(dest_path, "/", file_name)
  url <- make_date_url(date = date, exchange = exchange)

  tryCatch(
    {
      download.file(url = url, destfile = dest_file, quiet = TRUE) %>% suppressWarnings()
    },
    error = function(e){
      file.remove(dest_file)
      stop(paste0("No download data available for ",
                     date %>% as.character("%d %b %Y"),
                     ". Either the data is not available yet or the exchange did not function on that day."))
    },
    warning = function(w){
      file.remove(dest_file)
      stop(paste0("No download data available for ",
                     date %>% as.character("%d %b %Y"),
                     ". Either the data is not available yet or the exchange did not function on that day."))
    }
  )

  df_download <- suppressWarnings(suppressMessages(readr::read_csv(dest_file)))
  if(exchange == "nse") df_download$X14 <- NULL
  df_download$date <- date
  readr::write_csv(df_download, dest_file %>% stringr::str_replace("zip", "csv"))
  file.remove(dest_file)

  message(paste0("Dowloaded stocks data from ", toupper(exchange), " on ", toupper(as.character(date, "%d %b %Y"))))
}

download_stocks_period <- function(start = lubridate::today() - 8,
                                   end = lubridate::today(),
                                   exchange = c("both", "nse", "bse"),
                                   dest_path = "./data",
                                   compile = TRUE,
                                   delete_component_files = TRUE){

  start <- date_validation(start)
  end <- date_validation(end)
  stopifnot(start < end)

  exchange <- check_exchange(exchange)


  if(exchange == "both"){
    purrr::walk(start:end, function(x){
      tryCatch(download_stocks_both(date = x, dest_path),
               error = function(e){
                 message(paste0("No download data available for ",
                                lubridate::as_date(x) %>% as.character("%d %b %Y"),
                                ". Either the data is not available yet or the exchange did not function on that day."))
                 NULL
               })
    })
  } else {
    purrr::walk(start:end, function(x){
      tryCatch(download_stocks(date = x, exchange = exchange, dest_path),
               error = function(e){
                 message(paste0("No download data available for ",
                                lubridate::as_date(x) %>% as.character("%d %b %Y"),
                                ". Either the data is not available yet or the exchange did not function on that day."))
                 NULL
               })
    })
  }

  if(compile){
    compile_exchange_data(data_path = dest_path, exchange = exchange, delete_component_files)
  }

  message("Stock data downloaded for date range")

}


extract_date <- function(x){
  if(length(x) == 0) return(NA)
  stringr::str_extract(x, "[\\d]+_[\\d]+_[\\d]+") %>% lubridate::ymd()
}


compile_exchange_data <- function(data_path = "./data",
                                exchange = c("both", "nse", "bse"),
                                delete_component_files =  TRUE){

  exchange <- check_exchange(exchange)

  if(exchange == "both"){

    df_bse <- compile_exchange_data(data_path = data_path, exchange = "bse")
    df_bse$exchange <- "bse"

    df_nse <- compile_exchange_data(data_path = data_path, exchange = "nse")
    df_nse$exchange <- "nse"

    df_bse <-
      df_bse %>%
      dplyr::rename(
             symbol = SC_NAME,
             isin = SC_CODE,
             series = SC_TYPE,
             tottrdqty = NO_OF_SHRS) %>%
      dplyr::mutate(series = ifelse(series == "Q", "EQ", series))

    colnames(df_nse) <- tolower(colnames(df_nse))
    colnames(df_bse) <- tolower(colnames(df_bse))

    df_bse <-
      df_bse %>%
      dplyr::rename(volume = tottrdqty) %>%
      dplyr::select(exchange, date, symbol, isin, open, high, low, close, volume, dplyr::everything()) %>%
      dplyr::mutate(isin = isin %>% as.character())


    df_nse <-
      df_nse %>%
      dplyr::rename(volume = tottrdqty) %>%
      dplyr::select(exchange, date, symbol, isin, open, high, low, close, volume, dplyr::everything()) %>%
      dplyr::mutate(isin = isin %>% as.character())

    df_all <-
      dplyr::bind_rows(df_nse, df_bse)
    date_file_name <- dir(data_path) %>% extract_date() %>% min() %>% date_filename_pattern()
    df_all %>% readr::write_csv(paste0(data_path, "/", "all_compiled_", date_file_name, ".csv"))

    df_all

  } else {

    message(paste("Compiling all and only the available files in the specified directory.",
                  "If the available files contain gaps, then the compiled file will too."))

    files <- paste0(data_path, "/", dir(data_path, pattern = exchange))

    df_exchange_compiled <- purrr::map_dfr(files, function(x){

      df_x <- readr::read_csv(x) %>% suppressMessages() %>% suppressWarnings()
      df_x
    }) %>%
    dplyr::distinct()

    max_date <- dir("./data", pattern = exchange) %>% extract_date() %>% max()

    if(delete_component_files){
      file.remove(files)
    }

    readr::write_csv(df_exchange_compiled, paste0(data_path, "/", exchange, "_compiled_", date_filename_pattern(max_date), ".csv"))

    df_exchange_compiled
  }

}


update_stocks <- function(data_path = "./data",
                          till = lubridate::today(),
                          exchange = c("both", "nse", "bse"),
                          compile = TRUE,
                          delete_component_files = TRUE){

  exchange <- check_exchange(exchange)

  if(exchange == "both"){
    update_stocks(data_path = data_path,
                  till = till,
                  exchange = "nse",
                  compile = compile,
                  delete_component_files = delete_component_files)

    update_stocks(data_path = data_path,
                  till = till,
                  exchange = "bse",
                  compile = compile,
                  delete_component_files = delete_component_files)

    compile_exchange_data(exchange = "both", data_path = data_path, delete_component_files = FALSE)

  } else {
    # browser()

    files <- dir(path = data_path,
                 pattern = exchange)

    max_date <- max(extract_date(files))

    if(is.na(max_date)){
      max_date <- lubridate::today() - 8
    }

    download_stocks_period(start = max_date + 1,
                           end = till,
                           exchange = exchange,
                           dest_path = data_path,
                           compile = compile,
                           delete_component_files = delete_component_files)

  }

}


# `%>%` <- function(...){
#   purrr::`%>%`(...)
# }


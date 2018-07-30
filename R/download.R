#' Generate url to download
#'
#' @title This function generates the url depending on the exchange and the date.
#'
#' @param date The date you want the data for.
#' The input should either be a date object or a something that lubridate::as_date can parse to be a
#' date. If a string is in the format yyyy-mm-dd, this generally works.
#' @param exchange Choose either "bse" or "nse". If nothing is provided, defaults to "nse".
#'
#' @return The url that should have the data for the exchange and the date specified.
#'
#' @examples
#' make_date_url("2018-07-25", exchange = "bse")
#'
#' make_date_url(lubridate::today())

make_date_url <- function(date, exchange = c("nse", "bse")){

  exchange <- check_exchange(exchange, include_both = FALSE)
  date <- try(date_validation(date))

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


#' Download stock data
#'
#' Used to download stocks from both exchanges on the date specified.
#'
#' @param date The date you want the data for.
#' The input should either be a date object or a something that lubridate::as_date can parse to be a
#' date. If a string is in the format yyyy-mm-dd, this generally works. Defaults to lubridate::today()
#' @param ... Arguments you would pass to the download stocks function
#'
#' @return The function does not return anything.
#' It just gets the files downloaded if data is available.
#'
#' @export
#'
#' @examples
#' download_stocks_both()
#'
#' download_stocks_both(date = "2018-07-16", dest_path = ".")

download_stocks_both <- function(date = lubridate::today(), ...){
  download_stocks(date = date, exchange = "nse", ...)
  download_stocks(date = date, exchange = "bse", ...)
}


#' Download stock data
#'
#' Downloads stock data from the specified exchanges on the specified date.
#'
#' @param date  The date you want the data for.
#' The input should either be a date object or a something that lubridate::as_date can parse to be a
#' date. If a string is in the format yyyy-mm-dd, this generally works. Defaults to lubridate::today()
#' @param exchange Either "nse" or "bse". Defaults to "nse".
#' @param dest_path The location where you want to download the files to.
#' Defaults to the data folder in the current working directory.
#' If there is no data folder, one will be created.
#' @param quiet If TRUE, there will be no messages on the download status.
#'
#' @return he function does not return anything.
#' It just gets the files downloaded if data is available.
#' @export
#'
#' @examples
#' download_stocks()
#'
#' download_stocks(date = lubridate::today() - 3, exchange = "bse")

download_stocks <- function(date = lubridate::today(),
                            exchange = c("nse", "bse"),
                            dest_path = "./data",
                            quiet = FALSE){

  date <- try(date_validation(date))

  exchange <- check_exchange(exchange, include_both = FALSE)

  if(dest_path != "./data" & !dir.exists(dest_path)){
    stop("The path you specified does not exist.")
  }

  if(dest_path == "./data" & !dir.exists("./data")){
    dir.create("./data")
  }

  dest_file <- paste0(dest_path, "/", exchange, "_", date_filename_pattern(date), ".zip")
  url <- make_date_url(date = date, exchange = exchange)

  if(identical(httr::status_code(GET(url)), 200L)){

    httr::GET(url,
              httr::user_agent("Mozilla/5.0"),
              httr::write_disk(dest_file))

    df_download <- suppressWarnings(suppressMessages(readr::read_csv(dest_file)))
    if(exchange == "nse") df_download$X14 <- NULL
    df_download$date <- date
    df_download$exchange <- exchange
    readr::write_csv(df_download, dest_file %>% stringr::str_replace("zip", "csv"))
    safely_remove(dest_file)

    status_message <- paste0("Dowloaded stocks data from ", toupper(exchange), " on ", toupper(as.character(date, "%d %b %Y")))

  } else {
    status_message <- download_error_message(date, exchange)
  }

  if(!quiet){
    message(status_message)
  }

}


#' Download stock data
#'
#' Downloads stock data for the period specified
#'
#' @param start The date from which you want the data.
#' Defaults to lubridate::today() - 8 (8 days before today).
#' @param end The date till which you want the data. Defauts to lubridate::today().
#' @param exchange Choose one from "both", "nse" or "bse". Defaults to "both".
#' @param dest_path The path you want the downloaded files to go in.
#' Defaults to the data folder in the current working directory.
#' @param compile If FALSE, the individual downloaded files are retained and
#' not compiled into one large file. If TRUE, the files are compiled into one large file.
#' You can choose whether to retain just the compiled file or not, using the delete_component_files parameter.
#' If there are other nse or bse files, even they are compiled into one and
#' Defaults to TRUE.
#' @param delete_component_files Works only if compile is TRUE. If TRUE, only the compiled file will be retained.
#' If FALSE, all the individual component files will be retained.
#' @param quiet Controls the download status message.
#' If you do not want the download status on each day, TRUE should be specified. Defaults to FALSE.
#'
#' @return If compile is TRUE, the compiled dataframe is returned.
#' If FALSE, the files are just downloaded and nothing is returned.
#' @export
#'
#' @examples
#' download_stocks_period()
#'
#' download_stocks_period(start = "2017-01-01", end = "2017-01-05", exchange = "bse", compile = FALSE)
download_stocks_period <- function(start = lubridate::today() - 8,
                                   end = lubridate::today(),
                                   exchange = c("both", "nse", "bse"),
                                   dest_path = "./data",
                                   compile = TRUE,
                                   delete_component_files = TRUE,
                                   quiet = FALSE){

  start <- date_validation(start)
  end <- date_validation(end)
  stopifnot(start < end)

  exchange <- check_exchange(exchange)


  if(exchange == "both"){
    purrr::walk(start:end, ~download_stocks_both(date = .x,
                                                 dest_path = dest_path,
                                                 quiet = quiet))
  } else {
    purrr::walk(start:end, ~download_stocks(date = .x,
                                            exchange = exchange,
                                            dest_path = dest_path,
                                            quiet = quiet))
  }

  message("Stock data downloaded for date range")

  if(compile){
    compile_exchange_data(data_path = dest_path,
                          exchange = exchange,
                          delete_component_files = delete_component_files,
                          quiet = quiet)
  }

}



#' Compile the exchange files inside a directory
#'
#' This is used to compile all the individual files for different dates into compiled files.
#'
#' @param data_path The path that contains the data files you want to compile. Deafults to the data folder in the current working directory.
#' @param exchange Specifies the exchange files you want to compile. One of "both", "nse" or "bse".
#' If both is specified, the nse component files are compiled into nse_compiled_latest_date.csv and
#' bse files are compiled into  bse_compiled_latest_date.csv.
#' Both the nse and bse compiled files are parsed and combined into both_compiled_latest_date.
#' Dedaults to "both".
#' @param delete_component_files Deletes all the individual files and retains only the compiled files.
#'
#' @return Returns the compiled dataframe and also has the returned dataframe written out as a csv in the folder it compiles.
#' @export
#'
#' @examples
#' compile_exchange_data(data_path = "./data", exchange = "both")
#'

compile_exchange_data <- function(data_path = "./data",
                                exchange = c("both", "nse", "bse"),
                                delete_component_files =  TRUE,
                                quiet = FALSE){

  exchange <- check_exchange(exchange)
  stopifnot(dir.exists(data_path))

  if(exchange == "both"){

    df_bse <- compile_exchange_data(data_path = data_path, exchange = "bse")

    df_nse <- compile_exchange_data(data_path = data_path, exchange = "nse")

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

    if(!quiet) message(paste("\nCompiling", toupper("BSE and NSE together")))

    df_all <-
      dplyr::bind_rows(df_nse, df_bse)
    date_file_name <- dir(data_path) %>% extract_date() %>% min() %>% date_filename_pattern()
    df_all %>% readr::write_csv(paste0(data_path, "/", "both_compiled_", date_file_name, ".csv"))

    df_all

  } else {

    if(!quiet) message(paste("\nCompiling", toupper(exchange)))

    files <- dir(data_path, pattern = exchange) %>% stringr::str_subset(".csv")
    if(length(files) < 1){
      stop(paste("No files of", exchange, "to compile."))
    }
    files <- paste0(data_path, "/", files)

    if(!quiet) message(paste("Compiling all and only the available files in the specified directory.",
                  "If the available files contain gaps, then the compiled file will too.",
                  "If it contains other exchange files, they will get added to the compiled too.\n"))

    df_exchange_compiled <- purrr::map_dfr(files, function(x){

      df_x <-  suppressWarnings((suppressMessages(readr::read_csv(x))))
      df_x
    }) %>%
    dplyr::distinct()

    max_date <- dir("./data", pattern = exchange) %>% extract_date() %>% max()

    if(delete_component_files){
      files %>% purrr::walk(safely_remove)
    }

    readr::write_csv(df_exchange_compiled, paste0(data_path, "/", exchange, "_compiled_", date_filename_pattern(max_date), ".csv"))

    df_exchange_compiled
  }

}



#' Download stock data
#'
#' Used to periodically update the compiled data.
#' Downloads data from the point till when the data is present (if nothing is present, the last 8 days) till the point we specify.
#'
#' @param data_path The path you want to update, which possibly contains the data files.
#' Defaults to the data folder in the current working directory.
#' @param till The date till which you want to update. Defaults to lubridate::today()
#' @param exchange One of "both", "nse" or "bse". Defaults to "both".
#' @param compile If FALSE, the individual downloaded files are retained and
#' not compiled into one large file. If TRUE, the files are compiled into one large file.
#' You can choose whether to retain just the compiled file or not, using the delete_component_files parameter.
#' If there are other nse or bse files, even they are compiled into one and
#' Defaults to TRUE.
#' @param delete_component_files Works only if compile is TRUE. If TRUE, only the compiled file will be retained.
#' If FALSE, all the individual component files will be retained.
#' @param quiet Controls the download status message.
#' If you do not want the download status on each day, TRUE should be specified. Defaults to FALSE.
#'
#' @return If exchange is "both", then the compiled data from both "nse" and "bse" is returned or
#' the compiled data from whatever exchange is specified. The new files are also written as csvs in the path specified.
#' @export
#'
#' @examples
#' update_stocks()
#'
#' update_stocks(till = "2018-07-25")
update_stocks <- function(data_path = "./data",
                          till = lubridate::today(),
                          exchange = c("both", "nse", "bse"),
                          compile = TRUE,
                          delete_component_files = TRUE,
                          quiet = FALSE){

  exchange <- check_exchange(exchange)
  stopifnot(dir.exists(data_path))

  if(exchange == "both"){
    update_stocks(data_path = data_path,
                  till = till,
                  exchange = "nse",
                  compile = compile,
                  delete_component_files = delete_component_files,
                  quiet = quiet)

    update_stocks(data_path = data_path,
                  till = till,
                  exchange = "bse",
                  compile = compile,
                  delete_component_files = delete_component_files,
                  quiet = quiet)

    compile_exchange_data(exchange = "both",
                          data_path = data_path,
                          delete_component_files = FALSE,
                          quiet = TRUE)

  } else {

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
                           delete_component_files = delete_component_files,
                           quiet = quiet)

  }

}




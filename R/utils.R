#' Helper functions
#'
#' An error message constructor.
#'
#' @param date  The date you want the data for.
#' The input should either be a date object or a something that lubridate::as_date can parse to be a
#' date. If a string is in the format yyyy-mm-dd, this generally works.
#' @param market Usually "nse" or "bse". But any string can be specified.
#'
#' @return The download error message
#'
#' @examples
#' download_error_message(lubridate::today(), "nse")
download_error_message <- function(date, market){
  date <- lubridate::as_date(date)

  if(lubridate::wday(date) %in% c(1,7)){
    paste0("No download data available for ", toupper(market), " on ",
           date %>% as.character("%d %b %Y"),
           ifelse(lubridate::wday(date) == 7, " (Saturday)", " (Sunday)"))
  } else {
    paste0("No download data available for ", toupper(market), " on ",
           date %>% as.character("%d %b %Y"),
           ". Either the data is not available yet or the exchange did not function on that day.")
  }

}


#' Helper functions
#'
#' A function to validate the specified exchange value and get the exchange value if nothing is specified.
#'
#' @param exchange The value to be validated. Defaults to c("nse", "bse")
#' @param include_both Paramter to control whether to include "both" as an option for exchange or not. Defaults to TRUE
#'
#' @return The validated exchange value or en error if its not valid.
#'
#' @examples
#' check_exchange()

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


#' Helper functions
#'
#' A date validator
#'
#' @param date Any string that you want to see if it can be parsed as a date.
#'
#' @return The parsed date.
#'
#' @examples
#'
#' # date_validation("j765")
#'
#' date_validation("2018-07-24")
#' date_validation(lubridate::today())
date_validation <- function(date){
  date <- lubridate::as_date(date) #%>% suppressWarnings() %>% suppressMessages()

  if((!lubridate::is.Date(date)) | is.na(date)){
    e <- simpleError("Date failed to parse")
    stop(e)
  }

  date
}


#' Helper functions
#'
#' A function to help construct the date part of a filename from the name.
#'
#' @param date Any valid date
#'
#' @return A string that contains the date part of a filename
#'
#' @examples
#' date_filename_pattern(lubridate::today())
date_filename_pattern <- function(date){
  paste0(lubridate::year(date), "_",
         lubridate::month(date) %>% stringr::str_pad(width = 2, side = "left", pad = "0"), "_",
         lubridate::mday(date) %>% stringr::str_pad(width = 2, side = "left", pad = "0"))
}


#' Helper functions
#'
#' @param x A vector of filenames
#'
#' @return A vector of extracted dates from the filenames
#'
#' @examples
#'
#' extract_date(dir("./data"))
extract_date <- function(x){
  if(length(x) == 0) return(NA)
  stringr::str_extract(x, "[\\d]+_[\\d]+_[\\d]+") %>% lubridate::ymd()
}

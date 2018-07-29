#' Title
#'
#' @param date
#' @param exchange
#'
#' @return
#' @export
#'
#' @examples

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

#' Title
#'
#' @param date
#' @param exchange
#'
#' @return
#' @export
#'
#' @examples

date_validation <- function(date){
  date <- lubridate::as_date(date) #%>% suppressWarnings() %>% suppressMessages()

  if((!lubridate::is.Date(date)) | is.na(date)){
    e <- simpleError("Date failed to parse")
    stop(e)
  }

  date
}

#' Title
#'
#' @param date
#' @param exchange
#'
#' @return
#' @export
#'
#' @examples

date_filename_pattern <- function(date){
  paste0(lubridate::year(date), "_",
         lubridate::month(date) %>% stringr::str_pad(width = 2, side = "left", pad = "0"), "_",
         lubridate::mday(date) %>% stringr::str_pad(width = 2, side = "left", pad = "0"))
}


#' Title
#'
#' @param date
#' @param exchange
#'
#' @return
#' @export
#'
#' @examples

extract_date <- function(x){
  if(length(x) == 0) return(NA)
  stringr::str_extract(x, "[\\d]+_[\\d]+_[\\d]+") %>% lubridate::ymd()
}

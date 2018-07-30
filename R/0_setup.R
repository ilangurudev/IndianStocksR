
#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1") utils::globalVariables(c("SC_NAME",
                                                       "SC_CODE",
                                                       "SC_TYPE",
                                                       "NO_OF_SHRS",
                                                       "series",
                                                       "tottrdqty",
                                                       "symbol",
                                                       "isin",
                                                       "high",
                                                       "low",
                                                       "volume"))

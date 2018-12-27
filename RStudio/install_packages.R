install.packages("devtools",  repos="http://cran.rstudio.com/")

source("/home/rstudio/installUtils.R")

p <- c(
"BH" = "1.66.0-1",
"crayon" = "1.3.4",
"digest" = "0.6.18",
"htmltools" = "0.3.6",
"httpuv" = "1.4.5",
"jsonlite" = "1.6",
"later" = "0.7.5",
"magrittr" = "1.5",
"mime" = "0.6",
"promises" = "1.0.1",
"R6" = "2.3.0",
"Rcpp" = "1.0.0",
"rlang" = "0.3.0.1",
"shiny" = "1.2.0"
)

installAll(p)

	

library(netstat)
#library(dplyr)
#library(binman)
#library(wdman)
library(chromote)
library(rvest)

options(chromote.headless = TRUE)
get_uob_gold = function(wait = 10) {
  
  
  b = ChromoteSession$new()
  on.exit(b$close())
  b$Page$navigate("https://www.uobgroup.com/online-rates/gold-and-silver-prices.page")
  Sys.sleep(wait)
  
  
  doc = b$DOM$getDocument()
  html_source = b$DOM$getOuterHTML(nodeId = doc$root$nodeId)$outerHTML
  
  
  page = read_html(html_source)
  tables = html_table(page, fill = TRUE)

  #retry if page in chromote did not load in time
  if (length(tables) == 0 || nrow(tables[[1]]) == 0) {
    Sys.sleep(10)
    doc = b$DOM$getDocument()
    html_source = b$DOM$getOuterHTML(nodeId = doc$root$nodeId)$outerHTML
    page = read_html(html_source)
    tables = html_table(page, fill = TRUE)
    }
  #return first table, change if layout of page changes
  tables[[1]]
}


gold_tbl = suppressWarnings(get_uob_gold())
gc()

gold_tbl

daily_price = data.frame(
  date = c(Sys.Date()),
  bankbuy = gold_tbl$`BANK BUYS (SGD)`[gold_tbl$DESCRIPTION == "CAST BARS"],
  banksell = gold_tbl$`BANK SELLS (SGD)`[gold_tbl$DESCRIPTION == "CAST BARS"]
)

file_path = "prices.csv"

if (file.exists(file_path)) {
  write.table(
    daily_price,
    file_path,
    append = T,
    sep = ",",
    col.names = F,
    row.names = F
  )
} else{
  write.csv(daily_price, file_path, row.names = F)
}

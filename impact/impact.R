

library(magrittr)
library(dplyr)
library(ggplot2)
library(kableExtra)

l <- scholar::get_profile("Lo70aGIAAAAJ&")

t<- scholar::get_publications("Lo70aGIAAAAJ&hl&") %>% 
   distinct(title, .keep_all = TRUE) %>%
  filter(year >= 2009 & journal != "Abstract book for the ISBNPA") 

t %>% select(year, author, title, journal, cites) %>%
  arrange(desc(cites)) %>%
  head(n=5) %>%
   kable()%>%
  kable_styling(fixed_thead = T,font_size = 7) %>%
  save_kable("best5.html")
  
t %>% select(year, author, title, journal, cites) %>%
    filter( year > as.numeric(format(Sys.Date(),"%Y")) - 5) %>%
    filter( !(journal %in% c("Nature", "Nature genetics", "Nature communications"))) %>%
  arrange(desc(cites)) %>%
  head(n=5) %>%
   kable()%>%
  kable_styling(fixed_thead = T,font_size = 7) 
 
# plot publications by year
p1 <- ggplot(t, aes(x= year)) +
geom_bar() +
ylim(c(0,80)) +
geom_text(stat='count', aes(label=..count..), vjust=-1) +
ggthemes::theme_economist()

ggsave("publications.png",p1)


ct <- scholar::get_citation_history("Lo70aGIAAAAJ&hl&") %>%
  filter(year < as.numeric(format(Sys.Date(),"%Y")))

## Plot citation trend
p2 <- ggplot(ct, aes(year, cites)) + 
    geom_line() + 
    geom_point() +
    ggthemes::theme_economist()

ggsave("citations.png",p2)


# grants "/home/chris/web/chrisoldmeadow/impact/ChrisOldmeadow_Grants_supporting.xlsx")

grants <- readxl::read_xlsx(path = "/home/chris/web/chrisolmdeadow/impact/ChrisOldmeadow_Grants_supporting.xlsx")

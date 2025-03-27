library(scholar)
library(tidyverse)
library(glue)
library(here)


# Google Scholar ID from profile URL
scholar_id <- "dAAMOqgAAAAJ"

# pull from google
html_1 <- get_publications(scholar_id)

# convert to html table
html_2 <- html_1 %>%
  as_tibble %>% arrange(desc(year)) %>%
  mutate(
    author=str_replace_all(author, "([A-Z]) ([A-Z]) ", "\\1\\2 "),
    author=str_replace_all(author, ", \\.\\.\\.", " et al."),
    author=str_replace_all(author, "J Skaza", "<b>J Skaza</b>"), # make my name bold
    author=str_replace_all(author, "JS Skaza", "<b>JS Skaza</b>"), # make my name bold
    # Create HTML citation with conditional parts
    citation=pmap_chr(list(author, year, title, journal, number, cid), function(author, year, title, journal, number, cid) {
      # Base citation with Google Scholar link
      base <- glue('{author} ({year}) <a href="https://scholar.google.com/scholar?oi=bibs&cluster={cid}&btnI=1&hl=en">{title}</a>')
      # Add journal if present
      if (!is.na(journal) && journal != "") {
        base <- glue("{base}, {journal}")
        # Add number/pages if present
        if (!is.na(number) && number != "") {
          base <- glue("{base}, {number}")
        }
      }
      base
    })
  ) %>% split(.$year) %>%
  map(function(x){
    x <- x %>%
      glue_data('<tr><td>{citation}</td></tr>')
    x <- c('<table class="publication-table"><tbody>', x, '</tbody></table>')
    return(x);
  }) %>% rev

html_3 <- map2(names(html_2) %>% paste0("<h3>", ., "</h3>"), html_2, c) %>% unlist

# Add the last updated text at the bottom
html_4 <- c(
  html_3,
  paste0('<p style="text-align: right; margin-top: 40px;"><small>Last updated <i>',
         format(Sys.Date(), format="%B %d, %Y"),
         '&ndash; Pulled automatically from my <a href="https://scholar.google.com/citations?hl=en&user=', scholar_id, '">Google Scholar profile</a>.')
)

# write the html list to a file
writeLines(html_4, here::here("_includes", "publications.html"))

# Also generate a markdown version for the CV
cv_pubs <- html_1 %>%
  as_tibble %>% 
  arrange(desc(year)) %>%
  mutate(
    author=str_replace_all(author, "([A-Z]) ([A-Z]) ", "\\1\\2 "),
    author=str_replace_all(author, ", \\.\\.\\.", " et al."),
    # Create citation with conditional parts
    citation=pmap_chr(list(author, year, title, journal, number), function(author, year, title, journal, number) {
      # Base citation
      base <- glue("{author} ({year}). {title}.")
      # Add journal if present
      if (!is.na(journal) && journal != "") {
        base <- glue("{base} *{journal}*")
        # Add number/pages if present
        if (!is.na(number) && number != "") {
          base <- glue("{base}, {number}")
        }
      }
      base
    }),
    citation=str_replace_all(citation, "J Skaza", "**J Skaza**"), # make my name bold
    citation=str_replace_all(citation, "JS Skaza", "**JS Skaza**") # make my name bold
  ) %>%
  pull(citation) %>%
  paste(collapse="\n\n")

# Write to a temporary file that can be included in the CV
writeLines(cv_pubs, here::here("_includes", "cv_publications.md")) 
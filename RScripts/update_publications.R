library(scholar)
library(tidyverse)
library(glue)
library(here)
library(rvest)  # Add rvest for web scraping
library(httr)


# Google Scholar ID from profile URL
scholar_id <- "dAAMOqgAAAAJ"

# Function to get publications with retries and rate limiting
get_publications_with_retry <- function(scholar_id, max_attempts = 3) {
  for (attempt in 1:max_attempts) {
    tryCatch({
      # Add delay between attempts
      if (attempt > 1) {
        Sys.sleep(30 * attempt)  # Exponential backoff
      }
      
      # Set a realistic user agent
      options(scholar_user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
      
      # Get publications
      pubs <- get_publications(scholar_id)
      return(pubs)
    }, error = function(e) {
      if (attempt == max_attempts) {
        stop("Failed to fetch publications after ", max_attempts, " attempts: ", e$message)
      }
      warning("Attempt ", attempt, " failed: ", e$message)
    })
  }
}

# Function to get scholar links with retries and rate limiting
get_scholar_links <- function(scholar_id, max_attempts = 3) {
  for (attempt in 1:max_attempts) {
    tryCatch({
      # Add delay between attempts
      if (attempt > 1) {
        Sys.sleep(30 * attempt)  # Exponential backoff
      }
      
      url <- glue("https://scholar.google.com/citations?hl=en&user={scholar_id}&view_op=list_works&sortby=pubdate")
      
      # Set headers to mimic a browser
      response <- GET(url, 
                     add_headers(
                       "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
                       "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                       "Accept-Language" = "en-US,en;q=0.5",
                       "Connection" = "keep-alive"
                     ))
      
      if (status_code(response) != 200) {
        stop("HTTP error: ", status_code(response))
      }
      
      page <- read_html(response)
      
      links <- page %>%
        html_nodes(".gsc_a_at") %>%
        html_attr("href") %>%
        paste0("https://scholar.google.com", .)
      
      titles <- page %>%
        html_nodes(".gsc_a_at") %>%
        html_text()
      
      # Return a named vector of links
      names(links) <- titles
      return(links)
    }, error = function(e) {
      if (attempt == max_attempts) {
        stop("Failed to fetch scholar links after ", max_attempts, " attempts: ", e$message)
      }
      warning("Attempt ", attempt, " failed: ", e$message)
    })
  }
}

# pull publication data from Google Scholar with retries
html_1 <- get_publications_with_retry(scholar_id)

# Get direct links to publications with retries
publication_links <- get_scholar_links(scholar_id)

# convert to html table
html_2 <- html_1 %>%
  as_tibble %>% arrange(desc(year)) %>%
  mutate(
    author=str_replace_all(author, "([A-Z]) ([A-Z]) ", "\\1\\2 "),
    author=str_replace_all(author, ", \\.\\.\\.", " et al."),
    author=str_replace_all(author, "J Skaza", "<b>J Skaza</b>"), # make my name bold
    author=str_replace_all(author, "JS Skaza", "<b>JS Skaza</b>"), # make my name bold
    # Create HTML citation with direct links from scraping
    citation=pmap_chr(list(author, year, title, journal, number), function(author, year, title, journal, number) {
      # Find the direct link for this publication by matching title
      # Use fuzzy matching to handle slight differences in title formatting
      best_match <- which.min(adist(title, names(publication_links)))
      link <- if(length(best_match) > 0 && adist(title, names(publication_links)[best_match]) < 10) {
        publication_links[best_match]
      } else {
        # Fallback to a search query if no match found
        search_title <- URLencode(title, reserved=TRUE)
        glue("https://scholar.google.com/scholar?q={search_title}")
      }
      
      # Create linked title
      linked_title <- glue('<a href="{link}">{title}</a>')
      
      # Base citation with linked title
      base <- glue('{author} ({year}) {linked_title}')
      
      # Add journal if present
      if (!is.na(journal) && journal != "") {
        base <- glue("{base}, <em>{journal}</em>")
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
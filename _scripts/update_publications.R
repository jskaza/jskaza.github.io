library(scholar)
library(tidyverse)
library(glue)
library(here)
library(rvest)  # Add rvest for web scraping
library(httr)


# Google Scholar ID from profile URL
scholar_id <- "dAAMOqgAAAAJ"

# Function to get publications with retries and rate limiting
get_publications_with_retry <- function(scholar_id, max_attempts = 5) {
  for (attempt in 1:max_attempts) {
    tryCatch({
      # Add delay between attempts with exponential backoff
      if (attempt > 1) {
        Sys.sleep(60 * attempt)  # Increased delay between attempts
      }
      
      # Set a realistic user agent
      options(scholar_user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      
      # Get publications
      pubs <- get_publications(scholar_id)
      return(pubs)
    }, error = function(e) {
      if (attempt == max_attempts) {
        warning("Failed to fetch publications after ", max_attempts, " attempts: ", e$message)
        # Return empty data frame with correct structure as fallback
        return(data.frame(
          title = character(),
          author = character(),
          journal = character(),
          number = character(),
          cites = integer(),
          year = integer(),
          cid = character(),
          pubid = character()
        ))
      }
      warning("Attempt ", attempt, " failed: ", e$message)
    })
  }
}

# Function to get scholar links with retries and rate limiting
get_scholar_links <- function(scholar_id, max_attempts = 5) {
  for (attempt in 1:max_attempts) {
    tryCatch({
      # Add delay between attempts with exponential backoff
      if (attempt > 1) {
        Sys.sleep(60 * attempt)  # Increased delay between attempts
      }
      
      url <- glue("https://scholar.google.com/citations?hl=en&user={scholar_id}&view_op=list_works&sortby=pubdate")
      
      # Set headers to mimic a browser more realistically
      response <- GET(url, 
                     add_headers(
                       "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                       "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
                       "Accept-Language" = "en-US,en;q=0.9",
                       "Accept-Encoding" = "gzip, deflate, br",
                       "Connection" = "keep-alive",
                       "Upgrade-Insecure-Requests" = "1",
                       "Sec-Fetch-Dest" = "document",
                       "Sec-Fetch-Mode" = "navigate",
                       "Sec-Fetch-Site" = "none",
                       "Sec-Fetch-User" = "?1",
                       "Cache-Control" = "max-age=0"
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
        warning("Failed to fetch scholar links after ", max_attempts, " attempts: ", e$message)
        return(character())  # Return empty vector as fallback
      }
      warning("Attempt ", attempt, " failed: ", e$message)
    })
  }
}

# pull publication data from Google Scholar with retries
html_1 <- get_publications_with_retry(scholar_id)

# Get direct links to publications with retries
publication_links <- get_scholar_links(scholar_id)

# If we have no publications data, create a minimal version
if (nrow(html_1) == 0) {
  warning("No publications data available. Using fallback data.")
  html_1 <- data.frame(
    title = "Publications temporarily unavailable",
    author = "J Skaza",
    journal = "",
    number = "",
    cites = 0,
    year = as.integer(format(Sys.Date(), "%Y")),
    cid = "",
    pubid = ""
  )
}

# convert to html table
html_2 <- html_1 %>%
  as_tibble %>% arrange(desc(year)) %>%
  mutate(
    author=str_replace_all(author, "([A-Z]) ([A-Z]) ", "\\1\\2 "),
    author=str_replace_all(author, ", \\.\\.\\.", " et al."),
    author=str_replace_all(author, "J Skaza", "<b>J Skaza</b>"),
    author=str_replace_all(author, "JS Skaza", "<b>JS Skaza</b>"),
    # Create HTML citation with direct links from scraping
    citation=pmap_chr(list(author, year, title, journal, number), function(author, year, title, journal, number) {
      # Find the direct link for this publication by matching title
      # Use fuzzy matching to handle slight differences in title formatting
      link <- if(length(publication_links) > 0) {
        best_match <- which.min(adist(title, names(publication_links)))
        if(length(best_match) > 0 && adist(title, names(publication_links)[best_match]) < 10) {
          publication_links[best_match]
        } else {
          # Fallback to a search query if no match found
          search_title <- URLencode(title, reserved=TRUE)
          glue("https://scholar.google.com/scholar?q={search_title}")
        }
      } else {
        # If no links available, use a search query
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
    citation=str_replace_all(citation, "J Skaza", "**J Skaza**"),
    citation=str_replace_all(citation, "JS Skaza", "**JS Skaza**")
  ) %>%
  pull(citation) %>%
  paste(collapse="\n\n")

# Write to a temporary file that can be included in the CV
writeLines(cv_pubs, here::here("_includes", "cv_publications.md")) 
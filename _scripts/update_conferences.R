# Script to generate formatted conference entries for CV
library(yaml)
library(tidyverse)
library(glue)

# Read conferences data
conferences <- read_yaml(here::here("_data", "conferences.yml"))

# Process conferences to generate CV-friendly format with initials
cv_conferences <- map_chr(conferences, function(conf) {
  # Create author initials
  authors_initials <- map_chr(conf$authors, function(author) {
    first_initial <- if(!is.null(author$first)) substr(author$first, 1, 1) else ""
    middle_initial <- if(!is.null(author$middle)) substr(author$middle, 1, 1) else ""
    
    # Format as initials with last name
    initials <- paste0(
      first_initial,
      if(middle_initial != "") paste0(middle_initial) else "",
      if(!is.null(author$last)) paste0(" ", author$last) else ""
    )
    
    # Bold if the author is Jonathan Skaza
    if(!is.null(author$last) && author$last == "Skaza") {
      return(paste0("**", initials, "**"))
    } else {
      return(initials)
    }
  })
  
  # Join authors with commas and & for last author
  n_authors <- length(authors_initials)
  if(n_authors > 1) {
    authors_initials[n_authors] <- paste0("& ", authors_initials[n_authors])
  }
  authors_initials_formatted <- paste(authors_initials, collapse = ", ")
  
  # Create citation with initials
  citation_initials <- glue("{authors_initials_formatted} ({conf$date}). {conf$title}. *{conf$venue}*, {conf$location}")
  
  return(citation_initials)
}) %>% 
  as.character() %>%
  paste(collapse = "\n\n")

# Write to files that can be included in CV
writeLines(cv_conferences, here::here("_includes", "cv_conferences.md"))
writeLines(cv_conferences, here::here("_includes", "cv_conferences_initials.md")) 
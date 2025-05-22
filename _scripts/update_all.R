# Update publications
source(here::here("RScripts", "update_publications.R"))

# Update conferences
source(here::here("RScripts", "update_conferences.R"))

# Render CV
rmarkdown::render(
  here::here("assets", "Skaza_CV.Rmd"), 
  output_file=here::here("assets", "Skaza_CV.pdf")
) 
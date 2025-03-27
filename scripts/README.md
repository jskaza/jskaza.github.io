# Publication Update Scripts

This directory contains scripts to automatically update publications across the website and CV.

## Setup

1. Install required R packages:
```R
install.packages(c("scholar", "tidyverse", "glue", "rmarkdown"))
```

2. Update your Google Scholar ID in `update_publications.R` if needed.

## Usage

To update publications and regenerate the CV:

```R
source("update_all.R")
```

This will:
1. Pull latest publications from Google Scholar
2. Generate HTML for the research page
3. Generate markdown for the CV
4. Render the updated CV as PDF

## Files

- `update_publications.R`: Main script to pull and format publications
- `update_all.R`: Wrapper script to update everything
- `README.md`: This file 
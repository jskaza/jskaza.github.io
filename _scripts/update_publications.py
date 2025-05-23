import time
import sys
import os
import json
from datetime import datetime
from scholarly import scholarly, ProxyGenerator

# Google Scholar ID from profile URL
SCHOLAR_ID = "dAAMOqgAAAAJ"

def format_name(author):
    """Convert author name to FIRSTMIDDLE LAST format and bold if J/JS Skaza"""
    # Handle empty case
    if not author:
        return ""
        
    # Split on commas first (handles "Last, First Middle" format)
    parts = author.split(",")
    if len(parts) > 1:
        last = parts[0].strip()
        first_middle = parts[1].strip()
    else:
        # Assume "First Middle Last" format
        parts = author.split()
        if len(parts) < 2:
            return author
        last = parts[-1]
        first_middle = " ".join(parts[:-1])
    
    # Create abbreviated version
    initials = "".join(part[0] for part in first_middle.split())
    formatted = f"{initials} {last}"
    
    # Bold if J/JS Skaza
    if formatted.strip() in ["J Skaza", "JS Skaza"]:
        return f"<b>{formatted}</b>"
    return formatted

def format_name_markdown(author):
    """Same as format_name but with markdown bold syntax"""
    formatted = format_name(author)
    if formatted.startswith("<b>"):
        return f"**{formatted[3:-4]}**"
    return formatted

def format_authors(authors_str):
    """Format all authors with proper name formatting and commas"""
    # Split on both 'and' and commas
    authors = []
    for part in authors_str.split(" and "):
        authors.extend(name.strip() for name in part.split(","))
    
    # Format each non-empty author name
    formatted = [format_name(author) for author in authors if author.strip()]
    
    return ", ".join(formatted)

def format_authors_markdown(authors_str):
    """Same as format_authors but with markdown bold syntax"""
    # Split on both 'and' and commas
    authors = []
    for part in authors_str.split(" and "):
        authors.extend(name.strip() for name in part.split(","))
    
    # Format each non-empty author name
    formatted = [format_name_markdown(author) for author in authors if author.strip()]
    
    return ", ".join(formatted)

def init_proxy():
    """Return a fresh ProxyGenerator and register it with scholarly."""
    pg = ProxyGenerator()
    # Example: pick a fresh free proxy every time
    if not pg.FreeProxies():
        raise RuntimeError("Could not get a proxy")
    scholarly.use_proxy(pg)


def get_publications_with_retry(max_attempts=5):
    for attempt in range(max_attempts):
        try:
            init_proxy()                  
            if attempt:
                backoff = 180 * attempt
                print(f"Waiting {backoff}s before attempt {attempt + 1}")
                time.sleep(backoff)

            print(f"Fetching publications (attempt {attempt + 1}/{max_attempts})")
            author = scholarly.fill(scholarly.search_author_id(SCHOLAR_ID))
            publications = []
            print(f"Found {len(author['publications'])} publications, fetching details...")
            
            # Get publications
            for i, pub in enumerate(author['publications'], 1):
                print(f"Processing publication {i}/{len(author['publications'])}")
                try:
                    pub = scholarly.fill(pub)
                    
                    # Extract publication data
                    title = pub['bib'].get('title', '')
                    authors = pub['bib'].get('author', '')
                    journal = pub['bib'].get('journal', '') or pub['bib'].get('venue', '')
                    year = int(pub['bib'].get('pub_year', datetime.now().year))
                    cites = pub.get('num_citations', 0)
                    
                    # Get link - either direct link or scholar link
                    link = pub['pub_url'] if 'pub_url' in pub else f"https://scholar.google.com/citations?view_op=view_citation&citation_for_view={pub['author_pub_id']}"
                    
                    publications.append({
                        'title': title,
                        'author': authors,
                        'journal': journal,
                        'number': "",
                        'cites': cites,
                        'year': year,
                        'link': link
                    })
                except Exception as e:
                    print(f"Error processing publication {i}: {str(e)}", file=sys.stderr)
                    continue
                
                # Small delay between publications to avoid rate limiting
                if i < len(author['publications']):
                    time.sleep(2)
            
            if publications:
                print("Successfully fetched all publications")
                return publications
            else:
                raise Exception("No publications were successfully processed")
            
        except Exception as e:
            print(f"Error during attempt {attempt + 1}: {str(e)}", file=sys.stderr)
            if attempt == max_attempts - 1:
                print(f"Failed to fetch publications after {max_attempts} attempts", file=sys.stderr)
                return [{
                    'title': 'Publications temporarily unavailable',
                    'author': 'Skaza, Jonathan',
                    'journal': '',
                    'number': '',
                    'cites': 0,
                    'year': datetime.now().year,
                    'link': f'https://scholar.google.com/citations?hl=en&user={SCHOLAR_ID}'
                }]

def generate_html(publications):
    """Generate HTML output from publications data"""
    # Group publications by year
    pubs_by_year = {}
    for pub in publications:
        year = pub['year']
        if year not in pubs_by_year:
            pubs_by_year[year] = []
        pubs_by_year[year].append(pub)
    
    # Sort years in descending order
    years = sorted(pubs_by_year.keys(), reverse=True)
    
    html_parts = []
    for year in years:
        html_parts.append(f"<h3>{year}</h3>")
        html_parts.append('<table class="publication-table"><tbody>')
        
        for pub in pubs_by_year[year]:
            # Format authors with proper name formatting
            authors = format_authors(pub['author'])
            
            # Create citation
            citation = f'{authors} ({year}) <a href="{pub["link"]}">{pub["title"]}</a>'
            if pub['journal']:
                citation += f', <em>{pub["journal"]}</em>'
                if pub['number']:
                    citation += f', {pub["number"]}'
            
            html_parts.append(f'<tr><td>{citation}</td></tr>')
        
        html_parts.append('</tbody></table>')
    
    # Add last updated text
    html_parts.append(
        f'<p style="text-align: right; margin-top: 40px;"><small>Last updated <i>'
        f'{datetime.now().strftime("%B %d, %Y")}'
        f'&ndash; Pulled automatically from my <a href="https://scholar.google.com/citations?hl=en&user={SCHOLAR_ID}">Google Scholar profile</a>.</small></p>'
    )
    
    return '\n'.join(html_parts)

def generate_markdown(publications):
    """Generate Markdown output for CV"""
    md_parts = []
    
    # Sort publications by year (descending)
    sorted_pubs = sorted(publications, key=lambda x: x['year'], reverse=True)
    
    for pub in sorted_pubs:
        # Format authors with proper name formatting
        authors = format_authors_markdown(pub['author'])
        
        # Create citation
        citation = f'{authors} ({pub["year"]}). {pub["title"]}.'
        if pub['journal']:
            citation += f' *{pub["journal"]}*'
            if pub['number']:
                citation += f', {pub["number"]}'
        
        md_parts.append(citation)
    
    # Add final newline to ensure file ends with a newline
    return '\n\n'.join(md_parts) + '\n'

def main():
    print("Starting publications update...")
    # Get publications
    publications = get_publications_with_retry()
    
    if not publications:
        print("Error: No publications were fetched", file=sys.stderr)
        sys.exit(1)
    
    print(f"Successfully fetched {len(publications)} publications")
    
    # Generate HTML output
    print("Generating HTML output...")
    html_output = generate_html(publications)
    with open('_includes/publications.html', 'w', encoding='utf-8') as f:
        f.write(html_output)
    print("HTML output generated and saved")
    
    # Generate Markdown output for CV
    print("Generating Markdown output...")
    md_output = generate_markdown(publications)
    with open('_includes/cv_publications.md', 'w', encoding='utf-8') as f:
        f.write(md_output)
    print("Markdown output generated and saved")
    print("Update completed successfully")

if __name__ == "__main__":
    main() 
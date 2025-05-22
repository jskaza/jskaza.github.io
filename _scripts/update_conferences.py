import yaml
from datetime import datetime
import os
from pathlib import Path

def format_author(first, middle, last):
    """Format a single author consistently"""
    # Create initials
    initials = first[0] if first else ''
    if middle:
        initials += middle[0]
    
    # Format author name
    author_name = f"{initials} {last}"
    
    # Bold if the author is Jonathan Skaza
    if last == "Skaza":
        author_name = f"<b>{author_name}</b>"
    
    return author_name

def format_author_markdown(first, middle, last):
    """Format a single author consistently for markdown"""
    # Create initials
    initials = first[0] if first else ''
    if middle:
        initials += middle[0]
    
    # Format author name
    author_name = f"{initials} {last}"
    
    # Bold if the author is Jonathan Skaza
    if last == "Skaza":
        author_name = f"**{author_name}**"
    
    return author_name

def format_authors_list(authors, for_markdown=False):
    """Format list of authors consistently"""
    # Format each author
    formatted_authors = []
    for author in authors:
        first = author.get('first', '')
        middle = author.get('middle', '')
        last = author.get('last', '')
        
        if for_markdown:
            formatted_authors.append(format_author_markdown(first, middle, last))
        else:
            formatted_authors.append(format_author(first, middle, last))
    
    # Join authors with commas and & for last author
    if len(formatted_authors) > 1:
        formatted_authors[-1] = f"& {formatted_authors[-1]}"
    return ", ".join(formatted_authors)

def generate_html(conferences):
    """Generate HTML output from conferences data"""
    # Group conferences by year
    confs_by_year = {}
    for conf in conferences:
        year = conf['date']
        if year not in confs_by_year:
            confs_by_year[year] = []
        confs_by_year[year].append(conf)
    
    # Sort years in descending order
    years = sorted(confs_by_year.keys(), reverse=True)
    
    html_parts = []
    for year in years:
        html_parts.append(f"<h3>{year}</h3>")
        html_parts.append('<table class="conference-table"><tbody>')
        
        for conf in confs_by_year[year]:
            # Format authors consistently
            authors_str = format_authors_list(conf['authors'])
            
            # Create citation
            citation = f'{authors_str} ({year})'
            if conf.get('poster_link'):
                citation += f' <a href="{conf["poster_link"]}">{conf["title"]}</a>'
            else:
                citation += f' {conf["title"]}'
            
            citation += f', <em>{conf["venue"]}</em>, {conf["location"]}'
            
            html_parts.append(f'<tr><td>{citation}</td></tr>')
        
        html_parts.append('</tbody></table>')
    
    # Add last updated text
    html_parts.append(
        f'<p style="text-align: right; margin-top: 40px;"><small>Last updated <i>'
        f'{datetime.now().strftime("%B %d, %Y")}</i></small></p>'
    )
    
    return '\n'.join(html_parts)

def generate_markdown(conferences):
    """Generate Markdown output for CV"""
    md_parts = []
    
    # Sort conferences by year (descending)
    sorted_confs = sorted(conferences, key=lambda x: x['date'], reverse=True)
    
    for conf in sorted_confs:
        # Format authors consistently
        authors_str = format_authors_list(conf['authors'], for_markdown=True)
        
        # Create citation
        citation = f'{authors_str} ({conf["date"]}). {conf["title"]}. *{conf["venue"]}*, {conf["location"]}'
        
        md_parts.append(citation)
    
    # Add final newline to ensure file ends with a newline
    return '\n\n'.join(md_parts) + '\n'

def main():
    # Read conferences from YAML
    with open('_data/conferences.yml', 'r', encoding='utf-8') as f:
        conferences = yaml.safe_load(f)
    
    # Generate HTML output
    html_output = generate_html(conferences)
    with open('_includes/conferences.html', 'w', encoding='utf-8') as f:
        f.write(html_output)
    
    # Generate Markdown output for CV
    md_output = generate_markdown(conferences)
    with open('_includes/cv_conferences.md', 'w', encoding='utf-8') as f:
        f.write(md_output)

if __name__ == "__main__":
    main() 
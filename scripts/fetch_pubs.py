#!/usr/bin/env python3
"""
Sync Google Scholar → publications.toml
  fields: title, pub_year, author, journal, volume, abstract, url, github_repo
Install: pip install scholarly tomli-w requests
"""
import argparse, tomli_w, requests
from datetime import datetime
from pathlib import Path
from scholarly import scholarly
from urllib.parse import quote_plus
from tqdm import tqdm
import re

def scholar_search_url(title: str) -> str:
    """Guaranteed fallback: Google Scholar search for the full title."""
    return f"https://scholar.google.com/scholar?q={quote_plus(title)}"

def fetch_github_repos(username: str) -> list:
    """Fetch all public repositories for a GitHub user."""
    repos = []
    page = 1
    per_page = 100
    
    while True:
        api_url = f"https://api.github.com/users/{username}/repos"
        params = {'page': page, 'per_page': per_page, 'type': 'public'}
        
        response = requests.get(api_url, params=params)
        if response.status_code != 200:
            print(f"Warning: Failed to fetch GitHub repos for {username}")
            break
            
        page_repos = response.json()
        if not page_repos:
            break
            
        repos.extend(page_repos)
        page += 1
        
        # Break if we got fewer repos than requested (last page)
        if len(page_repos) < per_page:
            break
    
    return repos

def find_matching_repo(title: str, repos: list) -> str:
    """Check if paper title matches any repository description and return repo URL."""
    if not title or not repos:
        return None
    
    # Clean and normalize the title for matching
    title_words = re.findall(r'\w+', title.lower())
    title_clean = ' '.join(title_words)
    
    for repo in repos:
        description = repo.get('description', '') or ''
        if not description:
            continue
            
        description_clean = description.lower()
        
        # Check for exact title match
        if title_clean in description_clean:
            return repo['html_url']
    
    return None

def build_toml(scholar_id: str, github_username: str = None) -> dict:
    author = scholarly.fill(
        scholarly.search_author_id(scholar_id),
        sections=["publications"],
    )

    # Fetch GitHub repositories if username provided
    github_repos = []
    if github_username:
        print(f"Fetching GitHub repositories for {github_username}...")
        github_repos = fetch_github_repos(github_username)
        print(f"Found {len(github_repos)} repositories")

    # Add metadata about when this was fetched and from where
    toml_data = {
        "metadata": {
            "last_updated": datetime.now().isoformat(),
            "source": "Google Scholar",
            "scholar_id": scholar_id,
            "github_username": github_username,
            "note": "Publications automatically fetched from Google Scholar profile"
        },
        "publication": []
    }

    for stub in tqdm(author["publications"], desc="Fetching publication data"):
        pub = scholarly.fill(stub)          # one API call per paper
        
        bib = pub["bib"]

        # -------- core fields -------------------------------------------------
        title     = bib.get("title", "")
        pub_year  = bib.get("pub_year") or bib.get("year")
        authors   = [a.strip() for a in bib.get("author", "").split(" and ")]
        journal   = bib.get("journal") or bib.get("booktitle") or bib.get("venue") or bib.get("conference")
        volume    = bib.get("volume")
        abstract  = bib.get("abstract")

        # -------- best‑available link -----------------------------------------
        url = (
            pub.get("pub_url")
            or pub.get("eprint_url")
            or scholar_search_url(title) 
        )

        # -------- check for matching GitHub repository ------------------------
        github_repo = find_matching_repo(title, github_repos) if github_repos else None

        entry = {
            "title":     title,
            "pub_year":  int(pub_year) if str(pub_year).isdigit() else pub_year,
            "author":    authors,
            "journal":   journal,
            "volume":    volume,
            "abstract":  abstract,
            "url":       url,
            "github_repo": github_repo,
        }

        entry = {k: v for k, v in entry.items() if v is not None and v != ""} 
        toml_data["publication"].append(entry)

    return toml_data


def main() -> None:
    ap = argparse.ArgumentParser(description="Sync Google Scholar → TOML")
    ap.add_argument("--scholar-id", default="dAAMOqgAAAAJ")
    ap.add_argument("--github-username", default="jskaza")
    ap.add_argument("--out", default=Path(__file__).parent.parent / "data" / "publications.toml")
    args = ap.parse_args()

    data = build_toml(args.scholar_id, args.github_username)

    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    with open(args.out, "wb") as fh:
        tomli_w.dump(data, fh)

    # Count publications with GitHub repos
    github_matches = sum(1 for pub in data['publication'] if pub.get('github_repo'))

    print(f"✅  Wrote {len(data['publication'])} entries → {args.out}")
    if args.github_username:
        print(f"🔗  Found {github_matches} publications with matching GitHub repositories")
    print(f"📅  Last updated: {data['metadata']['last_updated']}")
    print(f"🎓  Source: {data['metadata']['source']}")


if __name__ == "__main__":
    main()
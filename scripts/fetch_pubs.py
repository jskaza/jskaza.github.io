#!/usr/bin/env python3
"""
Sync Google Scholar → publications.toml
  fields: title, pub_year, author, journal, volume, abstract, url
Install: pip install scholarly tomli-w
"""
import argparse, tomli_w
from datetime import datetime
from pathlib import Path
from scholarly import scholarly
from urllib.parse import quote_plus
from tqdm import tqdm

def scholar_search_url(title: str) -> str:
    """Guaranteed fallback: Google Scholar search for the full title."""
    return f"https://scholar.google.com/scholar?q={quote_plus(title)}"

def build_toml(scholar_id: str) -> dict:
    author = scholarly.fill(
        scholarly.search_author_id(scholar_id),
        sections=["publications"],
    )

    # Add metadata about when this was fetched and from where
    toml_data = {
        "metadata": {
            "last_updated": datetime.now().isoformat(),
            "source": "Google Scholar",
            "scholar_id": scholar_id,
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

        entry = {
            "title":     title,
            "pub_year":  int(pub_year) if str(pub_year).isdigit() else pub_year,
            "author":    authors,
            "journal":   journal,
            "volume":    volume,
            "abstract":  abstract,
            "url":       url,
        }

        entry = {k: v for k, v in entry.items() if v is not None} 
        toml_data["publication"].append(entry)

    return toml_data


def main() -> None:
    ap = argparse.ArgumentParser(description="Sync Google Scholar → TOML")
    ap.add_argument("--scholar-id", default="dAAMOqgAAAAJ")
    ap.add_argument("--out", default=Path(__file__).parent.parent / "data" / "publications.toml")
    args = ap.parse_args()

    data = build_toml(args.scholar_id)

    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    with open(args.out, "wb") as fh:
        tomli_w.dump(data, fh)

    print(f"✅  Wrote {len(data['publication'])} entries → {args.out}")
    print(f"📅  Last updated: {data['metadata']['last_updated']}")
    print(f"🎓  Source: {data['metadata']['source']}")


if __name__ == "__main__":
    main()
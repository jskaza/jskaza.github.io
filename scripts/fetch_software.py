import tomli
import tomli_w
import requests
from pathlib import Path
from urllib.parse import urlparse
from datetime import datetime

def extract_repo_name(url):
    """Extract repository name from GitHub URL."""
    path = urlparse(url).path
    return path.strip('/').split('/')[-1]

def fetch_repo_description(owner, repo):
    """Fetch repository description from GitHub."""
    api_url = f"https://api.github.com/repos/{owner}/{repo}"
    response = requests.get(api_url)
    if response.status_code == 200:
        return response.json().get('description', '')
    return None

def fetch_languages(owner, repo):
    """Fetch language breakdown from GitHub repository."""
    api_url = f"https://api.github.com/repos/{owner}/{repo}/languages"
    response = requests.get(api_url)
    if response.status_code == 200:
        return response.json()
    return None

def calculate_language_percentages(languages):
    """Calculate percentages for each language and return as ordered list."""
    if not languages:
        return None
    
    total_bytes = sum(languages.values())
    if total_bytes == 0:
        return None
    
    # Calculate percentages and store in a list of dictionaries
    percentages = [
        {"lang": lang, "percent": round((bytes_count / total_bytes) * 100, 2)}
        for lang, bytes_count in languages.items()
    ]
    
    # Sort the list by percentage in descending order
    return sorted(percentages, key=lambda x: x["percent"], reverse=True)

def main():
    # Read TOML file
    toml_path = Path(__file__).parent.parent / "data" / "software_raw.toml"
    with open(toml_path, 'rb') as f:
        data = tomli.load(f)
    
    # Create a new dictionary with array of tables format and metadata
    processed_data = {
        'metadata': {
            'last_updated': datetime.now().isoformat(),
            'note': 'Software data automatically fetched from GitHub repositories'
        },
        'software': []
    }
    
    # Process each repository
    for url in data['software']:
        repo_name = extract_repo_name(url)
        owner = urlparse(url).path.strip('/').split('/')[0]
        
        print(f"\nProcessing repository: {repo_name}")
        description = fetch_repo_description(owner, repo_name)
        languages_data = fetch_languages(owner, repo_name)
        
        if description is not None:
            # Add as a new table in the array
            repo_data = {
                'name': repo_name,
                'url': url,
                'description': description
            }
            
            # Add language information if available
            if languages_data:
                repo_data['languages'] = {
                    'bytes': languages_data,
                    'ordered': calculate_language_percentages(languages_data)
                }
            
            processed_data['software'].append(repo_data)
        else:
            print(f"Failed to fetch description for {repo_name}")
    
    # Save processed data to new TOML file
    output_path = Path(__file__).parent.parent / "data" / "software.toml"
    with open(output_path, 'wb') as f:
        tomli_w.dump(processed_data, f)
    
    print(f"\nData saved to {output_path}")

if __name__ == "__main__":
    main()

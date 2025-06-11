#!/bin/bash

# Auto-update script for publications and CV

# Source conda initialization
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
    source "/opt/conda/etc/profile.d/conda.sh"
else
    log "ERROR: Could not find conda initialization script"
    exit 1
fi

# Activate the site conda environment
conda activate site
if [ $? -ne 0 ]; then
    exit 1
fi

# Run the publications fetch script
python3 scripts/fetch_pubs.py
if [ $? -ne 0 ]; then
    exit 1
fi

# Compile CV with Typst
typst compile --root . static/cv/cv.typ
if [ $? -ne 0 ]; then
    exit 1
fi

# Check if there are any changes to commit
if [ -n "$(git status --porcelain)" ]; then
    echo "Changes detected, committing and pushing..."
    
    # Configure git for this repository only (--local flag)
    # This won't affect your global git settings
    git config --local user.email "automated-update@$(hostname)" > /dev/null 2>&1
    git config --local user.name "Auto Update Bot" > /dev/null 2>&1
    
    # Alternative: Use your actual git credentials (uncomment these lines and comment out the above)
    # git config --local user.email "$(git config --global user.email)"
    # git config --local user.name "$(git config --global user.name)"
    
    # Add all changes
    git add .
    
    # Commit with timestamp
    git commit -m "[Auto-update] publications and CV" > /dev/null 2>&1
    
    # Push to origin master
    git push origin master > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Successfully pushed changes to origin master"
    else
        echo "ERROR: Failed to push changes to origin master"
        exit 1
    fi
else
    echo "No changes detected, skipping commit"
fi

echo "Auto-update process completed successfully" 
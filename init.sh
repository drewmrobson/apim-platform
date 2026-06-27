#!/bin/bash
REPO=$(basename "$PWD")
git init
git remote add origin "https://drewmrobson@dev.azure.com/drewmrobson/Squareman/_git/$REPO"
git pull origin main --allow-unrelated-histories
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
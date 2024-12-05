#!/bin/bash

# Create a new branch for GitHub Pages
git init
git checkout -b gh-pages

# Add build/web contents to the root
cp -r build/web/* .

# Create .gitignore
echo "build/" > .gitignore
echo ".dart_tool/" >> .gitignore
echo ".idea/" >> .gitignore
echo ".flutter-plugins" >> .gitignore
echo ".flutter-plugins-dependencies" >> .gitignore

# Rename index.html's base href for GitHub Pages
sed -i 's/<base href="\/">/<base href="\/myapp\/">/' index.html

# Add all files
git add .

# Commit changes
git commit -m "Deploy to GitHub Pages"

echo "Now you can:"
echo "1. Create a new repository on GitHub"
echo "2. Run these commands to push your code:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"
echo "   git push -u origin gh-pages"
echo ""
echo "3. Go to your repository settings on GitHub"
echo "4. In the 'Pages' section, select 'gh-pages' branch as the source"
echo "5. Your site will be available at: https://YOUR_USERNAME.github.io/YOUR_REPO_NAME"

#!/bin/bash

LATEST_VERSION=$(curl -s 'https://api.github.com/repos/healthchecks/healthchecks/releases/latest' | jq -r '.tag_name');
CURRENT_VERSION=$(sed -nr 's/ARG HEALTHCHECKS_VERSION=*(.+)/\1/p' Dockerfile);
REPO_ADRESS=$(git config --get remote.origin.url | sed 's~http[s]*://~~g')

echo "Found versions:"
echo "  Latest:  ${LATEST_VERSION}"
echo "  Current: ${CURRENT_VERSION}"
echo "  Repo:    ${REPO_ADRESS}"

sed --in-place "s/HEALTHCHECKS_VERSION=${CURRENT_VERSION}/HEALTHCHECKS_VERSION=${LATEST_VERSION}/g" Dockerfile

git diff --exit-code . > /dev/null

if [ "$?" -eq "0" ]; then
	echo "No changes made. Nothig to do..."
    exit 0
else
	echo "Committing changes"
#	add changes and Push
    git config user.name "CraftingIT-Bot"
    git config user.email "craftingitbot@craftingit.de"
    git add Dockerfile
	git commit --message "Bump to latest version ${VERSION}"

git fetch --tags &> /dev/null
git show "${LATEST_VERSION}" &> /dev/null
if [ "$?" -eq "0" ]; then
	echo "Tag '${LATEST_VERSION}' already exist. Skipping..."
else

	echo "Tag '${LATEST_VERSION}' not exist. Creating..."
    git tag -a ${LATEST_VERSION} -m "New Version ${LATEST_VERSION} by CraftingIT-Bot"
fi
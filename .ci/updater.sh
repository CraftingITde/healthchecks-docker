#!/bin/bash

LATEST_VERSION=$(curl -s 'https://api.github.com/repos/healthchecks/healthchecks/releases/latest' | jq -r '.tag_name');
CURRENT_VERSION=$(sed -nr 's/ARG HEALTHCHECKS_VERSION=*(.+)/\1/p' Dockerfile);

echo "Found versions:"
echo "  Latest:  ${LATEST_VERSION}"
echo "  Current: ${CURRENT_VERSION}"
echo ""

sed --in-place "s/HEALTHCHECKS_VERSION=${CURRENT_VERSION}/HEALTHCHECKS_VERSION=${LATEST_VERSION}/g" Dockerfile

git diff --exit-code .

if [ "$?" -eq "0" ]; then
	echo "No changes made. Nothig to do..."
else
	echo "Committing changes"
	# add changes and Pusch
	#git add --all
	#git commit --message "Bump to latest version ${VERSION}"
	#git push origin master

fi
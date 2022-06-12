#!/bin/zsh

api='https://papermc.io/api/v2'
name='paper'
version='1.18'

# Get the build number of the most recent build
fetch_res="$(curl -sX GET "$api"/projects/"$name"/version_group/"$version"/builds -H 'accept: application/json')"
latest_version="$(echo -E $fetch_res | jq '.builds [-1].version' | sed 's/\"//g')"
latest_build="$(echo -E $fetch_res | jq '.builds [-1].build')"

# Construct download URL
download_url="$api"/projects/"$name"/versions/"$latest_version"/builds/"$latest_build"/downloads/"$name"-"$latest_version"-"$latest_build".jar

# Download file
wget "$download_url"

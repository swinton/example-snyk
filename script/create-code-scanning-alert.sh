#!/bin/sh

set -e

sarif_location=examples/snyk-code-test.sarif.json

# Change to root directory
cd $( dirname "$0" )/..

# Get the current user
# gh_user=$( gh api user --jq ".login" )
# echo "👋🌎 ${gh_user}"

# Encode the file and count the number of lines in the default output
line_count=$( base64 --input="${sarif_location}" | wc -l )

# If output has more than 1 line, use -w0 for single-line output
if [ "$line_count" -gt 1 ]; then
  b64encode="base64 -w0"
else
  b64encode="base64"
fi

# Write the request body with jq
gh_request_body=$( mktemp )
jq -n \
  --arg commit_sha "${GITHUB_SHA}" \
  --arg ref "${GITHUB_REF}" \
  --arg sarif "$(gzip -c $sarif_location | $b64encode)" \
'{
  commit_sha: $commit_sha,
  ref: $ref,
  sarif: $sarif
}' > $gh_request_body

cat $gh_request_body

# Upload an analysis as SARIF data
# https://docs.github.com/en/rest/code-scanning/code-scanning?apiVersion=2022-11-28#upload-an-analysis-as-sarif-data
gh api \
  "/repos/${GITHUB_REPOSITORY}/code-scanning/sarifs" \
  --method POST \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  --input "${gh_request_body}"

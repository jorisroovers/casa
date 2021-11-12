# Actual backup logic
USERNAME="{{github_username}}"
USERNAME="jorisroovers"
# Token generated via https://github.com/settings/tokens/new
TOKEN="{{github_access_token}}"

echo "Fetching starred repos..."
LENGTH=1
PAGE_NR=1
rm -f github-$USERNAME-starred.json # Remove any previously fetched results
while [ $LENGTH -gt 0 ]; do
    URL="https://api.github.com/user/starred?per_page=100&page=$PAGE_NR"
    echo "  Fetching $URL"
    RESULT=$(curl -u ${USERNAME}:${TOKEN} -s "$URL")
    echo $RESULT | jq -r '.[] | "\(.name)    \(.html_url)"' >> github-$USERNAME-starred.json
    LENGTH=$(echo $RESULT | jq -r ". | length")
    PAGE_NR=$(( $PAGE_NR + 1 ))
done
echo "All starred repos have been written to github-$USERNAME-starred.json"

echo "Fetching list of repositories..."
# For now, we only back up non-forked repos. This is because some of the forks are pretty large
REPOSITORIES="$(curl -u ${USERNAME}:${TOKEN} -s "https://api.github.com/user/repos?type=owner&per_page=150" | jq -r '.[] | select(.fork == false) | .html_url')"

echo $REPOSITORIES | tr " " "\n"

echo "Downloading repositories..."
for repository in $REPOSITORIES; do
    echo "Git Cloning ${repository}..."
    # Change url to form: https://<username>:<token>@<url>
    authenticated_url="${repository/https:\/\//https:\/\/$USERNAME:$TOKEN@}"
    git clone $authenticated_url
done

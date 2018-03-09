# Actual backup logic
USERNAME="{{github_username}}"
# Token generated via https://github.com/settings/tokens/new
TOKEN="{{github_access_token}}"

echo "Fetching list of repositories..."
# For now, we only back up non-forked repos. This is because some of the forks are pretty large
REPOSITORIES="$(curl -u ${USERNAME}:${TOKEN} -s "https://api.github.com/user/repos?type=owner" | jq -r '.[] | select(.fork == false) | .html_url')"

echo "Downloading repositories..."
for repository in $REPOSITORIES; do
    echo "Git Cloning ${repository}..."
    # Change url to form: https://<username>:<token>@<url>
    authenticated_url="${repository/https:\/\//https:\/\/$USERNAME:$TOKEN@}"
    git clone $authenticated_url
done

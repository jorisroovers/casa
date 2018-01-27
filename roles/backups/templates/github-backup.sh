# TODO(jorisroovers): support private repositories

# Actual backup logic
USERNAME="{{github_username}}"

echo "Fetching list of repositories..."
# For now, we only back up non-forked repos. This is because some of the forks are pretty large
REPOSITORIES="$(curl -s "https://api.github.com/users/${USERNAME}/repos" | jq -r '.[] | select(.fork == false) | .html_url')"

echo "Downloading repositories..."
for repository in $REPOSITORIES; do
    echo "Git Cloning ${repository}..."
    git clone $repository
done

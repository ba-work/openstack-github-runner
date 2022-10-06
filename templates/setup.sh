#!/bin/bash
set -euo pipefail

# proxy setting for avalon
export HTTP_PROXY=${proxy_settings.proxy}
export HTTPS_PROXY=${proxy_settings.proxy}
export NO_PROXY=${proxy_settings.no_proxy}

export RUNNER_ALLOW_RUNASROOT=true
export DEBIAN_FRONTEND=noninteractive


echo "%${admin_group} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${admin_group}
sed -i "1s/^/\+ : ${admin_group} : ALL\\n/" /etc/security/access.conf

apt-get update -qq
apt-get install jq -qq

# Create a folder
mkdir actions-runner && cd actions-runner

# Download the latest runner package
latest_version_label=$(curl -s -X GET 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')
latest_version=$(echo $${latest_version_label:1})
runner_file="actions-runner-linux-x64-$${latest_version}.tar.gz"
if [ -f "$${runner_file}" ]; then
    echo "$${runner_file} exists. skipping download."
else
    runner_url="https://github.com/actions/runner/releases/download/$${latest_version_label}/$${runner_file}"
    curl -O -L $${runner_url}
fi
tar xzf "./$${runner_file}"

# Install dependencies
./bin/installdependencies.sh

# get runner token
runner_token=$(curl -sX POST -H "Authorization: token ${token}" https://api.github.com/repos/${repo}/actions/runners/registration-token | jq -r '.token')


# Create the runner and start the configuration experience
./config.sh --unattended --url https://github.com/${repo} --name $(hostname) --token $${runner_token} --labels ${labels}

# Add proxy config
echo "" > ./.env
echo "http_proxy=${proxy_settings.proxy}" >> ./.env
echo "https_proxy=${proxy_settings.proxy}" >> ./.env
echo "no_proxy=${proxy_settings.no_proxy}" >> ./.env
# Install and start service
./svc.sh install
./svc.sh start
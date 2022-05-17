#!/usr/bin/env bash

mkdir -p ./lib/vagrant-goodhosts/bundle
cd ./lib/vagrant-goodhosts/bundle
# Download
curl -s https://api.github.com/repos/goodhosts/cli/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | xargs wget -i
# Extract
tar -zxvf goodhosts-1.1.0-darwin-amd64.tar.gz goodhosts && mv goodhosts cli_amd64_osx
tar -zxvf goodhosts-1.1.0-darwin-arm64.tar.gz goodhosts && mv goodhosts cli_arm64_osx
tar -zxvf goodhosts-1.1.0-linux-amd64.tar.gz goodhosts && mv goodhosts cli_amd64_linux
tar -zxvf goodhosts-1.1.0-linux-arm64.tar.gz goodhosts && mv goodhosts cli_arm64_linux
tar -zxvf goodhosts-1.1.0-windows-amd64.tar.gz goodhosts.exe && mv goodhosts.exe cli.exe
rm -f ./*.tar.gz
rm -f ./*.txt
# Generate
cd ../../../
gem build vagrant-goodhosts.gemspec
# gem push

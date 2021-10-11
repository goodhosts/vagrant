#!/usr/bin/env bash

mkdir -p ./lib/vagrant-goodhosts/bundle
cd ./lib/vagrant-goodhosts/bundle
# Download
curl -s https://api.github.com/repos/goodhosts/cli/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | xargs wget -i
# Extract
tar -zxvf goodhosts_darwin_amd64.tar.gz goodhosts && mv goodhosts cli_osx
tar -zxvf goodhosts_linux_amd64.tar.gz goodhosts && mv goodhosts cli
tar -zxvf goodhosts_windows_amd64.tar.gz goodhosts.exe && mv goodhosts.exe cli.exe
rm -f ./*.tar.gz
rm -f ./*.txt
# Generate
cd ../../../
gem build vagrant-goodhosts.gemspec
# gem push

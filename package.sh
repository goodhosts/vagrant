#!/usr/bin/env bash

mkdir -p ./lib/vagrant-goodhosts/bundle
cd ./lib/vagrant-goodhosts/bundle
# Download
curl -s https://api.github.com/repos/goodhosts/cli/releases/latest | jq --raw-output '.assets[] | .browser_download_url' | xargs -P16 wget -i
# Extract
tar -zxvf cli_darwin_amd64.tar.gz cli && mv cli cli_osx
tar -zxvf cli_linux_amd64.tar.gz cli
tar -zxvf cli_windows_amd64.tar.gz cli.exe
rm -f ./*.tar.gz
rm -f ./*.txt
# Generate
cd ../../../
gem build vagrant-goodhosts.gemspec

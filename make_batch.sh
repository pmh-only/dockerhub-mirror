#!/bin/bash

config=$(cat config.yml | python -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(str(sys.stdin.read()))))')
images=$(jq '[.images[] | .pull_from]' -c <<< "$config")

echo "images=$images" >> "$GITHUB_OUTPUT"

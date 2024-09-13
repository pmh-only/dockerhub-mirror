#!/bin/bash

alias yaml2json="python -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(str(sys.stdin.read()))))'"
config=$(cat config.yml | yaml2json)
images=$(jq ".images[]" -c <<< "$config")

while IFS=$"\n" read -r image; do
  
  pull_from=$(jq ".pull_from" -rc <<< "$image")
  push_to=$(jq ".push_to" -rc <<< "$image")
  platforms=$(jq ".platforms[]" -rc <<< "$image")
  amends=""

  while IFS=$"\n" read -r platform; do

    docker image pull $pull_from --platform $platform
    docker image tag $pull_from $push_to-$platform
    docker image push $push_to-$platform

    amends+="--amend $push_to-$platform"

  done <<< "$platforms"

  docker manifest create $push_to $amends
  docker manifest push $push_to

done <<< "$images"

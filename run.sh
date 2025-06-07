#!/bin/bash

config=$(cat config.yml | python -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(str(sys.stdin.read()))))')
image=$(jq '.images[] | select(.pull_from=="'$1'")' -c <<< "$config")

pull_from=$(jq ".pull_from" -rc <<< "$image")
push_to=$(jq ".push_to" -rc <<< "$image")
platforms=$(jq ".platforms[]" -rc <<< "$image")
amends=""

while IFS=$"\n" read -r platform; do
  platform_safe=$(sed 's/\//-/' <<< "$platform")

  docker image pull $pull_from --platform $platform
  docker image tag $pull_from $push_to-$platform_safe
  docker image push $push_to-$platform_safe

  amends+="--amend $push_to-$platform_safe "
done <<< "$platforms"

echo Amend flags: $amends

docker manifest create $push_to $amends
docker manifest push $push_to

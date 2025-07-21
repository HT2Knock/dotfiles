#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

CUB_DOCKER_PATH="/home/t2knock/Documents/Cubable/docker_cubable"

main() {
  pushd ${CUB_DOCKER_PATH}

  branch="$(gum input --placeholder="What your build branch?")"
  tags="$(gum input --placeholder="What your build tags?")"

  make build-args "${branch}" "${tags}"

  notify-send -u low -i face-smile "Cubable image build finish !!"
}

main "$@"

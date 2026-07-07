#!/bin/sh
# Resolve an app's VERSION: prefer bake's default; fall back to the app's
# resolve-version.sh when the default is empty (dynamic-version apps).
set -eu

app_dir="${1:-.}"

version=$(\
    docker buildx bake --file "${app_dir}/docker-bake.hcl" --list type=variables,format=json --progress=quiet \
        | jq --raw-output '.[] | select(.name == "VERSION") | .value' \
)

if [ -z "${version}" ] && [ -x "${app_dir}/resolve-version.sh" ]; then
    version=$(cd "${app_dir}" && ./resolve-version.sh)
fi

printf '%s' "${version}"

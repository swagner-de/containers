#!/bin/sh
# Resolve an app's build revision: the number of build-affecting commits since
# the commit that last changed the app's version.
#
# Static-version apps  (VERSION set in docker-bake.hcl): the version anchor is
#   the last commit that changed the VERSION value in docker-bake.hcl.
# Dynamic-version apps (empty VERSION + resolve-version.sh): the version tracks
#   the base image, so the anchor is the last commit that changed the FROM line
#   in the Dockerfile.
#
# Build-affecting files: Dockerfile, entrypoint.sh, docker-bake.hcl,
# resolve-version.sh. Changes to tests or READMEs do not advance the revision.
#
# Prints the revision as an integer. Falls back to 0 when no anchor can be
# found on a full-history clone (a genuine first build), which publishes the
# immutable base tags. On a SHALLOW clone the anchor may simply be truncated
# away, so emitting 0 would falsely look like a first build and overwrite the
# immutable X.Y.Z tag; guard against that by refusing to run without full
# history (callers must checkout with fetch-depth: 0).
set -eu

app_dir="${1:-.}"
bake="${app_dir}/docker-bake.hcl"

build_paths="${app_dir}/Dockerfile ${app_dir}/entrypoint.sh ${bake} ${app_dir}/resolve-version.sh"

if [ "$(git rev-parse --is-shallow-repository 2>/dev/null)" = "true" ]; then
    echo "app-build.sh: refusing to run on a shallow clone (checkout with fetch-depth: 0)" >&2
    exit 1
fi

version=$(\
    docker buildx bake --file "${bake}" --list type=variables,format=json --progress=quiet \
        | jq --raw-output '.[] | select(.name == "VERSION") | .value' \
)

if [ -n "${version}" ]; then
    # Static app: anchor on the last commit whose diff touched the line that
    # sets VERSION to its current value. Match the full `default = "<version>"`
    # assignment (version escaped for regex) rather than a bare substring, so a
    # new version that is a substring of the old one (e.g. 3.21 -> 3.2) still
    # anchors on the bump commit.
    # shellcheck disable=SC2016  # single quotes are intentional (sed script, \& is a backref)
    version_re=$(printf '%s' "${version}" | sed 's/[.[\*^$()+?{|]/\\&/g')
    anchor=$(git log -1 --format=%H -G"default = \"${version_re}\"" -- "${bake}" 2>/dev/null || true)
else
    # Dynamic app: anchor on the last change to the FROM (base image) line.
    anchor=$(git log -1 --format=%H -G'^FROM ' -- "${app_dir}/Dockerfile" 2>/dev/null || true)
fi

if [ -z "${anchor}" ]; then
    printf '0'
    exit 0
fi

# shellcheck disable=SC2086
git rev-list --count "${anchor}..HEAD" -- ${build_paths} 2>/dev/null || printf '0'

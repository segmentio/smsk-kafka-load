#!/bin/bash
set -xo pipefail

# Figure out modified directories
if [[ $BUILDKITE_PULL_REQUEST != "false" ]]; then
    # We're building a PR
    base=origin/${BUILDKITE_PULL_REQUEST_BASE_BRANCH}
else
    # We're building master. This assumes commits on master come via merge or squash commits
    base=$(git show HEAD~1 --format=format:%H | head -1)
fi

for path in $(git diff --name-only `git merge-base $base HEAD` </dev/null); do
    dirname "$path"
done | sort -u > /tmp/modified-directories

# Build the image in each modified directory
for subdir in $(cat /tmp/modified-directories)
do
    echo "--- Processing $subdir"
    if [ -f $subdir/Makefile ]; then
        pushd "$subdir"
        make buildpush
        popd
    else
        echo "No Makefile in $subdir, skipping"
    fi
done

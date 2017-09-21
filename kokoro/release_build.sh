#!/bin/bash

# Fails on any error.
set -e
# Displays commands to stderr.
set -x

cd github/app-maven-plugin

ARTIFACT_ID=$(mvn -B help:evaluate -Dexpression=project.artifactId 2>/dev/null | grep -v "^\[")
PROJECT_VERSION=$(mvn -B help:evaluate -Dexpression=project.version 2>/dev/null| grep -v "^\[")


echo "ARTIFACT_ID=$ARTIFACT_ID"
echo "PROJECT_VERSION=$PROJECT_VERSION"
echo "$KOKORO_GFILE_DIR"

cd $KOKORO_GFILE_DIR

# Finds the latest directory under prod/app-maven-plugin/ubuntu/release/.
LAST_BUILD=$(ls prod/app-maven-plugin/ubuntu/release/ | sort -rV | head -1)

echo "LAST_BUILD=$LAST_BUILD"

# Finds the bundled jars in the latest signed artifact directory.
FILES=$(find `pwd`/prod/app-maven-plugin/gcp_ubuntu/release/${LAST_BUILD}/* -type f \( -iname \*-bundle.jar \))

echo "FILES=$FILES"

"appengine-maven-plugin-1.3.2-SNAPSHOT-bundle.jar"


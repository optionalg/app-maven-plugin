#!/bin/bash

# Fail on any error.
set -e
# Display commands to stderr.
set -x

cd github/app-maven-plugin

# copy pom with the name expected in the Maven repository
ARTIFACT_ID=$(mvn -B help:evaluate -Dexpression=project.artifactId 2>/dev/null | grep -v "^\[")
PROJECT_VERSION=$(mvn -B help:evaluate -Dexpression=project.version 2>/dev/null| grep -v "^\[")


echo "ARTIFACT_ID=$ARTIFACT_ID"
echo "PROJECT_VERSION=$PROJECT_VERSION"


#!/bin/bash

# Fail on any error.
# set -e
# Display commands to stderr.
set -x


### REMOVE THIS
echo "Publishing test!"
# TODO: Implement publishing to Sonatype.

# pwd
# cd github/app-maven-plugin

# ARTIFACT_ID=$(mvn -B help:evaluate -Dexpression=project.artifactId 2>/dev/null | grep -v "^\[")
# PROJECT_VERSION=$(mvn -B help:evaluate -Dexpression=project.version 2>/dev/null| grep -v "^\[")


# echo "ARTIFACT_ID=$ARTIFACT_ID"
# echo "PROJECT_VERSION=$PROJECT_VERSION"
echo "$KOKORO_GFILE_DIR"

ls $KOKORO_ARTIFACTS_DIR
ls $KOKORO_GFILE_DIR

tree $KOKORO_ARTIFACTS_DIR
tree $KOKORO_GFILE_DIR

pwd
cd $KOKORO_GFILE_DIR

# Finds the latest directory under prod/app-maven-plugin/ubuntu/release/.
LAST_BUILD=$(ls prod/app-maven-plugin/ubuntu/release/ | sort -rV | head -1)

echo "LAST_BUILD=$LAST_BUILD"

# Finds the bundled jars in the latest signed artifact directory.
FILES=$(find `pwd`/prod/app-maven-plugin/gcp_ubuntu/release/${LAST_BUILD}/* -type f \( -iname \*-bundle.jar \))

echo "FILES=$FILES"

"appengine-maven-plugin-1.3.2-SNAPSHOT-bundle.jar"

exit 0
### END REMOVE THIS



sudo /opt/google-cloud-sdk/bin/gcloud components update
sudo /opt/google-cloud-sdk/bin/gcloud components install app-engine-java

cd github/app-maven-plugin
./mvnw -Prelease -B -U verify

# copy pom with the name expected in the Maven repository
ARTIFACT_ID=$(mvn -B help:evaluate -Dexpression=project.artifactId 2>/dev/null | grep -v "^\[")
PROJECT_VERSION=$(mvn -B help:evaluate -Dexpression=project.version 2>/dev/null| grep -v "^\[")
cp pom.xml target/${ARTIFACT_ID}-${PROJECT_VERSION}.pom


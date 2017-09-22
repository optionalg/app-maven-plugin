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

echo "$SONATYPE_USERNAME"
echo "$SONATYPE_PASSWORD"

echo "$KOKORO_GFILE_DIR"

cd $KOKORO_GFILE_DIR

ls prod
ls prod/app-maven-plugin
ls prod/app-maven-plugin/ubuntu
ls prod/app-maven-plugin/ubuntu/release-sign

# Finds the latest ubuntu/release-sign build directory.
LAST_BUILD=$(ls prod/app-maven-plugin/ubuntu/release-sign/ | sort -rV | head -1)

echo "LAST_BUILD=$LAST_BUILD"

# Finds the bundled jars in the latest signed artifact directory.
FILES=$(find `pwd`/prod/app-maven-plugin/ubuntu/release-sign/${LAST_BUILD}/* -type f \( -iname \*-bundle.jar \))

echo "FILES=$FILES"

"appengine-maven-plugin-1.3.2-SNAPSHOT-bundle.jar"

exit 1

# Usage: GetSessionID <username> <password> <variable name>
# Stores the Nexus session ID in the given variable.
GetSessionID() {
	local username=$1
	local password=$2
	local __resultvar=$3

	# Converts the credentials from <username>:<password> form to base64.
	local credentials="$username:$password"
	local credentials64=$(echo -n $credentials | base64)

	local cookies_temp=$(mktemp /tmp/sonatype_cookies.XXXXXXX)

	# Gets the session ID.
	local login_response=$(curl 'https://oss.sonatype.org/service/local/authentication/login' -X 'GET' -H "Authorization: Basic $credentials64" -c $cookies_temp 2> /dev/null)

	# Checks if login was successful.
	echo $login_response | grep -q '<loggedIn>true</loggedIn>'

	local login_check=$(echo -n $?)

	if [ "$login_check" -eq "1" ]; then
		return 1
	fi

	local nxsessionid
	local nxsessionid_line=$(cat $cookies_temp | grep 'NXSESSIONID')
	nxsessionid=$(echo -n $nxsessionid_line | awk '{print $NF}')

	eval $__resultvar="'$nxsessionid'"
}

# Usage: UploadJAR <session ID> <file>
# Uploads the bundled JAR file to the Nexus Staging Repository.
UploadJAR() {
	curl 'https://oss.sonatype.org/service/local/staging/bundle_upload' -H "Cookie: NXSESSIONID=$1" -H 'Content-Type: multipart/form-data' --compressed -F "file=@$2"
}

# Get the session ID.
GetSessionID $SONATYPE_USERNAME $SONATYPE_PASSWORD NXSESSIONID
if [ $? -eq 1 ]; then
	Die 'Login failed!'
fi
echo 'Login successful.'

# Upload the bundled JAR file.
echo 'Uploading artifact...'
# UploadJAR $NXSESSIONID $BUNDLED_JAR_FILE

### END REMOVE THIS



sudo /opt/google-cloud-sdk/bin/gcloud components update
sudo /opt/google-cloud-sdk/bin/gcloud components install app-engine-java

cd github/app-maven-plugin
./mvnw -Prelease -B -U verify

# copy pom with the name expected in the Maven repository
ARTIFACT_ID=$(mvn -B help:evaluate -Dexpression=project.artifactId 2>/dev/null | grep -v "^\[")
PROJECT_VERSION=$(mvn -B help:evaluate -Dexpression=project.version 2>/dev/null| grep -v "^\[")
cp pom.xml target/${ARTIFACT_ID}-${PROJECT_VERSION}.pom


#!/bin/bash
set -e
set -x

echo "Checking if repo needs to be updated"
ORG="IBM-Swift"
REPO="generator-swiftserver-projects"
GH_REPO="github.com/${ORG}/${REPO}.git"
BRANCHES="init openAPI"
projectName="Generator-Swiftserver-Projects"

SUCCESS="" # List of successful updates
FAIL=""    # List of failed updates

# Builds a list of branchs that failed to update (if any)
function fail () {
  FAIL="$FAIL $1" && echo "Failed to push to branch: $BRANCH"
}

for BRANCH in $BRANCHES
do
  cd "${TRAVIS_BUILD_DIR}"
  rm -rf current
  rm -rf new
  mkdir current
  cd current
  git clone -b "${BRANCH}" "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${ORG}/${REPO}.git"
  currentProject=$(pwd)

  mkdir -p "${TRAVIS_BUILD_DIR}/new/${projectName}"
  cd "${TRAVIS_BUILD_DIR}/new/${projectName}"
  if [[ "${BRANCH}" == "init" ]]
  then
    yo swiftserver --init --skip-build
  elif [[ "$BRANCH" == "openAPI" ]]
  then
    yo swiftserver --app --spec '{ "appName":"'"$projectName"'", "appType":"scaffold", "appDir":".", "openapi":true, "docker":true, "metrics":true, "healthcheck":true }' --skip-build
    rm spec.json
  else
    exit
  fi

  echo "Generate README rtf"
  pandoc README.md -f markdown_github -t rtf -so README.rtf
  cd "${TRAVIS_BUILD_DIR}"/new
  newProject=$(pwd)

  currentRepo="${currentProject}/${REPO}"
  newRepo="${newProject}/${projectName}"

  if diff -x '.git' -r "${currentRepo}" "${newRepo}"
  then
    echo "Project does not need to be updated"
    rm -rf "${currentRepo}" "${newRepo}"
    exit 1
  fi

  echo "Project needs to be updated"
  cp -r "${newProject}/${projectName}/." "${currentProject}/${REPO}"
  cd "${currentProject}/${REPO}"
  git add -A
  git commit -m "CRON JOB: Updating generated project"
  git push origin "${BRANCH}" || fail "${BRANCH}" || continue
  SUCCESS="$SUCCESS $BRANCH"
  cd "${TRAVIS_BUILD_DIR}"
done

echo Success: $SUCCESS
echo Failed: $FAIL

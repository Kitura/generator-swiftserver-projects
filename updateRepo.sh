#!/bin/bash
set -ex

echo "Checking if repo needs to be updated"

if [[ $TRAVIS == true ]]
then GH_REPO="github.com/${TRAVIS_REPO_SLUG}.git"
else 
  # If running locally set ORG to the Org of your fork.
  ORG="<my-org>"
  REPO="generator-swiftserver-projects"
  GH_REPO="github.com/${ORG}/${REPO}.git"
fi

echo GH_REPO

BRANCHES="init openAPI"
projectName="Generator-Swiftserver-Projects"

SUCCESS="" # List of successful updates
FAIL=""    # List of failed updates

# Builds a list of branchs that failed to update (if any)
function fail () {
  FAIL="$FAIL $1" && echo "Failed to push to branch: $BRANCH"
  return 1
}

for BRANCH in $BRANCHES
do
  echo "Generating project for ${BRANCH}"
  cd "${TRAVIS_BUILD_DIR}"
  rm -rf current
  rm -rf new
  git clone -b "${BRANCH}" "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@${GH_REPO}" current
  currentProject="$(pwd)/current"

  # Need to create a project directory and move into it so we can run the generator.
  mkdir -p "new/${projectName}" && cd "new/${projectName}"
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
  # Step back into the travis build directory after generator has finished.
  cd "${TRAVIS_BUILD_DIR}"

  echo "Generate README rtf"
  pandoc README.md -f markdown_github -t rtf -so README.rtf
  newProject="$(pwd)/new"

  currentRepo="${currentProject}/${REPO}"
  newRepo="${newProject}/${projectName}"

  if diff -x '.git' -r "${currentRepo}" "${newRepo}"
  then
    echo "Project does not need to be updated"
    rm -rf "${currentProject}" "${newProject}"
    continue
  fi

  echo "Project needs to be updated"
  rsync -av --ignore-times "${newRepo}/" "${currentRepo}/"
  cd "${currentRepo}"
  git add -A
  git commit -m "CRON JOB: Updating generated project"
  if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
  then git push origin "${BRANCH}" || fail "${BRANCH}" || continue
  fi
  SUCCESS="$SUCCESS $BRANCH"
done

echo Success: $SUCCESS
echo Failed: $FAIL

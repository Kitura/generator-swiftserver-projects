#!/bin/bash
set -ex

echo "Checking if repo needs to be updated"
ORG="ddunn2"
REPO="generator-swiftserver-projects"
GH_REPO="github.com/${ORG}/${REPO}.git"
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
  cd "${TRAVIS_BUILD_DIR}"
  rm -rf current
  rm -rf new
  git clone -b "${BRANCH}" "https://ddunn2:${GITHUB_PASS}@github.com/${ORG}/${REPO}.git" current
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
    rm -rf "${currentRepo}" "${newRepo}"
    exit 1
  fi

  echo "Project needs to be updated"
  rsync -av --ignore-times "${newRepo}/" "${currentRepo}"
  cd "${currentRepo}"
  git add -A
  git commit -m "CRON JOB: Updating generated project"
  git push origin "${BRANCH}" || fail "${BRANCH}" || continue
  SUCCESS="$SUCCESS $BRANCH"
done

echo Success: $SUCCESS
echo Failed: $FAIL

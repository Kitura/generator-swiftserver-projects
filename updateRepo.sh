#!/bin/bash

echo "Checking if repo needs to be updated"
export ORG="IBM-Swift"
export REPO="generator-swiftserver-projects"
export GH_REPO="github.com/${ORG}/${REPO}.git"
export BRANCHES="init openAPI"
export projectName="Generator-Swiftserver-Projects"

for BRANCH in $BRANCHES
do
  cd "${TRAVIS_BUILD_DIR}" || exit
  mkdir current
  cd current || exit
  git clone -b "${BRANCH}" "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${ORG}/${REPO}.git"
  currentProject=$(pwd)

  mkdir -p "${TRAVIS_BUILD_DIR}/new/${projectName}"
  cd "${TRAVIS_BUILD_DIR}/new/${projectName}" || exit
  if [[ "${BRANCH}" == "init" ]]
  then
    yo swiftserver --init --skip-build
  elif [[ "$BRANCH" == "openAPI" ]]
  then
    yo swiftserver --app --spec '{ "appName":"'"$projectName"'", "appType":"scaffold", "appDir":".", "openapi":true, "docker":true, "metrics":true, "healthcheck":true }' --skip-build
  fi

  rm spec.json
  echo "Generate README rtf"
  pandoc README.md -f markdown_github -t rtf -so README.rtf
  cd "${TRAVIS_BUILD_DIR}"/new || exit
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
  cd "${currentProject}/${REPO}" || exit
  git add .
  git commit -m "CRON JOB: Updating generated project"
  git push origin "${BRANCH}"
  cd "${TRAVIS_BUILD_DIR}" || exit
  rm -rf current
  rm -rf new
done

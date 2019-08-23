#!/bin/bash
set -ex

if [[ $TRAVIS == true ]]
then
  GH_REPO="github.com/${TRAVIS_REPO_SLUG}.git"
else 
  # If running locally set ORG to the Org of your fork.
  ORG="<my-org>"
  REPO="generator-swiftserver-projects"
  GH_REPO="github.com/${ORG}/${REPO}.git"
fi

# Determine location of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Checking if repo needs to be updated"
echo GH_REPO

# List of branches that this script should try to update. Each of these must have
# a generator command line associated in the script below.
BRANCHES="init openAPI"

# Name of project that should be generated. Note, this MUST match the name that is
# hard-coded in kitura-cli, which will be replaced by a user's chosen project name.
projectName="Generator-Swiftserver-Projects"

# Process each branch
for BRANCH in $BRANCHES
do
  cd "${SCRIPT_DIR}"
  currentProject="${SCRIPT_DIR}/current/${BRANCH}"
  newProjectDir="${SCRIPT_DIR}/new/${BRANCH}"
  newProject="${newProjectDir}/${projectName}"

  # Start from a clean state
  rm -rf "${currentProject}"
  mkdir -p "${currentProject}"
  rm -rf "${newProjectDir}"
  mkdir -p "${newProject}"

  # Clone the current state of this branch
  echo "Generating project for ${BRANCH}"
  git clone -b "${BRANCH}" "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@${GH_REPO}" "${currentProject}"

  # Run the generator command associated with this branch name:
  cd "${newProject}"
  case "${BRANCH}" in
  init)
    yo --no-insight swiftserver --init --skip-build
    ;;
  openAPI)
    yo --no-insight swiftserver --app --spec '{ "appName":"'"$projectName"'", "appType":"scaffold", "appDir":".", "openapi":true, "docker":true, "metrics":true, "healthcheck":true }' --skip-build
    ;;
  *)
    echo "Error - no recipe for branch '${BRANCH}'."
    exit
  esac
  # Remove files that are excluded from the generated project
  rm spec.json

  # Diff the current and newly generated projects. If any files have changed,
  # they should be committed and pushed to the branch.
  if diff -x '.git' -r "${currentProject}" "${newProject}"
  then
    echo "Project does not need to be updated"
    continue
  fi

  # Files differed - use rsync to update files that have changed
  echo "Project needs to be updated"
  rsync -avc --delete --exclude '.git' "${newProject}/" "${currentProject}/"
  
  # CD to the newly updated project
  cd "${currentProject}"
  
  # Update the README.rtf
  echo "Generate README rtf"
  pandoc README.md -f markdown_github -t rtf -so README.rtf

  # Add all changes. Only commit and push if we detect this script is running as
  # part of a Travis build (and not a pull request).
  git add -A
  if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
  then
    git commit -m "CRON JOB: Updating generated project"
    git push origin "${BRANCH}"
  else
    echo "Skipping push (not a cron job). Changes can be inspected in:"
    echo "  ${currentProject}"
  fi
done

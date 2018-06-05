echo "Checking if repo needs to be updated"
export ORG="IBM-Swift"
export REPO="generator-swiftserver-projects"
export GH_REPO="github.com/${ORG}/${REPO}.git"
export BRANCH="init"
export projectName="Generator-Swiftserver-Projects"

cd ${TRAVIS_BUILD_DIR}
mkdir current
cd current
git clone -b ${BRANCH} "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${ORG}/${REPO}.git"
export currentProject=`pwd`

mkdir -p ../new/${projectName}
cd ../new/${projectName}
yo swiftserver --init --skip-build
echo "Generate README rtf"
pandoc README.md -f markdown_github -t rtf -so README.rtf
cd ../
export newProject=`pwd`

if diff -x '.git' -r ${currentProject}/${REPO} ${newProject}/${projectName}
then
  echo "Project does not need to be updated"
  rm -rf ${currentProject}/${REPO} ${newProject}/${projectName}
  exit 1
fi

echo "Project needs to be updated"
cp -r ${newProject}/${projectName}/. ${currentProject}/${REPO}
cd ${currentProject}/${REPO}
git add .
git commit -m "CRON JOB: Updating generated project"
git push origin ${BRANCH}

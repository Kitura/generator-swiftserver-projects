echo "Checking if repo needs to be updated"
export ORG="IBM-Swift"
export REPO="generator-swiftserver-projects"
export GH_REPO="github.com/${ORG}/${REPO}.git"
export projectName="Generator-Swiftserver-Projects"
export scriptDir=`pwd`

mkdir ${TRAVIS_BUILD_DIR}/current
cd ${TRAVIS_BUILD_DIR}/current
export currentProject=`pwd`
git clone "https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${ORG}/${REPO}.git"

for branch in "init" "openAPI"
do
  export BRANCH=${branch}
  ${scriptDir}/updateRepo.sh
done
#
# export BRANCH="init"
# ${scriptDir}/updateRepo.sh
#
# export BRANCH="openAPI"
# ${scriptDir}/updateRepo.sh

export projectName="Generator-Swiftserver-Projects"
cd ${TRAVIS_BUILD_DIR}
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`

for branch in "init" "openAPI"
do
  mkdir ${projectFolder}/${branch}
  cd ${projectFolder}/${branch}
  echo "Generating project"
  case "$branch" in
       init) yo swiftserver --init --skip-build ;;
    openAPI) yo swiftserver --app --skip-build --spec \
            '{ "appName": "'${projectName}'", "appType": "scaffold", "appDir": ".", "openapi": true, "docker": true, "metrics": true, "healthcheck": true }' ;;
          *) echo "Cannot generate project for this type." ;;
  esac
  echo "Testing '${branch}' swiftserver generated project"
  git clone https://github.com/IBM-Swift/Package-Builder.git
  ${projectFolder}/${branch}/Package-Builder/build-package.sh -projectDir ${projectFolder}/${branch}
done

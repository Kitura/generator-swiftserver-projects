export projectName="generator-swiftserver-projects"
cd ${TRAVIS_BUILD_DIR}
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
export SWIFT_SNAPSHOT=swift-4.0.3
echo "Testing swiftserver generated project"
git clone https://github.com/IBM-Swift/Package-Builder.git
if ! ./Package-Builder/build-package.sh -projectDir .
then
  echo "FAILED"
  cd ${TRAVIS_BUILD_DIR}
  rm -rf ${projectFolder}
  exit 1
fi
cd ${TRAVIS_BUILD_DIR}
rm -rf ${projectFolder}

export projectName="swiftserver-generator-projects"
export startDir=`pwd`
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
export SWIFT_SNAPSHOT=swift-4.0.3
echo "Testing swiftserver generated project"
if ! ./Package-Builder/build-package.sh -projectDir .
then
  echo "FAILED"
  cd ${startFolder}
  rm -rf ${projectFolder}
  exit 1
fi
cd ${startFolder}
rm -rf ${projectFolder}

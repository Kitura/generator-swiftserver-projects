#!/bin/bash
export projectName="Generator-Swiftserver-Projects"

if [[ $TRAVIS == true ]]; then
  cd ${TRAVIS_BUILD_DIR}
fi

mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
echo "Testing swiftserver generated project"
git clone https://github.com/Kitura/Package-Builder.git

export projectName="generator-swiftserver-projects"
cd ${TRAVIS_BUILD_DIR}
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
echo "Testing swiftserver generated project"
git clone https://github.com/IBM-Swift/Package-Builder.git
./Package-Builder/build-package.sh -projectDir ${projectFolder}
if [ $? -eq 0 ]; then
    echo "Generated project built successfully"
    cd ${TRAVIS_BUILD_DIR}
    rm -rf ${projectFolder}
else
    echo "FAILURE: Could not build generated project"
    cd ${TRAVIS_BUILD_DIR}
    rm -rf ${projectFolder}
fi

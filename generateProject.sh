export projectName="generator-swiftserver-projects"
cd ${TRAVIS_BUILD_DIR}
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
echo "Testing swiftserver generated project"
git clone https://github.com/alexwishart/Package-Builder.git -b debug

export projectName="Generator-Swiftserver-Projects"
cd ${TRAVIS_BUILD_DIR}
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
echo "Generate README rtf"
pandoc README.md -f gfm -t rtf -so README.rtf
echo "Testing swiftserver generated project"
git clone https://github.com/IBM-Swift/Package-Builder.git

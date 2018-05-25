export projectName="Generator-Swiftserver-Projects"
cd ${TRAVIS_BUILD_DIR}
mkdir ${projectName}
cd ${projectName}
export projectFolder=`pwd`
echo "Generating project"
yo swiftserver --init --skip-build
echo "Generate README pdf"
markdown-pdf README.pdf
echo "Testing swiftserver generated project"
git clone https://github.com/IBM-Swift/Package-Builder.git

echo "Testing swiftserver generated project"
if ! ./Package-Builder/build-package.sh -projectDir .
then
  echo "FAILED"
  rm -rf $projectFolder
  exit 1
fi

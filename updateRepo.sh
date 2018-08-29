cd ${currentProject}/${REPO}
git checkout ${BRANCH}

mkdir -p ${TRAVIS_BUILD_DIR}/new/${BRANCH}/${projectName}
cd ${TRAVIS_BUILD_DIR}/new
export newProject=`pwd`

cd ${newProject}/${BRANCH}/${projectName}
case "$BRANCH" in
     init) yo swiftserver --init --skip-build ;;
  openAPI) yo swiftserver --app --skip-build --spec \
          '{ "appName": "'${projectName}'", "appType": "scaffold", "appDir": ".", "openapi": true, "docker": true, "metrics": true, "healthcheck": true }' ;;
        *) echo "Cannot generate project for this type." ;;
esac

echo "Generate README rtf"
pandoc README.md -f markdown_github -t rtf -so README.rtf
cd ../


if diff -x '.git' -r ${currentProject}/${REPO} ${newProject}/${BRANCH}/${projectName}
then
  echo "Project does not need to be updated"
  rm -rf ${currentProject}/${REPO} ${newProject}/${BRANCH}/${projectName}
  exit 1
fi

echo "Project needs to be updated"
cp -r ${newProject}/${BRANCH}/${projectName}/. ${currentProject}/${REPO}
cd ${currentProject}/${REPO}
git add .
git commit -m "CRON JOB: Updating generated project"
git push origin ${BRANCH}

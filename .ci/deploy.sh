#!/bin/bash

# for your information
whoami
printenv

# we need to extract the ssh/git URL as the runner uses a tokenized URL
export CI_PUSH_REPO=`echo $CI_BUILD_REPO | perl -pe 's#.*@(.+?(\:\d+)?)/#git@\1:#'`

# runner runs on a detached HEAD, create a temporary local branch for editing
git checkout -b tmpBranch
git config --global user.name "artenobot"
git config --global user.email "artenobot@uni.lu"
git remote set-url --push origin "${CI_PUSH_REPO}"

# commit
git commit -am "Update models"

# push changes
# always return true so that the build does not fail if there are no changes
git push origin tmpBranch:${CI_BUILD_REF_NAME} || true

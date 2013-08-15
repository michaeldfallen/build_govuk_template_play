
thisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
templateDir="$thisDir/govuk_template"
pkgDir="$templateDir/pkg"
playDir="$thisDir/govuk_template_play"

cd $playDir
#now in ./govuk_template_play
echo "Updating govuk_template_play submodule"
playSha="$(git rev-parse HEAD)"
git checkout master
git pull -q

cd $templateDir
#now in ./govuk_template
echo "Updating govuk_template submodule"
templateSha="$(git rev-parse HEAD)"
git checkout master
git pull -q
rm -rf $pkgDir

echo "Compiling govuk_template for play using build:play"
bundle exec rake build:play

cd $playDir
#now in ./govuk_template_play
tar -xf $pkgDir/play_govuk_template*
cp -r play_govuk_template-*/* .
version="$(ls $pkgDir | grep play | grep -Eo "\d.\d.\d" )"
rm -rf play_govuk_template-*

if [[ -n "$(git tag | grep -o $version)" ]]; then
  echo ""
  echo "Tag already exists, reverting."
  git reset --hard HEAD
  git checkout $playSha
  cd $templateDir
  git reset --hard HEAD
  git checkout $templateSha
  cd $thisDir
  git reset --hard HEAD
  echo "Bump the version number then run build again."	
else 
	git add -A .
	git commit -q -m "deploying Govuk Play templates $version"
	git tag -af v$version -m "deploying $version"
	git push 
  git push --tags
  cd $thisDir
  git add -A .
  git commit -q -m "updated govuk_template and govuk_template_play submodules"
  git push
fi

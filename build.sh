
thisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
templateDir="$thisDir/govuk_template"
pkgDir="$templateDir/pkg"
playDir="$thisDir/govuk_template_play"

cd $playDir
#now in ./govuk_template_play
echo "Updating govuk_template_play submodule"
git pull -q

cd $templateDir
#now in ./govuk_template
echo "Updating govuk_template submodule"
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

echo "Version $version compiled. Should I deploy?"
read deploy

if [[ "$deploy" == y* ]] || [[ "$deploy" == Y* ]]; then
  if [[ -n "$(git tag | grep -o $version)" ]]; then
    echo ""
    echo "Tag already exists, reverting."
    git reset --hard HEAD
    echo "Bump the version number then run build again."	
  else 
  	git add -A .
  	git commit -q -m "deploying Govuk Play templates $version"
  	git tag -af v$version -m "deploying $version"
  	git push 
    git push --tags 
  fi
fi

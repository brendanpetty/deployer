#!/bin/bash

echo "****************************"
echo "*   BEGIN INSTALL SCRIPT   *"
echo "****************************"
echo ""

read -p "Enter SITEPATH (doc root location within ~, like public_html or sub): " SITEPATH
read -p "Enter REPOPATH (i.e. vendor name including trailing slash): " REPOPATH
read -p "Enter REPONAME (not including vendor name or slashes): " REPONAME
read -p "Enter GITHUBPAT (Personal Access Token, from https://github.com/settings/tokens with *contents read* on the specified repo): " GITHUBPAT

echo " "
read -p "$SITEPATH and ${SITEPATH}_app will be deleted. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

rm -Rf ~/${SITEPATH}
mkdir ~/${SITEPATH}_app

read -p "Repo will be cloned. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

cd ~/${SITEPATH}_app
git clone https://${GITHUBPAT}@github.com/${REPOPATH}${REPONAME}.git
git clone $(printf "https://%s@" "$GITHUBPAT")$(printf "github.com/%s%s.git" "$REPOPATH" "$REPONAME")
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Success"
else
  echo "Git Clone failed. Aborting."
  exit 1
fi

read -p "Symlink to app directory will be created. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

ln -s ~/${SITEPATH}_app/${REPONAME}/public ~/${SITEPATH}

read -p "Deployer config file will be written. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

echo "SITEPATH=${SITEPATH}" > ~/${SITEPATH}_app/config.sh
echo "REPONAME=${REPONAME}" >> ~/${SITEPATH}_app/config.sh

read -p "Composer will install packages. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

cd ~/${SITEPATH}_app/${REPONAME}
composer install --no-dev
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Success"
else
  echo "Composer install failed. Aborting."
  exit 1
fi

# Check if .env.example file exists
if [[ -f ".env.example" ]]; then
  read -p "env file will be initialised. Do you want to continue? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
      echo "Aborting."
      exit 1
  fi

  cp .env.example .env
  sed -i '/^APP_ENV=/c\APP_ENV=production' .env
  sed -i '/^APP_DEBUG=/c\APP_DEBUG=false' .env
fi

# Check if artisan is installed
if [[ -f "artisan" ]]; then
  php artisan key:generate
else
  echo "No PHP Artisan installed, skipping .env key generation"
fi

read -p "Symlink to deployer update will be created. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
fi

chmod u+x vendor/brendanpetty/deployer/run.sh
ln -s ~/${SITEPATH}_app/${REPONAME}/vendor/brendanpetty/deployer/run.sh ~/deploy_${SITEPATH}.sh
echo "In future, call:  ~/deploy_${SITEPATH}.sh"

echo "Now edit .env file with (at least) credentials for Database & Email..."
sleep 2

rm install_deployer.sh

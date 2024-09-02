# Deployer
A small library that automates deployment process for the app

# Install into Project
composer require brendanpetty/deployer

# Set Up Project

Update the values of each export at the top here, then paste it into the terminal

* SITEPATH **WILL BE DELETED** is the directory within ~ where the (sub)domain is served from (could be *public_html* or *sub*)
* GITHUB Personal Access Token (from https://github.com/settings with *contents read* on the specified repo)

```
export SITEPATH=public_html
export REPOPATH=brendanpetty/
export REPONAME=myappname
export GITHUBPAT=github_pat_xxxxxxxxxxxx

rm -Rf ~/${SITEPATH}
mkdir ~/${SITEPATH}_app
cd ~/${SITEPATH}_app
git clone https://${GITHUBPAT}@‌github.com/${REPOPATH}${REPONAME}.git
ln -s ~/${SITEPATH}_app/${REPONAME}/public ~/${SITEPATH}
echo "SITEPATH=${SITEPATH}" > ~/${SITEPATH}_app/config.sh
echo "REPONAME=${REPONAME}" >> ~/${SITEPATH}_app/config.sh
cd ~/${SITEPATH}_app/${REPONAME}
composer install --no-dev
cp .env.example .env
sed -i '/^APP_ENV=/c\APP_ENV=production' .env
sed -i '/^APP_DEBUG=/c\APP_DEBUG=false' .env
php artisan key:generate
chmod u+x vendor/brendanpetty/deployer/run.sh
ln -s ~/${SITEPATH}_app/${REPONAME}/vendor/brendanpetty/deployer/run.sh ~/deploy_${SITEPATH}.sh
echo "In future, call:  ~/deploy_${SITEPATH}.sh"
```

* Then edit .env file with (at least) credentials for Database & Email.

# Deploy Project

From terminal, run (replace * with your relevant path)
```
    ~/deploy_*.sh
```

Generally option 2 will do all the necessary updates work, then option 1 to exit the script.
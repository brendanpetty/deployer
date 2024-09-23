# Deployer
A small library that automates deployment process for the app

# Install into Project
composer require brendanpetty/deployer

# Set Up Project

```
cd ~
wget https://raw.githubusercontent.com/brendanpetty/deployer/main/install_deployer.sh
chmod u+x install_deployer.sh
./install_deployer.sh
rm install_deployer.sh
```

Then edit .env file with (at least) credentials for Database & Email.

# Deploy Project

From terminal, run (replace * with your relevant path)
```
    ~/deploy_*.sh
```

Generally option 2 will do all the necessary updates work, then option 1 to exit the script.
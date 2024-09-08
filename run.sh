#!/bin/bash

echo "***************************"
echo "*   BEGIN DEPLOY SCRIPT   *"
echo "***************************"
echo ""

# Determine the actual script location, resolving symlinks
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

# Set SITEPATH based on the script's directory
SITEPATHAPP=$(echo "$SCRIPT_DIR" | awk -F'/' '{print $4}')

# Set the config file path
CONFIG_FILE=~/${SITEPATHAPP}/config.sh

# Source the config file if it exists
if [ -f "$CONFIG_FILE" ]; then
    cat $CONFIG_FILE
    source "$CONFIG_FILE"
else
    # Prompt for configuration values if the file doesn't exist
    read -p "Enter SITEPATH (doc root location within ~ like public_html or sub): " SITEPATH
    read -p "Enter REPONAME (not including vendor name): " REPONAME

    # Save the configuration
    echo "SITEPATH=${SITEPATH}" > $CONFIG_FILE
    echo "REPONAME=${REPONAME}" >> $CONFIG_FILE
fi

cd ~/${SITEPATH}_app/${REPONAME}

# Define the function to run the appropriate npm command
run_npm_script() {
    local PACKAGE_JSON="package.json"
    # Check if the package.json file exists
    if [[ ! -f "$PACKAGE_JSON" ]]; then
        return
    fi
    # Check for 'build'/'prod'/'production' script in package.json
    if grep -q '"build":' "$PACKAGE_JSON"; then
        npm run build
    elif grep -q '"prod":' "$PACKAGE_JSON"; then
        npm run prod
    elif grep -q '"production":' "$PACKAGE_JSON"; then
        npm run production
    else
        echo "No valid 'build' or 'prod' or 'production' script found in package.json."
    fi
}

options=("Exit" "FULL UPDATE" "Git Status" "Git Fetch" "Git Pull" "Git Diff" "Git Clean (force)" "Git Reset" "Composer Install" "NPM Install" "NPM Build" "Artisan Migrate" "Artisan Cache" "Artisan Seed")

while true
do
    echo ""
    echo ""
    echo "Select an action (1-${#options[@]}): "
    select opt in "${options[@]}"
    do
        case $opt in
            "Exit")
                echo "See ya!"
                exit 0
                ;;
            "FULL UPDATE")
                echo "git pull"
                git pull
                echo "composer install --no-dev"
                composer install --no-dev
                echo "npm install"
                npm install
                echo "run npm build"
                run_npm_script
                echo "artisan migrate"
                php artisan migrate
                echo "artisan config cache"
                php artisan config:cache
                echo "artisan route cache"
                php artisan route:cache
                echo "artisan view cache"
                php artisan view:cache
                echo "finished"
                break
                ;;
            "Git Status")
                git status
                break
                ;;
            "Git Fetch")
                git fetch
                break
                ;;
            "Git Pull")
                git pull
                break
                ;;
            "Git Clean (force)")
                git clean -df
                break
                ;;
            "Git Reset")
                git reset --hard
                break
                ;;
            "Git Diff")
                git diff -R
                git diff --cached --stat
                git diff origin/main
                break
                ;;
            "Composer Install")
                composer install --no-dev
                break
                ;;
            "NPM Install")
                npm install
                break
                ;;
            "NPM Build")
                run_npm_script
                break
                ;;
            "Artisan Migrate")
                php artisan migrate
                break
                ;;
            "Artisan Cache")
                php artisan config:cache
                php artisan route:cache
                php artisan view:cache
                break
                ;;
            "Artisan Seed")
                php artisan db:seed
                break
                ;;
            *)
                echo "Invalid option $opt. Please try again"
                ;;
        esac
    done
done

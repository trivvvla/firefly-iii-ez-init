#!/bin/zsh

# ----------------------------------------
# Firefly III Configuration Script
# ----------------------------------------

# Color and style variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print in bold
print_bold() {
    local text=$1
    echo -e "${BOLD}${text}${NC}"
}

# Function to print success message
print_success() {
    local message=$1
    echo -e "${GREEN}${message}${NC}"
}

# Function to print the banner
print_banner() {
    clear
    print_bold "Firefly III Configuration Script Started"
    echo
}

# Function to print the menu
print_menu() {
    print_bold "Please select an option:"
    echo "${BLUE}1)${NC} Update variable values"
    echo "${BLUE}2)${NC} Init files and update them"
    echo "${BLUE}3)${NC} Run the compose file"
    echo "${BLUE}4)${NC} Manual steps required after setup"
    echo "${BLUE}q)${NC} Exit"
    echo -n "Enter your choice [${BLUE}1-4, q${NC}]: "
}

# Default variable values
db_password="test_pwd"
user_mail="naabb+firefly@pm.me"
random_32_chars="RNQdCmtw5TsrA9yBKMWDLSakPg3FXnYc"

# Function to update variable values
update_variable_values() {
    echo -n "${YELLOW}Enter DB password [default: ${NC}$db_password${YELLOW}]: ${NC}"
    read new_db_password
    if [[ -n $new_db_password ]]; then
        db_password=$new_db_password
    fi

    echo -n "${YELLOW}Enter user email [default: ${NC}$user_mail${YELLOW}]: ${NC}"
    read new_user_mail
    if [[ -n $new_user_mail ]]; then
        user_mail=$new_user_mail
    fi

    echo -n "${YELLOW}Enter random 32 characters string [default: ${NC}$random_32_chars${YELLOW}]: ${NC}"
    read new_random_32_chars
    if [[ -n $new_random_32_chars ]]; then
        random_32_chars=$new_random_32_chars
    fi
}

init_and_update_files() {
    typeset -A files
    files=(
        "https://raw.githubusercontent.com/firefly-iii/docker/main/docker-compose-importer.yml" "docker-compose.yml"
        "https://raw.githubusercontent.com/firefly-iii/firefly-iii/main/.env.example" ".env"
        "https://raw.githubusercontent.com/firefly-iii/data-importer/main/.env.example" ".importer.env"
        "https://raw.githubusercontent.com/firefly-iii/docker/main/database.env" ".db.env"
    )

    # Create config directory if it doesn't exist
    mkdir -p "config" || { echo "Failed to create config directory"; exit 1; }

    # Function to download files
    download_files() {
        local url=$1
        local filename=$2
        command -v curl > /dev/null || { echo "curl not found, please install it"; exit 1; }
        curl --silent -L "$url" -o "$filename" && echo "Downloaded $filename" || { echo "Failed to download $url"; exit 1; }
        mv "$filename" ./config/ || { echo "Failed to move $filename to config directory"; exit 1; }
    }

    # Download files
    for url filename in ${(kv)files}; do
        download_files "$url" "$filename"
    done

    # Function to perform sed operations
    perform_sed() {
        local file=$1
        local search=$2
        local replace=$3
        sed -i "s|$search|$replace|g" "$file" || { echo "Failed to edit $file"; exit 1; }
    }

    # Update configuration files
    perform_sed "./config/.env" "DB_PASSWORD=secret_firefly_password" "DB_PASSWORD=$db_password"
    perform_sed "./config/.env" "SITE_OWNER=mail@example.com" "SITE_OWNER=$user_mail"
    perform_sed "./config/.env" "APP_KEY=SomeRandomStringOf32CharsExactly" "APP_KEY=$random_32_chars"
    perform_sed "./config/.db.env" "MYSQL_PASSWORD=secret_firefly_password" "MYSQL_PASSWORD=$db_password"
    perform_sed "./config/.importer.env" "FIREFLY_III_URL=" "FIREFLY_III_URL=http://app:8080"
    perform_sed "./config/.importer.env" "VANITY_URL=" "VANITY_URL=http://localhost"
    echo "File configuration complete."
}

run_compose_file() {
    docker-compose -f ./config/docker-compose.yml up -d
    echo "Docker compose has been started."
    echo "Please follow the logs using the command: docker-compose -f ./config/docker-compose.yml logs -f"
}

# Function to guide user through manual steps
manual_steps() {
    echo "Manual steps required after setup:"
    echo "1. Set up Firefly III using the provided tutorials and how-to guides."
    echo "2. Create an access token for the Data Importer."
    echo "3. Browse to the Data Importer at http://localhost:81/ and enter the Client ID."
    echo "4. Authenticate and give permission to the Data Importer."
    echo "5. You are now ready to import data using the Data Importer."
    echo "Please refer to the official documentation for detailed instructions:"
    echo "https://docs.firefly-iii.org/how-to/data-importer/installation/docker/"
}

# Main program
while true; do
    print_banner
    print_menu
    read choice

    case $choice in
        1)
            update_variable_values
            print_success "Variable values updated successfully."
            ;;
        2)
            init_and_update_files
            print_success "Files initialized and updated successfully."
            ;;
        3)
            run_compose_file
            print_success "Docker compose started successfully."
            ;;
        4)
            manual_steps
            ;;
        q)
            print_bold "Byebye"
            exit 0
            ;;
        *)
            echo "${RED}Invalid option selected.${NC}"
            ;;
    esac
    # Wait for user to acknowledge before re-displaying the menu
    echo -n "Press any key to continue..."
    read -k1 -s
done
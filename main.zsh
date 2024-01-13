#!/bin/zsh

# ----------------------------------------
# Firefly III Configuration Script
# ----------------------------------------

# Color and style variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print in bold
print_bold() {
    echo -e "${BOLD}$1${NC}"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to print the banner
print_banner() {
    printf "\n%.0s" {1..3}
    print_bold "Firefly III Configuration Script Started"
    printf "\n%.0s" {1..1}
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
declare -A config_values=(
    [db_password]="test_pwd"
    [user_mail]="mail@mail.com"
    [random_32_chars]="RNQdCmtw5TsrA9yBKMWDLSakPg3FXnYc"
)

# Function to update variable values
# Function to update variable values with validation
update_variable_values() {
    local prompts=("DB password" "user email" "random 32 characters string")
    local keys=("db_password" "user_mail" "random_32_chars")
    local new_value

    for i in {1..3}; do
        while true; do
            echo -n "${YELLOW}Enter ${prompts[i]} [default: ${NC}${config_values[${keys[i]}]}${YELLOW}]: ${NC}"
            read new_value
            case $i in
                2) # Validate user email
                    if [[ -n $new_value ]] && ! [[ $new_value =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
                        echo "${RED}Invalid email format. Please try again.${NC}"
                        continue
                    fi
                    ;;
                3) # Validate random 32 characters string
                    if [[ -n $new_value ]] && ! [[ $new_value =~ ^.{32}$ ]]; then
                        echo "${RED}The string must be exactly 32 characters long. Please try again.${NC}"
                        continue
                    fi
                    ;;
            esac
            # If input is empty, use default value
            if [[ -z $new_value ]]; then
                echo "No change made, using default value: ${config_values[${keys[i-1]}]}"
                break
            else
                config_values[${keys[i-1]}]=$new_value
                echo "Value set to: $new_value"
                break
            fi
        done
    done
    print_success "Variable values updated successfully."
}

# Function to check for dependencies
check_dependencies() {
    local missing=()
    for cmd in docker-compose curl sed; do
        if ! command -v $cmd &> /dev/null; then
            missing+=($cmd)
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        print_error "Missing dependencies: ${missing[*]}. Please install them and try again."
        exit 1
    fi
}

# Function to perform sed operations
perform_sed() {
    local file=$1
    local search=$2
    local replace=$3
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s|$search|$replace|g" "$file" || { print_error "Failed to edit $file"; exit 1; }
    else
        sed -i "s|$search|$replace|g" "$file" || { print_error "Failed to edit $file"; exit 1; }
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

# Function to clean up on exit
cleanup() {
    print_bold "Cleaning up before exit..."
    # Add any necessary cleanup commands here
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Main program
check_dependencies
while true; do
    print_banner
    print_menu
    read choice

    case $choice in
        1)
            update_variable_values
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
            print_error "Invalid option selected."
            ;;
    esac
    # Wait for user to acknowledge before re-displaying the menu
    echo -n "Press any key to continue..."
    read -k1 -s
    printf "\n%.0s" {1..2} # Add spacing instead of clearing the screen
done
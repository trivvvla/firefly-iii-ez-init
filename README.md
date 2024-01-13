# Firefly III Easy Initialization Script

This repository contains a Zsh script designed to simplify the configuration and setup process for [Firefly III](https://www.firefly-iii.org/), a free and open-source personal finance manager.

Please note that this script is not an official part of the Firefly III project and is provided "as is" by the community.

## Overview

The `main.zsh` script provides a user-friendly interface to perform various setup tasks such as updating configuration values, initializing necessary files, running Docker compose, and guiding through manual steps required after setup.

## Features

- Interactive menu-driven interface
- Validation of user input for email and random strings
- Automated file downloading and configuration
- Dependency checks to ensure necessary tools are installed
- Cleanup traps to handle script exits
- User feedback for actions taken or skipped

## Prerequisites

Before running the script, ensure you have the following installed:

- Zsh
- Docker and Docker Compose
- Curl
- Sed (with support for in-place editing)

## Usage

To use the script, clone the repository and run the `main.zsh` file in your terminal:
```
git clone https://github.com/your-username/firefly-iii-ez-init.git
cd firefly-iii-ez-init
chmod +x ./main.zsh
./main.zsh
```

Follow the on-screen prompts to select from the available options:

1. **Update variable values**: Set or update the configuration values for the database password, user email, and a random 32-character string.
2. **Init files and update them**: Download necessary files and update them with the configuration values set in the previous step.
3. **Run the compose file**: Start the Docker compose process to get Firefly III running.
4. **Manual steps required after setup**: Display the manual steps needed to be performed after the initial setup.
5. **Exit**: Quit the script.

## Configuration

The script uses default values for various configuration options, which can be updated when prompted by the script. For advanced users, these values can also be set via environment variables or a separate configuration file (not provided in this repository).

## Security

Sensitive information such as database passwords is handled by the script. Users are encouraged to provide secure values and avoid using the defaults for any production environment.

## Contributions

Contributions to this script are welcome.

## License
This script is released under the  GPL-3.0 license. See the `LICENSE` file for more information.


## Acknowledgments
This script is created for the Firefly III community. Firefly III is a project by [James Cole](https://github.com/JC5).

---
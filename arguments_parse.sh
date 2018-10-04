#!/bin/bash
source add_color.sh

release="stable"
file="default.tar.gz"
url="http://your.repo.com/resources"

function monitor-api() {
    echo "Checking API . . ."
    printf "${green}OK${fontreset}\n"
}

function monitor-proxy() {
    echo "Checking PROXY . . ."
    printf "${red}ERROR${fontreset}\n"
}

function monitor-all() {
    monitor-api
    monitor-proxy
}

function update-api() {
    echo "Updating API . . ."
    printf "${italic}Using ${url}/${release}/${file}${fontreset}\n"
    printf "${green}OK${fontreset}\n"
}

function update-proxy() {
    echo -e "Updating PROXY . . ."
    printf "${italic}Using ${url}/${release}/${file}${fontreset}\n"
    printf "${yellow}WARNING${fontreset}\n"
}

function update-all() {
    update-api
    update-proxy
}

######################################################

function help() {
    printf "${bold}Useage: $0 option${fontreset}"
	printf "${bold}\n  Options are:\n${fontreset}"
    printf "${cyan}${bold}%-50s${faded}${italic}%-30s${fontreset}\n" "  --monitor <api|proxy|all>" "# start or check"
    printf "${cyan}${bold}%-50s${faded}${italic}%-30s${fontreset}\n" "  --update <api|proxy|all>" "# update"
    printf "${cyan}${bold}%-50s${faded}${italic}%-30s${fontreset}\n" "    -f|--file (use a custom file)"
    printf "${cyan}${bold}%-50s${faded}${italic}%-30s${fontreset}\n" "    -u|--url (use a custom URL address)"
    printf "${cyan}${bold}%-50s${faded}${italic}%-30s${fontreset}\n" "    --release (ftp folder name \${url_release})" "# http://your.repo.com/resources/\${url_release}"
    printf "${cyan}${bold}%-50s${faded}${italic}%-30s${fontreset}\n" "  -h|--help" "# display this help message"
    printf "\n${bold}NOTE${fontreset}:"
    printf "\n* Each update creates a backup of the existing install in the 'backups' folder."
    printf "\n* You can roll back using the update command and one of the backup files."
    printf "\n  If the file command points to the 'backups' folder, creating new backup will be skipped."
    printf "${italic}\n  Example: $0 --monitor api${fontreset}"
    printf "${italic}\nOther examples:${fontreset}"
    printf "${italic}\n  $0 --update ALL --release testing${fontreset}"
    printf "${italic}\n  $0 --update api --url http://your-local-server/archive.tar.gz${fontreset}\n"
}

######################################################

# MAIN
date
# if there are any valid arguments, parse and assign the values
if (( $# >= 1 )); then
    # Use -gt 2 to consume three arguments per pass in the loop (e.g. each
    # argument has a corresponding value to go with it).
    # Use -gt 1 to consume two arguments per pass in the loop (e.g. each
    # argument has a corresponding value to go with it).
    # some arguments don't have a corresponding value to go with it such
    # as in the --default example).
    # NOTE: shift only that has a second argument
    while [[ $# -gt 0 ]]; do
        key="$1"
        echo Parsed key: $key
        case $key in
            --monitor)
                case $2 in
                    api)
                        run="monitor-api"
                        ;;
                    proxy)
                        run="monitor-proxy"
                        ;;
                    all|ALL)
                        run="monitor-all"
                        ;;
                    *)
                        printf ${red}"Incorrect syntax!\n"${fontreset}
                        help
                        exit 1
                esac
                shift
                ;;
            --update)
                case $2 in
                    api)
                        run="update-api"
                        ;;
                    proxy)
                        run="update-proxy"
                        ;;
                    all|ALL)
                        run="update-all"
                        ;;
                    *)
                        printf ${red}"Incorrect syntax!\n"${fontreset}
                        help
                        exit 1
                esac
                shift
                ;;
            --release)
                release="$2"
                shift
                ;;
            -f|--file)
                file="$2"
                shift
                ;;
            -u|--url)
                url="$2"
                shift
                ;;
            -h|--help)
                help
                ;;
            *)
                printf ${red}"Incorrect syntax!\n"${fontreset}
                help
                exit 1
        esac
        shift
    done
    echo -e "Running: ${run}\n"
    $run
else
    help
    exit 0
fi
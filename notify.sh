#!/bin/bash
version="SCript by AndreiMagic, last revision 19.12.2017"
DATE=$(date)

# Notification services credentials
# Use `export variable="value"` command in ~/.bash_profile to export them as environmental
# else uncomment and use the below assignments
#
# pushover_token="a7...tv"
# pushover_user="uS...x12"
# mailgun_key="key-b0...x12"
# mailgun_domain="sandboxc894....mailgun.org"

# Pushover Notifications
function pushover() {
    if [[ ! $pushover_token ]] || [[ ! $pushover_user ]]; then
        echo -e "Notification services credentials missing!\n\n<pushover_token, pushover_user>"
        echo -e "Must be declared using 'export variable=\"value\"'\n(or uncomment them in the script)"
        exit 1
    fi

    if [[ ! $push_subject ]] || [[ ! $push_text ]] || [[ ! $push_priority ]]; then
        echo -e "All notification service parameters are mandatory!"
        exit 1
    fi

    curl -s -F "token=${pushover_token}" \
    -F "user=${pushover_user}" \
    -F "title=${push_subject}" \
    -F "message=${push_text}" \
    -F "priority=${push_priority}" \
    https://api.pushover.net/1/messages.json
}

# Pushover Glances
function glances() {
    if [[ ! $pushover_token ]] || [[ ! $pushover_user ]]; then
        echo -e "Notification services credentials missing!\n\n<pushover_token, pushover_user>"
        echo -e "Must be declared using 'export variable=\"value\"'\n(or uncomment them in the script)"
        exit 1
    fi

    if [[ ! $glance_title ]] || [[ ! $glance_text ]] || [[ ! $glance_subtext ]] || [[ ! $glance_count ]] || [[ ! $glance_percent ]]; then
        echo -e "All notification service parameters are mandatory!"
        exit 1
    fi

    if [[ ${glance_title} ]]; then glance_title="title=${glance_title}"; fi
    if [[ ${glance_text} ]]; then glance_text="text=${glance_text}"; fi
    if [[ ${glance_subtext} ]]; then glance_subtext="subtext=${glance_subtext}"; fi
    if [[ ${glance_count} ]]; then glance_count="count=${glance_count}"; fi
    if [[ ${glance_percent} ]]; then glance_percent="percent=${glance_percent}"; fi

    curl --data "token=${pushover_token}&user=${pushover_user}&${glance_title}&${glance_text}&${glance_subtext}&${glance_count}&${glance_percent}" https://api.pushover.net/1/glances.json
}

# Mailgun Notifications (multiple recipients comma separated)
function mailgun() {
    if [[ ! $mailgun_key ]] || [[ ! $mailgun_domain ]]; then
        echo -e "Notification services credentials missing!\n<mailgun_key, mailgun_domain>"
        echo -e "Must be declared using 'export variable=\"value\"'\n(or uncomment them in the script)"
        exit 1
    fi

    if [[ ! $mail_recipients ]] || [[ ! $mail_subject ]] || [[ ! $mail_text ]]; then
        echo -e "All notification service parameters are mandatory!"
        exit 1
    fi

    curl -s --user "api:${mailgun_key}" \
    https://api.mailgun.net/v3/${mailgun_domain}/messages \
    -F from="Mailgun Script <mailgun@${mailgun_domain}>" \
    -F to="${mail_recipients}" \
    -F subject="${mail_subject}" \
    -F text="${mail_text}"
}

# Mailgun Notifications (multiple recipients comma separated)
function slack() {
    if [[ ! $slack_webhook ]] || [[ ! $slack_username ]] || [[ ! $slack_channel ]] || [[ ! $slack_text ]]; then
        echo -e "All notification service parameters are mandatory!\n<slack_webhook, slack_channel, slack_username, slack_text>"
        exit 1
    fi

    json="{\"channel\": \"$slack_channel\", \"username\":\"$slack_username\", \"icon_emoji\":\"ghost\", \"attachments\":[{\"color\":\"danger\" , \"text\": \"$slack_text\"}]}"
    curl --data "payload=$json" "$slack_webhook"
}

function help() {
    echo -e "Useage: $0 option"
    echo -e "\n  Options are:"
    printf "%-60s%-30s\n" "  --mailgun" "# email"
    printf "%-60s\n" "    -s|--subject -m|--message -r|--recipients"
    printf "%-60s%-30s\n" "  --pushover" "# push notification"
    printf "%-60s\n" "    -s|--subject -m|--message -p|--priority"
    printf "%-60s%-30s\n" "  --glances" "# push stats to watchOS"
    printf "%-60s\n" "    -t|--title -m|--message -s|--subtext -c|--count -%|--percent"
    printf "%-60s%-30s\n" "  --slack" "# push messages to Slack"
    printf "%-60s\n" "    -w|--webhook -c|--channel -u|--username -m|--message"
    printf "%-60s%-30s\n" "  -h|--help" "# display this help message"
    echo -e "\nNOTE: Notification services credentials\n<pushover_token, pushover_user, mailgun_key, mailgun_domain>"
    echo -e "must be declared using 'export variable=\"value\"' (or add them in the script header)"
}



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
            -s|--subject|--subtext)
                mail_subject="$2"
                push_subject="$2"
                glance_subtext="$2"
                shift # past argument
                ;;
            -m|--message)
                mail_text="$2"
                push_text="$2"
                glance_text="$2"
                slack_text="$2"
                shift # past argument
                ;;
            -r|--recipients)
                mail_recipients="$2"
                shift # past argument
                ;;
            -p|--priority)
                push_priority="$2"
                shift # past argument
                ;;
            -t|--title)
                glance_title="$2"
                shift # past argument
                ;;
            -c|--count|--channel)
                glance_count="$2"
                slack_channel="$2"
                shift # past argument
                ;;
            -%|--percent)
                glance_percent="$2"
                shift # past argument
                ;;
            -u|--username)
                slack_username="$2"
                shift # past argument
                ;;
            -w|--webhook)
                slack_webhook="$2"
                shift # past argument
                ;;
            --mailgun)
                run="mailgun"
                ;;
            --pushover)
                run="pushover"
                ;;
            --glances)
                run="glances"
                ;;
            --slack)
                run="slack"
                ;;
            -h|--help)
                help
                ;;
            *)
                echo -e "Incorrect syntax!"
                help
                exit 1
        esac
        shift # past argument or value
    done
    echo Running: $run
    $run
elif (( $# == 0 )); then
    help
else
    echo -e "Incorrect syntax!"
    help
fi
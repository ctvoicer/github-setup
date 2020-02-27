#!/bin/bash

function getHelp {
    echo "Setup repository labels

    --help, -h    Show this help
    --token, -t   GitLab Private-Token (defaults to \$GITLAB_TOKEN)
    --url, -u     GitLab base URL (defaults to \$GITLAB_URL or https://gitlab.com)
    --verbose, -v Details process

To generate a Private-Token see: https://docs.gitlab.com/ee/api/README.html#personal-access-tokens

Usage:
    $0 --token gitlab-private-token [-u http://gitlab.example.com] owner/repo\n"
}

function gitlab_labels_api {
    QUERY=
    [[ ! -z "$3" ]] && QUERY="?$(urlencode $3)"
    [[ -z "$3" ]] && [[ "$1" = "DELETE" ]] && QUERY="?$(urlencode $2)"
    curl -w "\nStatus: %{http_code}\n" -H "Private-Token: $GITLAB_TOKEN" -sL "$GITLAB_URL/api/v4/projects/$GITLAB_REPO/labels$QUERY" -X "$1" -d "$2"
}

urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

VERBOSE=0
[[ -z "$GITLAB_URL" ]] && GITLAB_URL=https://gitlab.com/
args=("$@")
for i in "$@"
do
    if [ ! -z "$counter" ] && [[ "$counter" != "$readed_counter" ]]; then
        counter=$[$counter + 1]
        continue
    fi

    if [[ "$i" = "--help" ]] || [[ "$i" = "-h" ]]; then
       printf "$(getHelp)"
       exit 0
    elif [[ $i == '--token' ]] || [[ $i == '-t' ]]; then
        GITLAB_TOKEN=${args[$counter + 1]}
        readed_counter=$[$readed_counter + 1]
    elif [[ $i == '--url' ]] || [[ $i == '-u' ]]; then
        GITLAB_URL=${args[$counter + 1]}
        readed_counter=$[$readed_counter + 1]
    elif [[ $i == '--verbose' ]] || [[ $i == '-v' ]]; then
        VERBOSE=1
    else
        GITLAB_REPO=$i
    fi

    readed_counter=$[$readed_counter + 1]
    counter=$[$counter + 1]
done

if [ -z "$GITLAB_REPO" ]; then
    read -p "Type your GitLab repository name (owner/repo_name): " GITLAB_REPO
fi

if [ -z "$GITLAB_TOKEN" ]; then
    read -p "Type your GitLab Private-token: " GITLAB_TOKEN
fi

if [ -z "$GITLAB_TOKEN" ] || [ -z "$GITLAB_REPO" ]; then
    >&2 echo "There are missing parameters !"
    >&2 printf "$(getHelp)"
    exit 1
fi

GITLAB_REPO=$(urlencode $GITLAB_REPO)

REMOVE_DEFAULT_LABELS='bug
confirmed
critical
discussion
documentation
enhancement
suggestion
support'

LABELS='point: 1,dddddd,,
point: 2,dddddd,,
point: 3,dddddd,,
point: 5,dddddd,,
point: 8,dddddd,,
point: 13,dddddd,,
point: 21,dddddd,,
priority: high,bfd4f2,,
priority: highest,bfd4f2,,
priority: low,bfd4f2,,
priority: lowest,bfd4f2,,
priority: medium,bfd4f2,,
type:bug,d6bb26,bug,
type:chore,d6bb26,chore or maintenance work,
type:feature,d6bb26,new feature,
type:infra,d6bb26,infrastructure related,
type:perf,d6bb26,performance related,
type:refactor,d6bb26,refactor,
type:test,d6bb26,test related,'

if [[ "$VERBOSE" == 1 ]]; then
   echo "Removing default labels"
fi

while read -r label; do
    response=$(gitlab_labels_api DELETE "name=$label")
    if [[ "$response" != *"Status: 204"* ]]; then
        [[ "$response" != *"Status: 404"* ]] && >&2 echo "Error removing \"$label\": $response"
    elif  [[ "$VERBOSE" == 1 ]]; then
        echo "Label \"$label\" removed"
    fi
done <<< "$REMOVE_DEFAULT_LABELS"

if [[ "$VERBOSE" == 1 ]]; then
    echo "Creating new labels"
fi

while read -r label; do
    label_name=$(echo $label | cut -d , -f 1)
    label_color=$(echo $label | cut -d , -f 2)
    label_description=$(echo $label | cut -d , -f 3)
    label_priority=$(echo $label | cut -d , -f 4)
    response=$(gitlab_labels_api POST "name=$label_name&color=#$label_color&description=$label_description&priority=$label_priority")

    if [[ "$response" != *"Status: 201"* ]]; then
        [[ "$response" != *"Status: 409"* ]] && >&2 echo "Error on creating: $label_name, response: $response"
    elif [[ "$VERBOSE" == 1 ]]; then
         echo "Label \"$label_name\" created"
    fi
done <<< "$LABELS"


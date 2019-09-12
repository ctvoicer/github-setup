#!/bin/bash

function getHelp {
    echo "Setup repository labels

    --help, -h      Show this help
    --user, -u      GitHub username
    --password, -p  GitHub password
    --verbose, -v   Details process

Usage:
    $0 -u githubUser -p githubPassword owner/repo\n"
}

function github_api {
    AUTHORIZATION="$GITHUB_USERNAME:$GITHUB_PASSWORD"
    COMMAND='-u'
    [ ! -z ${GITHUB_TOKEN+x} ] && {
        AUTHORIZATION="Authorization: token $GITHUB_TOKEN"
        COMMAND='-H'
    }

    curl $COMMAND "$AUTHORIZATION" -sL "https://api.github.com/repos/$GITHUB_REPO/$1" -X "$2" -d "$3"
}

VERBOSE=0
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
    elif [[ $i == '--user' ]] || [[ $i == '-u' ]]; then
        GITHUB_USERNAME=${args[$counter + 1]}
        readed_counter=$[$readed_counter + 1]
   elif [[ $i == '--password' ]] || [[ $i == '-p' ]]; then
        GITHUB_PASSWORD=${args[$counter + 1]}
        readed_counter=$[$readed_counter + 1]
    elif [[ $i == '--verbose' ]] || [[ $i == '-v' ]]; then
        VERBOSE=1
    else
        GITHUB_REPO=$i
    fi

    readed_counter=$[$readed_counter + 1]
    counter=$[$counter + 1]
done

if [ -z "$GITHUB_REPO" ]; then
    read -p "Type your Github repository name (owner/repo_name): " GITHUB_REPO
fi

if [ -z "$GITHUB_USERNAME" ] && [ -z $GITHUB_TOKEN ]; then
    read -p "Type your Github username: " GITHUB_USERNAME
fi

if [ -z "$GITHUB_PASSWORD" ] && [ -z $GITHUB_TOKEN ]; then
    read -p "Type your Github password (won't be shown): " -s GITHUB_PASSWORD
    echo;
fi

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_REPO" ] && [ -z $GITHUB_TOKEN ]; then
    >&2 echo "There are missing parameters !"
    >&2 printf "$(getHelp)"
    exit 1
fi

REMOVE_DEFAULT_LABELS='bug
documentation
duplicate
enhancement
good%20first%20issue
help%20wanted
invalid
question
wontfix'

LABELS='Level: Easy,48d1cc,Tarefa simples
Level: Medium,20b2aa,Tarefa moderada
Level: Hard,008b8b,Tarefa complexa
Priority: Highest,b60205,Emergencial
Priority: High,fef2c0,Alta urgência
Priority: Medium,d4c5f9,Urgente
Priority: Low,d4c5f9,Baixa urgência
Priority: Lowest,ededed,Nenhuma urgência
Status: Blocked,d93f0b,Bloqueado por outra pendência
Status: Duplicated,c5def5,Duplicado
Status: Impediment,b60205,Fora de escopo
Status: Needs Info,ff8c00,Carece mais informações
Type: BUG,fc2929,Mal funcionamento
Type: Improvement,84b6eb,Melhoria de alguma funcionalidade
Type: New feature,0052cc,Nova funcionalidade
Type: Sub-task,ededed,Sub-tarefa relacionada a alguma outra'

if [[ "$VERBOSE" == 1 ]]; then
   echo "Removing default labels"
fi

while read -r label; do
    response=$(github_api "labels/$label" DELETE)
    if [[ "$response" == *"message"* ]]; then
        if [[ ! "$response" == *"Not Found"* ]]; then
            echo "Error removing \"$label\": $response"
        fi
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
    response=$(github_api labels POST "{\"name\": \"$label_name\", \"color\":\"$label_color\", \"description\":\"$label_description\"}")

    if [[ "$response" == *"errors"* ]]; then
        if [[ ! "$response" == *"already_exists"* ]]; then
            >&2 echo "Error on creating: $label_name, response: $response"
        fi
    elif [[ "$VERBOSE" == 1 ]]; then
         echo "Label \"$label_name\" created"
    fi
done <<< "$LABELS"


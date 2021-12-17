#!/bin/bash

TMP_STORE_LOCATION=/tmp/api_response.json

# getProject queries the github api for the specific project
function getProject() {
    local USER=$1
    local PROJECT_NUMBER=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    query($user: String!, $number: Int!) {
        user(login: $user){
            projectNext(number: $number) {
                id
                fields(first:20) {
                    nodes {
                        id
                        name
                        settings
                    }
                }
            }
        }
    }' -f user=$USER -F number=$PROJECT_NUMBER > $TMP_STORE_LOCATION
}

# extractProjectID returns the project id
function extractProjectID() {
    echo $(jq '.data.user.projectNext.id' $TMP_STORE_LOCATION | sed -e "s+\"++g")
}

# extractStatusFieldID returns the status field id
function extractStatusFieldID() {
    echo $(jq '.data.user.projectNext.fields.nodes[] | select(.name== "Status") | .id' $TMP_STORE_LOCATION | sed -e "s+\"++g")
}

# extractStatusFieldNodeSettingsByValue returns a list of available settings
function extractStatusFieldNodeSettingsByValue() {
    local STATUS_NAME=$1
    jq ".data.user.projectNext.fields.nodes[] | select(.name== \"Status\") | .settings | fromjson.options[] | select(.name==\"$STATUS_NAME\") |.id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# getItemID queries the github api for the specific item_id
# Required arguments:
#   1: project id
#   2: resource node id
function getItemID() {
    local project_id=$1
    local resource_id=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation($project:ID!, $resource_id:ID!) {
        addProjectNextItem(input: {projectId: $project, contentId: $resource_id}) {
            projectNextItem {
                id
            }
        }
    }' -f project=$project_id -f resource_id=$resource_id --jq '.data.addProjectNextItem.projectNextItem.id' | sed -e "s+\"++g"
}

# removeFromProject removes the given item
# Required arguments:
#   1: project id
#   2: project item id
function removeFromProject() {
    local project_id=$1
    local item_id=$2
    echo $(gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation (
        $project: ID!
        $item: ID!
    ) {
        deleteProjectNextItem(
            input: {
                projectId: $project
                itemId: $item
            }
        )
        {
            deletedItemId
        }
    }' -f project=$project_id -f item=$item_id | sed -e "s+\"++g")
}

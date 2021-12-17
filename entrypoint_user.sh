#!/bin/bash

organization_name=$1 # organization name
organization_project_id=$2 # organization id
resource_id=$3 # pr or issue node id

# load lib bash functions
source gh_api_lib_user.sh

# request gh api and returns the project settings
getProject $organization_name $organization_project_id

PROJECT_ID=$(extractProjectID)

ITEM_ID=$(getItemID $PROJECT_ID $resource_id)


echo "PROJECT_ID: $PROJECT_ID"
echo "ITEM_ID: $ITEM_ID"

# update single select field
removeFromProject "$PROJECT_ID" "$ITEM_ID"
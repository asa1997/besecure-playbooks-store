#!/bin/bash

steps_flag=true
modified_file=$1
assement_tools=$2
for file in $(echo "${{ env.MODIFIED_FILES }}" | grep -E "${{ env.ASSESSMENT_TOOLS }}" | grep '\-playbook\.sh$'); do
tool_name=$(echo "$file" | cut -d "-" -f 2)
version=$(echo "$file" | cut -d "-" -f 3)
if echo "${{ env.MODIFIED_FILES }}" | grep -q "besman-$tool_name-$version-steps" && ls -R . | grep -q "besman-$tool_name-$version-steps"
then
    steps_flag=false
    echo -e "\e[31mCould not find steps file for \e[33mbesman-$tool_name-$version-playbook.sh\e[31m"
# elif ls -R . | grep -q "besman-$tool_name-$version-steps"
# then
#   steps_flag=false
fi
if [[ "$steps_flag" == "true" ]]
then
    exit 1
fi
done
          # if [[ "$steps_flag" == "true" ]]
          # then
          #   exit 1
          # fi
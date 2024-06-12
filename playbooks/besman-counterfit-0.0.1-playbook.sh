#!/bin/bash

function __besman_init() {
    __besman_echo_white "initializing"
    export ASSESSMENT_TOOL_NAME="counterfit"
    export ASSESSMENT_TOOL_TYPE="dast"
    export ASSESSMENT_TOOL_VERSION="0.1.0"
    export ASSESSMENT_TOOL_PLAYBOOK="besman-$ASSESSMENT_TOOL_NAME-$ASSESSMENT_TOOL_VERSION-playbook.sh"
    
    local steps_file_name="besman-$ASSESSMENT_TOOL_NAME-$ASSESSMENT_TOOL_VERSION-steps.md"
    export BESMAN_STEPS_FILE_PATH="$BESMAN_PLAYBOOK_DIR/$steps_file_name"

    local var_array=("BESMAN_COUNTERFIT_LOCAL_PATH" "BESMAN_COUNTERFIT_BRANCH" "BESMAN_COUNTERFIT_URL" "BESMAN_ARTIFACT_NAME" "BESMAN_ASSESSMENT_DATASTORE_DIR" "BESMAN_ARTIFACT_VERSION" "BESMAN_ARTIFACT_URL" "BESMAN_ENV_NAME" "BESMAN_LAB_TYPE" "BESMAN_LAB_NAME" "BESMAN_ASSESSMENT_DATASTORE_URL")

    local flag=false
    for var in "${var_array[@]}"; do
        if [[ ! -v $var ]]; then
            __besman_echo_yellow "$var is not set"
            __besman_echo_no_colour ""
            flag=true
        fi
    done

      #TODO
    # Check if counterfit is installed, anaconda is installed etc.
    # If not present set the variable "flag" as "true"

    if [[ $flag == true ]]; then
        return 1
    else
        export DETAILED_REPORT_PATH="$BESMAN_ASSESSMENT_DATASTORE_DIR/models/$BESMAN_ARTIFACT_NAME/dast/$BESMAN_ARTIFACT_NAME-dast-summary-report.json"
        export OSAR_PATH="$BESMAN_ASSESSMENT_DATASTORE_DIR/models/$BESMAN_ARTIFACT_NAME/$BESMAN_ARTIFACT_NAME-osar.json"
        __besman_fetch_steps_file "$steps_file_name" || return 1
        return 0
    fi

  

}

function __besman_execute() {
    local duration
    mkdir -p "$BESMAN_DIR/tmp/steps"
    __besman_echo_yellow "Launching steps file"
    cp "$BESMAN_STEPS_FILE_PATH" "$BESMAN_DIR/tmp/steps"
    SECONDS=0
    jupyter notebook "$BESMAN_DIR/tmp/steps"
    # while read -p "Done with assessment?(y/n):" input 
    # do
    #     if [[ $input == "y" ]] 
    #     then
    #         if [[ -f $DETAILED_REPORT_PATH ]] 
    #         then
    #             break
    #         else
    #             __besman_echo_red "Could not find report @ $DETAILED_REPORT_PATH"
    #             __besman_echo_no_colour ""
    #             __besman_echo_yellow "Waiting" 
    #         fi

        
    #     fi
    # done
    
    duration=$SECONDS

    export EXECUTION_DURATION=$duration
    if [[ $SCAN_RESULT == 1 ]]; then
        export PLAYBOOK_EXECUTION_STATUS=failure
        return 1
    else
        export PLAYBOOK_EXECUTION_STATUS=success
        return 0
    fi
}

function __besman_prepare() {
    echo "preparing data"
    EXECUTION_TIMESTAMP=$(date)
    export EXECUTION_TIMESTAMP

    #TODO
    # Move the report from counterfit folder to $DETAILED_REPORT_PATH

    [[ ! -f $DETAILED_REPORT_PATH ]] && __besman_echo_red "Could not find report @ $DETAILED_REPORT_PATH" && return 1

    __besman_generate_osar
}


function __besman_publish() {
    __besman_echo_yellow "Pushing to datastore"
    cd "$BESMAN_ASSESSMENT_DATASTORE_DIR"

    git add models/$BESMAN_ARTIFACT_NAME/*
    git commit -m "Added DAST and OSAR reports for $BESMAN_ARTIFACT_NAME"
    git push origin main
}

function __besman_cleanup() {
    local var_array=("ASSESSMENT_TOOL_NAME" "ASSESSMENT_TOOL_TYPE" "ASSESSMENT_TOOL_VERSION" "ASSESSMENT_TOOL_PLAYBOOK" "BESMAN_STEPS_FILE_PATH" "DETAILED_REPORT_PATH" "OSAR_PATH" "EXECUTION_TIMESTAMP" "EXECUTION_DURATION")

    for var in "${var_array[@]}"; do
        if [[ -v $var ]]; then
            unset "$var"
        fi
    done

    deactivate
}

function __besman_launch() {
    __besman_echo_yellow "Starting playbook"
    local flag=1

    __besman_init
    flag=$?
    if [[ $flag == 0 ]]; then
        __besman_execute
        flag=$?
    else
        __besman_cleanup
        return
    fi

    if [[ $flag == 0 ]]; then
        __besman_prepare
        __besman_publish
        __besman_cleanup
    else
        __besman_cleanup
        return
    fi
}

function __besman_fetch_steps_file() {
    echo "Fetching steps file"
    local steps_file_name=$1
    local steps_file_url="https://raw.githubusercontent.com/$BESMAN_PLAYBOOK_REPO/$BESMAN_PLAYBOOK_REPO_BRANCH/playbooks/$steps_file_name"
    __besman_check_url_valid "$steps_file_url" || return 1

    if [[ ! -f "$BESMAN_STEPS_FILE_PATH" ]]; then
        touch "$BESMAN_STEPS_FILE_PATH"
        __besman_secure_curl "$steps_file_url" >>"$BESMAN_STEPS_FILE_PATH"
        [[ "$?" != "0" ]] && echo "Failed to fetch from $steps_file_url" && return 1
    fi
    echo "Done fetching"
}

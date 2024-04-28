#!/bin/bash
function __besman_init() {
    __besman_echo_white "initialising"
    export ASSESSMENT_TOOL_NAME="criticality_score"
    export ASSESSMENT_TOOL_TYPE="criticality_score"
    export ASSESSMENT_TOOL_VERSION="2.0.3"
    #export BESLAB_OWNER_TYPE="Organization"
    #export BESLAB_OWNER_NAME="Be-Secure"
    export ASSESSMENT_TOOL_PLAYBOOK="besman-$ASSESSMENT_TOOL_TYPE-0.0.1-playbook.sh"

    local steps_file_name="besman-$ASSESSMENT_TOOL_NAME-0.0.1-steps.sh"
    export BESMAN_STEPS_FILE_PATH="$BESMAN_PLAYBOOK_DIR/$steps_file_name"

    local var_array=("BESMAN_ARTIFACT_TYPE" "BESMAN_ARTIFACT_NAME" "BESMAN_ARTIFACT_VERSION" "BESMAN_ARTIFACT_URL" "BESMAN_ENV_NAME" "BESMAN_ARTIFACT_DIR" "ASSESSMENT_TOOL_NAME" "ASSESSMENT_TOOL_TYPE" "ASSESSMENT_TOOL_VERSION" "ASSESSMENT_TOOL_PLAYBOOK" "BESMAN_ASSESSMENT_DATASTORE_DIR" "BESMAN_TOOL_PATH" "BESMAN_ASSESSMENT_DATASTORE_URL" "BESMAN_LAB_TYPE" "BESMAN_LAB_NAME")

    local flag=false
    for var in "${var_array[@]}"; do
        if [[ ! -v $var ]]; then

            # read -rp "Enter value for $var:" value #remove
            # export "$var"="$value" #remove
            __besman_echo_yellow "$var is not set" #uncomment
            __besman_echo_no_colour ""             #uncomment
            flag=true                              #uncomment
        fi

    done

    local dir_array=("BESMAN_ASSESSMENT_DATASTORE_DIR")
    for dir in "${dir_array[@]}"; do
        # Get the value of the variable with the name stored in $dir
        dir_path="${!dir}"

        if [[ ! -d $dir_path ]]; then
            __besman_echo_red "Could not find $dir_path"
            flag=true
        fi

    done

    # [[ ! -f $BESMAN_TOOL_PATH/$ASSESSMENT_TOOL_NAME ]] && __besman_echo_red "Could not find artifact @ $BESMAN_TOOL_PATH/$ASSESSMENT_TOOL_NAME" && flag=true
    if ! [ -x "$(command -v criticality_score)" ]; then
        __besman_echo_red "required tool - criticality_score is not installed. Please check the installed Bes env"
    fi

    if [[ $flag == true ]]; then
        return 1
    else
        export CRITICALITY_SCORE_PATH="$BESMAN_ASSESSMENT_DATASTORE_DIR/$BESMAN_ARTIFACT_NAME/$BESMAN_ARTIFACT_VERSION/criticality_score"
        export DETAILED_REPORT_PATH="$CRITICALITY_SCORE_PATH/$BESMAN_ARTIFACT_NAME-$BESMAN_ARTIFACT_VERSION-criticality_score-report.json"
        mkdir -p "$CRITICALITY_SCORE_PATH"
        export OSAR_PATH="$BESMAN_ASSESSMENT_DATASTORE_DIR/osar/$BESMAN_ARTIFACT_NAME-$BESMAN_ARTIFACT_VERSION-OSAR.json"
        __besman_fetch_steps_file "$steps_file_name" || return 1
        return 0

    fi
}

function __besman_prepare() {
    __besman_echo_white "preparing data"
    EXECUTION_TIMESTAMP=$(date)
    export EXECUTION_TIMESTAMP

    __besman_generate_osar

}

function __besman_execute() {
    __besman_echo_white "preparing data"
    EXECUTION_TIMESTAMP=$(date)
    export EXECUTION_TIMESTAMP

    __besman_generate_osar

}

function __besman_publish() {
    __besman_echo_yellow "Pushing to datastores"
    # push code to remote datastore
    cd "$BESMAN_ASSESSMENT_DATASTORE_DIR"

    git add "$DETAILED_REPORT_PATH" "$OSAR_PATH"
    git commit -m "Added osar and detailed report"
    git push origin main
}

function __besman_cleanup() {
    local var_array=("ASSESSMENT_TOOL_NAME" "ASSESSMENT_TOOL_TYPE" "ASSESSMENT_TOOL_PLAYBOOK" "ASSESSMENT_TOOL_VERSION" "OSAR_PATH" "CRITICALITY_SCORE_PATH" "DETAILED_REPORT_PATH")

    for var in "${var_array[@]}"; do
        if [[ -v $var ]]; then
            unset "$var"
        fi

    done

}

#!/bin/bash
# function launch
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
    __besman_echo_white "fetching steps file"
    local steps_file_name=$1
    local steps_file_url="https://raw.githubusercontent.com/$BESMAN_NAMESPACE/$BESMAN_PLAYBOOK_REPO/main/playbooks/$steps_file_name"
    __besman_check_url_valid "$steps_file_url" || return 1

    if [[ ! -f "$BESMAN_STEPS_FILE_PATH" ]]; then

        touch "$BESMAN_STEPS_FILE_PATH"

        __besman_secure_curl "$steps_file_url" >>"$BESMAN_STEPS_FILE_PATH"
        [[ "$?" != "0" ]] && __besman_echo_red "Failed to fetch from $steps_file_url" && return 1
    fi
    __besman_echo_white "done fetching"
}

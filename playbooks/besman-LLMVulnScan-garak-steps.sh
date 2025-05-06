#!/bin/bash

__besman_echo_yellow "Activating conda environment"
source /opt/conda/etc/profile.d/conda.sh
conda activate garak

if [[ $? -ne 0 ]]; then
    __besman_echo_red "Failed to activate conda environment"
    return 1
fi

__besman_echo_yellow "Running vulnerability scan using garak"

if [[ "$BESMAN_ARTIFACT_PROVIDER" == "ollama" ]] 
then
    
    garak --model_type ollama --model_name "$BESMAN_ARTIFACT_NAME:$BESMAN_ARTIFACT_VERSION" --probes "$BEMAN_GARAK_CATEGORIES" --report_prefix "$BESMAN_ARTIFACT_NAME:$BESMAN_ARTIFACT_VERSION"
elif [[ "$BESMAN_ARTIFACT_PROVIDER" == "huggingface" ]] 
then
    garak --model_type huggingface --model_name "$BESMAN_ARTIFACT_NAME:$BESMAN_ARTIFACT_VERSION" --probes "$BEMAN_GARAK_CATEGORIES" --report_prefix "$BESMAN_ARTIFACT_NAME:$BESMAN_ARTIFACT_VERSION"
fi


conda deactivate

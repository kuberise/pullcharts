#!/bin/bash

# Path to the values.yaml file
valuesFile="../kuberise/app-of-apps/values.yaml"

# Function to compare version numbers
compareVersions() {
    if [[ $1 == $2 ]]; then
        return 1
    fi
    IFS='.' read -ra VER1 <<< "$1"
    IFS='.' read -ra VER2 <<< "$2"
    for ((i=0; i<${#VER1[@]}; i++)); do
        if [[ -z ${VER2[i]} ]]; then
            VER2[i]=0
        fi
        if ((10#${VER1[i]} > 10#${VER2[i]})); then
            return 0
        elif ((10#${VER1[i]} < 10#${VER2[i]})); then
            return 2
        fi
    done
    return 1
}

# Function to process each helm chart
processChart() {
    local chart=$1
    local repoURL=$2
    local targetVersion=$3

    # Assuming chart directories are named "<chart>-<version>"
    local chartDir=$(find . -maxdepth 1 -type d -name "${chart}-*" -print -quit)
    if [[ ! -z "$chartDir" ]]; then
        local existingVersion=${chartDir##*${chart}-}
        compareVersions $targetVersion $existingVersion
        case $? in
            0)
                echo "Existing version of $chart ($existingVersion) is older than target version $targetVersion. Updating..."
                rm -rf "$chartDir"
                helm pull $chart --version $targetVersion --repo $repoURL --untar
                ;;
            1)
                echo "$chart is up to date. Version: $existingVersion."
                ;;
            2)
                echo "Existing version of $chart ($existingVersion) is newer than target version $targetVersion. No action taken."
                ;;
        esac
    else
        echo "Chart $chart not found locally. Pulling version $targetVersion..."
        helm pull $chart --version $targetVersion --repo $repoURL --untar
    fi
}

# Iterate over each helm chart in the values file
yq e '.helmCharts[] | .chart + " " + .repoURL + " " + .targetRevision' $valuesFile | while read -r line; do
    read chart repoURL targetVersion <<<"$line"
    processChart "$chart" "$repoURL" "$targetVersion"
done

#!/bin/bash

# Define the path to the values.yaml file
valuesFile="../kuberise/app-of-apps/values.yaml"

# Define directories for compressed charts and extracted charts
compressedDir="./compressed"
chartsDir="./charts"

# Ensure the directories exist
mkdir -p "$compressedDir"
mkdir -p "$chartsDir"

# Function to process each helm chart
processChart() {
    local chart=$1
    local repoURL=$2
    local targetVersion=$3

    # Determine if the chart archive already exists and is up-to-date
    local chartArchive="$compressedDir/${chart}-${targetVersion}.tgz"
    local chartDir="$chartsDir/${chart}"

    # Check if the chart is already extracted and up-to-date
    if [[ -f "$chartArchive" && -d "$chartDir" ]]; then
        # Assuming no need to check the version inside the extracted folder
        return # Chart is up-to-date; do nothing
    fi

    # Download the chart archive if it doesn't exist or isn't up-to-date
    echo "Downloading chart $chart version $targetVersion..."
    helm pull $chart --version $targetVersion --repo $repoURL --destination "$compressedDir"

    # Extract chart to the charts directory
    echo "Extracting $chartArchive to $chartDir..."
    mkdir -p "$chartDir"
    tar -xzf "$chartArchive" -C "$chartDir" --strip-components=1
}

# Iterate over each helm chart in the values file
yq e '.helmCharts[] | .chart + " " + .repoURL + " " + .targetRevision' $valuesFile | while read -r line; do
    read chart repoURL targetVersion <<<"$line"
    processChart "$chart" "$repoURL" "$targetVersion"
done

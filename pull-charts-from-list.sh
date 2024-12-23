#!/bin/bash

# This script reads a file called charts.txt with the following format:
# chartName,version,repoURL
# It will pull the chart from the repo and decompress it in the charts directory
# This scripts complements the pull-charts-from-values.sh script and
# is useful to pull charts from a list that are not part of the app of apps values.yaml

compressedDir="./compressed"
chartsDir="./charts"

filename="charts.csv"

while IFS=, read -r chart targetVersion repoURL
do
    [[ $chart =~ ^#.*$ ]] && continue # Skip lines starting with #
    echo "Pulling chart: $chart, version: $targetVersion from repo: $repoURL"

    # Check if the repoURL is an OCI repository
    if [[ $repoURL == oci://* ]]; then
        # Pull the chart from an OCI repository
        helm pull $repoURL/$chart --version $targetVersion --destination "$compressedDir"
        helm export $repoURL/$chart --version $targetVersion --destination "$compressedDir"
    else
        # Pull the chart from a non-OCI repository
        helm pull $chart --version $targetVersion --repo $repoURL --destination "$compressedDir"
    fi

    echo "Decompressing chart: $chart"
    tar -xzvf $compressedDir/$chart-$targetVersion.tgz -C "$chartsDir"
done < "$filename"

#!/bin/bash

# This script reads a file called charts.txt with the following format:
# chartName,version,repoURL
# It will pull the chart from the repo and decompress it in the charts directory
# This scripts complements the pull-charts-from-values.sh script and
# is useful to pull charts from a list that are not part of the app of apps values.yaml

compressedDir="./compressed"
chartsDir="./charts"

filename="charts.txt"

while IFS=, read -r chart targetVersion repoURL
do
    echo "Pulling chart: $chart, version: $targetVersion from repo: $repoURL"
    helm pull $chart --version $targetVersion --repo $repoURL --destination "$compressedDir"
    echo "Decompressing chart: $chart"
    tar -xzvf $compressedDir/$chart-$targetVersion.tgz -C "$chartsDir"
done < "$filename"

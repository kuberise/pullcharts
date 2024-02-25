# pullcharts

This script automates the process of downloading and decompressing Helm charts based on specifications from a `values.yaml` file. It ensures that the specified versions of Helm charts are pulled from their repositories, downloaded to a `compressed` directory, and then extracted into a `charts` directory within the current working directory.

## Use case

kuberise is an application that deploys several helm charts to kubernetes cluster. pullcharts pulls all those helm chart source code into a folder and makes it easier to check the source codes or search for a specific word among all of them.

## Prerequisites

Before running this script, ensure you have the following installed:

- Helm 3: The script uses `helm pull` to download chart archives.
- `yq` (version 4 or above): Used for parsing the `values.yaml` file.
- Bash environment: The script is a Bash script, requiring a Unix-like environment to run.

## Getting Started

1. **Clone the repository** or download the script to your local machine where you intend to manage Helm charts.

2. **Ensure `helm` and `yq` are installed** and accessible from your command line. You can verify their installation by running `helm version` and `yq --version`.

3. **Prepare your `values.yaml` file** according to your Helm chart requirements. The file should follow the structure outlined below:

    ```yaml
    helmCharts:
      keycloak:
        repoURL: https://charts.bitnami.com/bitnami
        chart: keycloak
        targetRevision: 18.4.0
      airflow:
        repoURL: https://airflow.apache.org
        chart: airflow
        targetRevision: 1.12.0
    ```

    Ensure the file is located at `../kuberise/app-of-apps/values.yaml` relative to the script or adjust the `valuesFile` variable in the script to match your file's location.

## Usage

To run the script, navigate to the directory containing the script and execute it from the terminal:

```bash
./pullcharts.sh
```

## Notes

- The script checks if a chart is already downloaded and up-to-date before proceeding with the download and extraction. This behavior minimizes unnecessary network usage and disk operations.
- If you encounter permissions issues, ensure the script is executable by running `chmod +x pullcharts.sh`.
- The script assumes connectivity to the Helm chart repositories specified in your `values.yaml` file.

## Contributing

Feel free to fork the repository and submit pull requests to improve the script or extend its capabilities.

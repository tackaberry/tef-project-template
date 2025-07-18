# GCP Project Factory

This repository contains the Terraform configuration and automation for a GCP Project Factory. It provides a standardized, repeatable, and automated way to provision new Google Cloud Platform (GCP) projects.

The core principle of this factory is to define projects as data within a `projects.json` file. A centralized Terraform configuration reads these definitions and provisions the projects accordingly. This ensures that all projects are created with a consistent set of configurations, including IAM policies, network attachments, and metadata labels.

The workflow is further streamlined by:
- A Python helper script (`add_project.py`) to safely add new project definitions.
- An Azure DevOps pipeline (`new-project-pipeline.yml`) that automates the creation of a pull request when a new project is requested.

This approach simplifies project creation, enforces governance, and provides a clear audit trail for all provisioned infrastructure.

## Automated Project Creation Workflow

The process for creating a new project is automated via an Azure DevOps pipeline, ensuring consistency and providing a clear audit trail through Git.

1.  **Request Initiation**: A user requests a new GCP project by creating a work item in a system like Azure Boards. This request includes necessary details such as the desired project name, the editor group, and data classification.

2.  **Pipeline Trigger**: The work item triggers the `new-project-pipeline.yml`. It passes the details from the work item as parameters to the pipeline run.

3.  **Create Feature Branch**: The pipeline checks out the latest code and creates a new feature branch. The branch is named using the work item ID (e.g., `feature/wi-1234`) to link the code change directly to the request.

4.  **Update Configuration**: The pipeline executes the `add_project.py` script, which adds the new project's configuration as an entry into the relevant `projects.json` file.

5.  **Commit and Push**: The pipeline commits the updated `projects.json` file to the feature branch and pushes it to the remote Git repository. The commit message also references the work item ID.

6.  **Create Pull Request**: The pipeline automatically creates a pull request (PR) to merge the feature branch into the main deployment branch. This PR provides a clear, auditable view of the proposed changes.

7.  **Review and Approval**: A designated approver (e.g., a cloud administrator) reviews the pull request. This step serves as a manual governance gate to ensure the requested project adheres to organizational standards.

8.  **Merge and Deploy**: Upon PR approval and merge, a separate build pipeline is triggered. This pipeline runs IaC deploy to provision the new GCP project as defined in the code.

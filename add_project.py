#!/usr/bin/env python3

import os
import sys
import json

def add_project_to_json():
    """
    Reads project details from environment variables and adds them
    to the projects.json file.
    """
    project_name = os.getenv("PROJECT_NAME")
    editor_group = os.getenv("EDITOR_GROUP")
    folder_path = os.getenv("FOLDER_PATH")
    data_classification = os.getenv("DATA_CLASSIFICATION", "unclass")
    workitem_id = os.getenv("WORKITEM_ID", "none")

    if not project_name or not editor_group:
        print("Error: Please set PROJECT_NAME and EDITOR_GROUP environment variables.", file=sys.stderr)
        sys.exit(1)

    json_file_path = os.path.join(os.path.dirname(__file__), f'{folder_path}/projects.json')

    # Read existing JSON data
    try:
        with open(json_file_path, 'r') as file:
            data = json.load(file) or {}
    except (FileNotFoundError, json.JSONDecodeError):
        data = {}

    # Create a unique key for the project from its name
    project_key = project_name.lower().replace(" ", "-").replace("_", "-")

    if project_key in data:
        print(f"Error: Project with key '{project_key}' already exists in {json_file_path}", file=sys.stderr)
        sys.exit(1)

    # Add the new project block
    data[project_key] = {
        'project_name': project_name,
        'editor_group': editor_group,
        'metadata': {
            'data_classification': data_classification,
            'workitem_id': workitem_id
        }
    }

    # Write the updated data back to the JSON file
    with open(json_file_path, 'w') as file:
        json.dump(data, file, indent=2)
    print(f"Successfully added project '{project_name}' to {json_file_path}")

if __name__ == "__main__":
    add_project_to_json()
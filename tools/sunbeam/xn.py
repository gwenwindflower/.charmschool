#!/usr/bin/python3

import json
import subprocess
import sys

manifest = {
    "title": "xn",
    "description": "Browse nodes in dbt manifest",
    "commands": [
        {
            "name": "search_all",
            "title": "Search all node types",
            "mode": "search",
        },
        {
            "name": "search_models",
            "title": "Search models",
            "mode": "search",
        },
        {
            "name": "search_macros",
            "title": "Search macros",
            "mode": "search",
        },
        {
            "name": "test_node",
            "title": "Test node",
            "mode": "tty",
            "params": [
                {
                    "name": "node_name",
                    "title": "Node name",
                    "type": "string",
                },
            ],
            "hidden": True,
        },
        {
            "name": "get-details",
            "title": "Get details",
            "mode": "detail",
            "params": [
                {
                    "name": "node_id",
                    "title": "Node ID",
                    "type": "string",
                },
            ],
            "hidden": True,
        },
    ],
}

if len(sys.argv) == 1:
    print(json.dumps(manifest))
    sys.exit(0)

payload = json.loads(sys.argv[1])
cwd = payload["cwd"]
dbt_manifest = json.load(open(f"{cwd}/target/manifest.json"))

macros = dbt_manifest["macros"].values()
nodes = dbt_manifest["nodes"].values()
sources = dbt_manifest["sources"].values()

models = list(filter(lambda node: node["resource_type"] == "model", nodes))
entities = list(macros) + list(nodes) + list(sources)


if payload["command"] == "search_all":
    # query = payload["query"]

    items = []

    for node in entities:
        # if query in node["unique_id"]:
        items.append(
            {
                "title": node["name"],
                "id": node["unique_id"],
                "actions": [
                    {
                        "title": "Copy node name",
                        "type": "copy",
                        "key": "c",
                        "text": node["name"],
                        "exit": True,
                    },
                    {
                        "title": "Get node details",
                        "type": "run",
                        "key": "g",
                        "command": "get-details",
                        "params": {"node_id": node["unique_id"]},
                        "exit": False,
                    },
                ],
            }
        )

    print(json.dumps({"items": items}))

if payload["command"] == "search_models":
    # query = payload["query"]

    items = []

    for node in models:
        # if query in node["unique_id"]:
        items.append(
            {
                "title": node["name"],
                "id": node["unique_id"],
                "actions": [
                    {
                        "title": "Get node details",
                        "type": "run",
                        "key": "g",
                        "command": "get-details",
                        "params": {"node_id": node["unique_id"]},
                        "exit": False,
                    },
                    {
                        "title": "Copy node name",
                        "type": "copy",
                        "key": "c",
                        "text": node["name"],
                        "exit": True,
                    },
                    {
                        "title": "Test model",
                        "type": "run",
                        "key": "t",
                        "command": "test_node",
                        "params": {"node_name": node["name"]},
                        "exit": False,
                    },
                ],
            }
        )

    print(json.dumps({"items": items}))

elif payload["command"] == "search_macros":
    # query = payload["query"]
    items = []
    for macro in macros:
        # if query in macro["unique_id"]:
        items.append(
            {
                "title": macro["name"],
                "id": macro["unique_id"],
                "actions": [
                    {
                        "title": "Copy macro name",
                        "type": "copy",
                        "key": "c",
                        "text": macro["name"],
                        "exit": True,
                    },
                    {
                        "title": "Copy run-operation command",
                        "type": "copy",
                        "key": "r",
                        "text": "dbt run-operation " + macro["name"],
                        "exit": True,
                    },
                ],
            }
        )
    print(json.dumps({"items": items}))

elif payload["command"] == "get-details":
    filtered_entities = list(
        filter(lambda node: node["unique_id"] == payload["params"]["node_id"], entities)
    )
    entity = filtered_entities[0]
    if entity["resource_type"] == "model":
        compiled_path = entity["compiled_path"]
    else:
        compiled_path = "N/A"
    text = f"""
    \033[1;32m{entity['name']}\033[0m

    \033[1mDetails\033[0m

    \033[0;32m\u2022 unique_id: {entity['unique_id']}
    \033[0;32m\u2022 resource_type: {entity['resource_type']}
    \033[0;32m\u2022 original_file_path: {entity['original_file_path']}
    \033[0;32m\u2022 compiled_path: {compiled_path}
    \033[0;32m\u2022 depends_on: {entity['depends_on']}
    \033[0;32m\u2022 columns: {entity['columns']}
    """

    print(
        json.dumps(
            {
                "format": "ansi",
                "text": text,
                "actions": [
                    {
                        "title": "Show compiled",
                        "type": "open",
                        "key": "s",
                        "path": f"{payload['cwd']}/{entity['compiled_path']}",
                    }
                ],
            }
        )
    )

elif payload["command"] == "test_node":

    def dbt_test(node_name):
        test = subprocess.run(
            ["dbt", "test", "-s", node_name],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        return test

    node_name = payload["params"]["node_name"]
    test_result = dbt_test(node_name)


else:
    print(f"Unknown command: {payload['command']}")
    sys.exit(1)

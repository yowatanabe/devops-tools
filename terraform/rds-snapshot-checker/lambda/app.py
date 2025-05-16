import json
import os
import urllib.request
from datetime import datetime, timedelta, timezone

import boto3
import pytz


def get_secret(secret_name):
    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response["SecretString"])["ASANA_TOKEN"]


def get_old_snapshots(age_days):
    rds = boto3.client("rds")
    jst = pytz.timezone("Asia/Tokyo")
    cutoff = datetime.now(timezone.utc) - timedelta(days=age_days)
    results = []

    # RDS instance snapshots
    instance_snaps = rds.describe_db_snapshots(SnapshotType="manual")["DBSnapshots"]
    for s in instance_snaps:
        if s["SnapshotCreateTime"] < cutoff:
            snap_id = s["DBSnapshotIdentifier"]
            created = (
                s["SnapshotCreateTime"].astimezone(jst).strftime("%b %d, %Y, %H:%M")
            )
            size_gb = s.get("AllocatedStorage", "N/A")
            results.append(f"{snap_id} / {size_gb} GB / {created} (UTC+09:00)")

    # Aurora cluster snapshots
    cluster_snaps = rds.describe_db_cluster_snapshots(SnapshotType="manual")[
        "DBClusterSnapshots"
    ]
    for s in cluster_snaps:
        if s["SnapshotCreateTime"] < cutoff:
            snap_id = s["DBClusterSnapshotIdentifier"]
            created = (
                s["SnapshotCreateTime"].astimezone(jst).strftime("%b %d, %Y, %H:%M")
            )
            size_gb = s.get("AllocatedStorage", "N/A")
            results.append(f"{snap_id} / {size_gb} GB / {created} (UTC+09:00)")

    return results


def lambda_handler(event, context):
    # Load settings
    secret_name = os.environ["SECRET_NAME"]
    project_id = os.environ["ASANA_PROJECT_ID"]
    age_days = int(os.environ["SNAPSHOT_AGE_DAYS"])

    # Get Asana token
    token = get_secret(secret_name)

    # Collect old snapshots
    old_snaps = get_old_snapshots(age_days)
    if not old_snaps:
        print("No outdated snapshots found.")
        return

    # Build task body
    account_id = boto3.client("sts").get_caller_identity()["Account"]
    header = f"Here is the list of RDS snapshots older than {age_days} days. Please delete any that are no longer needed."
    account_line = f"<h2>AWS Account: {account_id}</h2>"
    snapshot_lines = "\n".join(old_snaps)
    html_body = f"<body>{header}\n\n{account_line}{snapshot_lines}</body>"

    # Post to Asana
    req = urllib.request.Request(
        url="https://app.asana.com/api/1.0/tasks",
        data=json.dumps(
            {
                "data": {
                    "name": f"RDS Snapshots Report (>{age_days} days)",
                    "html_notes": html_body,
                    "projects": [project_id],
                }
            }
        ).encode(),
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with urllib.request.urlopen(req) as res:
        print("Asana task created:", res.status)

import csv
import json
import os
import urllib.request
from datetime import datetime
from io import StringIO

import boto3
import pytz

# Initialize clients as global variables
rds = boto3.client("rds")
jst = pytz.timezone("Asia/Tokyo")


def get_japanese_holidays(year):
    """
    Get Japanese holidays for the specified year from the Cabinet Office

    Args:
        year (int): Year to retrieve holidays for (e.g., 2025)

    Returns:
        set: Set of holidays for the specified year (YYYY-MM-DD format)
    """
    # Official holiday CSV file from the Cabinet Office
    url = "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"
    try:
        # Create HTTP request with User-Agent header
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        # Download CSV file with 10-second timeout
        with urllib.request.urlopen(req, timeout=10) as response:
            # Decode data encoded in Shift_JIS
            content = response.read().decode("shift_jis")

        holidays = set()
        # Parse CSV data
        reader = csv.reader(StringIO(content))
        next(reader)  # Skip header row

        # Process each row and extract holidays for the specified year only
        for row in reader:
            if len(row) >= 1:
                # Normalize date format (YYYY/M/D → YYYY-M-D)
                date_str = row[0].replace("/", "-")
                parts = date_str.split("-")
                # Process only data for the specified year
                if len(parts) == 3 and parts[0] == str(year):
                    # Format to YYYY-MM-DD (zero-pad month and day)
                    formatted_date = (
                        f"{parts[0]}-{parts[1].zfill(2)}-{parts[2].zfill(2)}"
                    )
                    holidays.add(formatted_date)

        return holidays
    except Exception as e:
        # Return empty set on error to continue processing
        print(f"Failed to fetch holidays: {e}")
        return set()


def process_rds_instances(action):
    """
    Start/stop RDS instances
    Only targets instances with AutoSchedule=true tag

    Args:
        action (str): Action to perform ("start" or "stop")

    Raises:
        Exception: When an error occurs in RDS API calls
    """
    try:
        # Get information for all RDS instances
        instances = rds.describe_db_instances()["DBInstances"]

        # Check each instance
        for instance in instances:
            db_id = instance["DBInstanceIdentifier"]
            arn = instance["DBInstanceArn"]
            status = instance["DBInstanceStatus"]

            # Get instance tags and check for AutoSchedule tag
            tags = rds.list_tags_for_resource(ResourceName=arn)["TagList"]
            if not any(
                tag["Key"] == "AutoSchedule" and tag["Value"] == "true" for tag in tags
            ):
                # Skip if AutoSchedule=true tag is not present
                continue

            # Execute processing based on action and status
            if action == "start" and status == "stopped":
                # Start stopped instance
                rds.start_db_instance(DBInstanceIdentifier=db_id)
                print(f"Started RDS instance: {db_id}")
            elif action == "stop" and status == "available":
                # Stop running instance
                rds.stop_db_instance(DBInstanceIdentifier=db_id)
                print(f"Stopped RDS instance: {db_id}")
            # Do nothing for other statuses (starting, stopping, etc.)

    except Exception as e:
        print(f"Error processing RDS instances: {e}")
        raise


def process_aurora_clusters(action):
    """
    Start/stop Aurora clusters
    Only targets clusters with AutoSchedule=true tag

    Args:
        action (str): Action to perform ("start" or "stop")

    Raises:
        Exception: When an error occurs in RDS API calls
    """
    try:
        # Get information for all Aurora clusters
        clusters = rds.describe_db_clusters()["DBClusters"]

        # Check each cluster
        for cluster in clusters:
            cluster_id = cluster["DBClusterIdentifier"]
            arn = cluster["DBClusterArn"]
            status = cluster["Status"]

            # Get cluster tags and check for AutoSchedule tag
            tags = rds.list_tags_for_resource(ResourceName=arn)["TagList"]
            if not any(
                tag["Key"] == "AutoSchedule" and tag["Value"] == "true" for tag in tags
            ):
                # Skip if AutoSchedule=true tag is not present
                continue

            # Execute processing based on action and status
            if action == "start" and status == "stopped":
                # Start stopped cluster
                rds.start_db_cluster(DBClusterIdentifier=cluster_id)
                print(f"Started Aurora cluster: {cluster_id}")
            elif action == "stop" and status == "available":
                # Stop running cluster
                rds.stop_db_cluster(DBClusterIdentifier=cluster_id)
                print(f"Stopped Aurora cluster: {cluster_id}")
            # Do nothing for other statuses (starting, stopping, etc.)

    except Exception as e:
        print(f"Error processing Aurora clusters: {e}")
        raise


def lambda_handler(event, context):
    """
    Main handler for Lambda function
    Start/stop RDS/Aurora based on action parameter received from EventBridge

    Args:
        event: Event passed from EventBridge ({"action": "start"} or {"action": "stop"})
        context: Lambda execution context

    Returns:
        dict: Dictionary containing HTTP status code and message
    """
    try:
        # Get action from EventBridge input ("start" or "stop")
        action = event.get("action")
        if not action:
            return {"statusCode": 400, "body": "Missing action parameter"}

        # Get current Japan time
        now = datetime.now(jst)
        today = now.strftime("%Y-%m-%d")

        # Check for holidays (skip processing if it's a holiday)
        holidays = get_japanese_holidays(now.year)
        if today in holidays:
            print(f"Today is a holiday ({today}). Skipping action.")
            return {"statusCode": 200, "body": "Holiday - no action taken"}

        # Process RDS/Aurora with AutoSchedule=true tag
        process_rds_instances(action)
        process_aurora_clusters(action)

        return {"statusCode": 200, "body": f"Action {action} completed"}

    except Exception as e:
        print(f"Lambda execution failed: {e}")
        return {"statusCode": 500, "body": f"Error: {str(e)}"}

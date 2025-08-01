# RDS Auto Scheduler

A lightweight AWS Lambda solution to automatically start and stop RDS and Aurora instances based on a configurable schedule.

## Features

* Supports both RDS instances and Aurora clusters.
* Automatically excludes Japanese holidays from scheduled operations.
* Only targets resources with `AutoSchedule=true` tag.
* Scheduled via EventBridge with customizable frequency.
* Separate start and stop schedules for flexible operation.

## Project Structure

```none
.
├── src/
│   ├── __init__.py                    # Python package marker
│   ├── custom_holidays.csv            # Custom holiday configuration
│   ├── lambda_function.py             # Lambda function source code
│   └── requirements.txt               # Python dependencies
├── terraform/
│   ├── .terraform.lock.hcl            # Terraform provider lock file
│   ├── main.tf                        # Main Terraform configuration
│   ├── provider.tf                    # Provider configuration
│   ├── terraform.auto.tfvars.template # Template for variables
│   ├── terraform.tf                   # Terraform version and provider requirements
│   └── variables.tf                   # Variable definitions
├── tests/s
│   ├── __init__.py                    # Python package marker
│   └── test_lambda_function.py        # Holiday detection test
├── .gitignore                         # Git ignore rules
├── build_lambda.sh                    # Script to build Lambda deployment package
└── README.md                          # Project documentation
```

## Getting Started

### Prerequisites

* Terraform (Tested with version `1.12.2`)
* Python (Tested with version `3.13.5`)
* AWS account (with permissions to create Lambda, IAM, EventBridge)

### Setup

1. Clone the repository.

   ```bash
   git clone https://github.com/yowatanabe/devops-tools.git
   cd terraform/rds-auto-scheduler/terraform
   ```

1. Create `terraform.auto.tfvars` from the provided template.

   ```bash
   cp terraform.auto.tfvars.template terraform.auto.tfvars
   ```

1. Edit `terraform.auto.tfvars` to configure your schedules.

1. Deploy with the following command

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Configuration

The following variables should be defined in a file named `terraform.auto.tfvars`, which Terraform will automatically load during execution:

* `start_schedule`: Cron expression for starting RDS/Aurora (e.g., `cron(0 9 ? * MON-FRI *)`)
* `stop_schedule`: Cron expression for stopping RDS/Aurora (e.g., `cron(0 18 ? * MON-FRI *)`)

## Tagging Resources

To enable auto-scheduling for your RDS instances or Aurora clusters, add the `AutoSchedule=true` tag:

```bash
# RDS instance
aws rds add-tags-to-resource \
  --resource-name arn:aws:rds:ap-northeast-1:123456789012:db:mydb \
  --tags Key=AutoSchedule,Value=true

# Aurora cluster
aws rds add-tags-to-resource \
  --resource-name arn:aws:rds:ap-northeast-1:123456789012:cluster:mycluster \
  --tags Key=AutoSchedule,Value=true
```

## Testing

Test the holiday detection functionality before deployment:

```bash
# Test current year
python -m tests.test_lambda_function

# Test specific year
python -m tests.test_lambda_function 2025
```

The test will show:

* Official holidays (from Cabinet Office)
* Custom holidays (from `src/custom_holidays.csv`)
* Weekends (normally handled by EventBridge cron schedule)
* Working days (when Lambda will execute)

### Custom Holidays

Edit `src/custom_holidays.csv` to add company-specific holidays:

```csv
2025-01-02
2025-01-03
2025-12-29
2025-12-30
2025-12-31
```

# cmdRunner

A simple Bash script that executes a list of commands sequentially.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Using the Default Command File](#using-the-default-command-file)
  - [Specifying a Custom Command File](#specifying-a-custom-command-file)
- [Saving Output to a File](#saving-output-to-a-file)
  - [Saving Standard Output Only](#saving-standard-output-only)
  - [Saving Both Standard Output and Standard Error](#saving-both-standard-output-and-standard-error)
  - [Appending Output to an Existing File](#appending-output-to-an-existing-file)
- [Examples](#examples)
- [Notes](#notes)
- [License](#license)

## Overview

`cmdRunner.sh` reads commands from a text file (`cmdList.txt` by default) and executes them one by one.
This script is useful for automating batch processes or running a series of commands with controlled timing.

## Prerequisites

- **Operating System**: macOS
- **Shell**: Bash (should be available by default on macOS)
- **Permissions**: Execute permission for `cmdRunner.sh`

## Installation

1. **Download the Script**: Save `cmdRunner.sh` to your desired directory.

2. **Create the Command File**: Create a `cmdList.txt` file in the same directory, containing the commands you wish to execute, one per line.

3. **Set Execute Permission**:

   ```bash
   chmod +x cmdRunner.sh
   ```

## Usage

### Using the Default Command File

By default, `cmdRunner.sh` reads commands from `cmdList.txt`.

```bash
./cmdRunner.sh
```

### Specifying a Custom Command File

You can specify a different command file as an argument.

```bash
./cmdRunner.sh customCommands.txt
```

## Saving Output to a File

You can save the output of `./cmdRunner.sh` to a text file by redirecting the standard output and standard error streams.

### Saving Standard Output Only

To save only the standard output (normal messages) to `output.txt`:

```bash
./cmdRunner.sh > output.txt
```

This command redirects the standard output to `output.txt`.

### Saving Both Standard Output and Standard Error

To include standard error output (error messages) in the same file:

```bash
./cmdRunner.sh > output.txt 2>&1
```

This redirects both standard output and standard error to `output.txt`.

### Appending Output to an Existing File

If you want to append the output to an existing `output.txt` file without overwriting it, use `>>` instead of `>`:

```bash
./cmdRunner.sh >> output.txt 2>&1
```

This appends all output to the end of `output.txt`.

## Examples

### Example `cmdList.txt`

```bash
echo "Starting batch process..."
pwd
ls -la
echo "Process completed."
```

### Running the Script

```bash
./cmdRunner.sh
```

### Expected Output

```
Executing: echo "Starting batch process..."
Starting batch process...
Executing: pwd
/Users/yourusername/path/to/directory
Executing: ls -la
(total list of files and directories)
Executing: echo "Process completed."
Process completed.
```

## Notes

- **File Not Found**: If the specified command file does not exist, the script will output an error message and exit.

  ```
  Error: Command file 'cmdList.txt' not found.
  ```

- **Line Endings**: Ensure that your command file uses Unix-style line endings (LF) to avoid execution issues.

# Sync Directories

## Overview
This script syncs source & replica directories.

### Script User Input
* Source Directory
* Replica Directory
* Log Directory

## Running Script
### Windows
Run follwing command from powershell prompt:
```
.\one-way-sync-powershell-script.ps1
```

Provide user inputs.

**Note**: Input variables should contain full path e.g.  F:\replica

### Linux
Install Powershell from Microsoft documentation

Run follwing command from powershell prompt:
```
./one-way-sync-powershell-script.ps1
```

Provide user inputs.

**Note**: Input variables should contain full path e.g.  /home/ubuntu/source

## Details
* This script compare contents of Source & Replica directories
* The new content in Source directory is copied to Replica directory
* Extra files in Replica directory that are not part of Source directory are removed from Replica Directory
* Content of Source Directory is never changed by this script
* After running this script, COPY and DELETE operation brings Source and Replica directory in sync

### Error Handling
Script handles following edge cases:
* If Source directory is missing, the script throws a custom error and stops execution
* If Replica directory is missing, script creates Replica directory
* If log directory is missing, script creates log directory

### Exception
Following cases are not handled:
* On Windows, if a directory is renamed. Script does not sync content inside the renamed directoy on first run, workaround is to run script twice. Works fine on Linux
* As part of requirement, no file will be copied from Replica to Source directory. Sync is only from Source to Replica directory



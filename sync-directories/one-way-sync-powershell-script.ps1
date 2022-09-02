#Read Dyamic Inputs from User
param (
    [Parameter(Mandatory = $true)]
    [string]
    $SourceDirectory
,
    [Parameter(Mandatory = $true)]
    [string]
    $TargetDirectory
,
    [Parameter(Mandatory = $true)]
    [string]
    $LogDirectory
)


#Creating Log Directory/File if does not exist
function Create-LogDirectory{
    param (
        [string[]]$logDirectory, [string[]]$logFile
    )
	
	try {
		if (-not (Test-Path -Path $LogDirectory -ErrorAction Stop )) {
			Write-Host "Creating Log Dir: $LogDirectory"
			New-Item -ItemType Directory -Path $LogDirectory -ErrorAction Stop  | Out-Null
			Write-Host "Creating Log File: $logFile"
			New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
		}
		
		if (-not (Test-Path -Path $logFile -ErrorAction Stop )) {
			Write-Host "Creating Log File: $logFile"
			New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
		}
	}
	catch {
		throw "Problem in creating log Directory/File $logFile"
	}
}


#Writes logs to Log file and Console
function Create-LogStatement {
	param (
        [string[]]$logFile, [string[]]$logLevel, [string[]]$logStatement
    )
	
	Add-Content -Path $logFile -Value "[$logLevel] $logStatement"
	Write-Host "[$logLevel] $logStatement"
}

#Throw Error if SourceDirectory does not exist
function Validate-SourceDirectory{
   param (
        [string[]]$SourceDirectory, [string[]]$logFile
    )
	
	if (-not (Test-Path -Path $SourceDirectory -ErrorAction Stop)) {
		$log = "Source Directory does not exist. Throwing error..."
		Create-LogStatement -logFile $logFile -logLevel "ERROR" -logStatement $log
		throw "$log"
	}
	
}


#Creating TargetDirectory if it does not exist
function Validate-DestinationDirectory{
	param (
        [string[]]$TargetDirectory, [string[]]$logFile
    )
	if (-not (Test-Path -Path $TargetDirectory -ErrorAction Stop)) {
		$log = "Creating TargetDirectory as it does not exist. TargetDirectory: $TargetDirectory"
		Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement $log
			
		New-Item -ItemType Directory -Path $TargetDirectory -ErrorAction Stop  | Out-Null
	}
	
	
}

#Sync Source and Target Directories
function Sync-Files{
	param (
        [string[]]$SourceDirectory, [string[]]$TargetDirectory, [string[]]$logFile
    )
	
	#Start Sync
	Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "...Start Sync..."
	
	#Creating tmp files to avoid null comparison error
	$tmpFile = "tmp.txt"
	Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "Creating tmp directory in source and target directories"
	New-Item -ItemType File -Path $SourceDirectory/$tmpFile -ErrorAction SilentlyContinue | Out-Null
	New-Item -ItemType File -Path $TargetDirectory/$tmpFile -ErrorAction SilentlyContinue  | Out-Null
	
	#Comparing objects in two directories, like linux diff
	$sourceFiles=Get-ChildItem -Path $SourceDirectory -Recurse
	$targetFiles=Get-ChildItem -Path $TargetDirectory -Recurse
	$fileDifference=Compare-Object -ReferenceObject $sourceFiles -DifferenceObject $targetFiles

	#Loop all incoming & outgoing objects
    foreach($object in $fileDifference) {
		
		#Copy outgoing objects, Delete Incoming Objects, to achieve Sync
		if($object.SideIndicator -eq "<=") {
			
			$sourceObject = $object.InputObject.FullName
            $targetObject = $object.InputObject.FullName.Replace($SourceDirectory, $TargetDirectory)
			
			Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "Outgoing object: $sourceObject"
			Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "...{COPY} this object to target directory"
			
            Copy-Item -Path $sourceObject -Destination $targetObject
		}
		else{
			$targetObject = $object.InputObject.FullName
			Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "Incoming object: $targetObject"
			Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "...{DELETE} this object from target directory"
			Remove-Item -Path $targetObject -Recurse -ErrorAction SilentlyContinue | Out-Null
		}
    }

    #Removing tmp files
	Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "Removing tmp files"
	Remove-Item -Path $SourceDirectory/$tmpFile | Out-Null
	Remove-Item -Path $TargetDirectory/$tmpFile | Out-Null
	
	#Sync Over
	Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "...Finish Sync..."
	
}


#Executes all methods serially
function Start-Execution{
	param (
        [string[]]$SourceDirectory, [string[]]$TargetDirectory, [string[]]$LogDirectory
    )
	
	Write-Host "======= Starting Execution ========"
	
	#Create LogDirectory
	$logFileName = "sync-dir.log"
	$logFile = "$LogDirectory\$logFileName"
	Create-LogDirectory -logDirectory $LogDirectory -logFile $logFile
	
	#Logging Input Parameters
	$log="Input Parameters -- SourceDir: $SourceDirectory TargetDir: $TargetDirectory LogDirectory:$LogDirectory"
	Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement $log
	
	#Validate Source Directory
	Validate-SourceDirectory -SourceDirectory $SourceDirectory -logFile $logFile
	
	#Validate Destination Directory
	Validate-DestinationDirectory -TargetDirectory $TargetDirectory -logFile $logFile
	
	#Sync Files
	Sync-Files -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory -logFile $logFile
	
	Create-LogStatement -logFile $logFile -logLevel "INFO" -logStatement "======= Execution Finish ========"
}

#Start Execution
Start-Execution -SourceDirectory $SourceDirectory -TargetDirectory $TargetDirectory -LogDirectory $LogDirectory


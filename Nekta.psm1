#==========================================================================
# List of all functions in this script:
# -------------------------------------
# -Windows functions
#     -Files and folders
#       -Nekta_PurgeFiles                           -> Delete files in a directory
#       -Nekta_CopyArchive                          -> Copy a file or multiple files
#       -Nekta_NewDirectory                         -> Create a directory
#       -Nekta_WipeDirectory                        -> Delete a directory
#       -Nekta_MoveDirectory                        -> Move a directory
#       -Nekta_DeleteFile                           -> Delete a file
#       -Nekta_RenameItem                           -> Rename a file or registry value
#       -Nekta_UnzipArchive                         -> Expand a zip file 
#       -Nekta_AddStream                            -> Add content to a file
#       -Nekta_GetStream                            -> Get content from file 
#       -Nekta_MoveArchive                          -> Move a file or multiple files
#       -Nekta_GetFileName                          -> Get a name of any file
#       -Nekta_ISOSetupInstall                      -> Execute an EXE file located on a ISO image, with or without arguments.
#     -Installations and executables
#       -Nekta_RunProcess                           -> Start a process
#       -Nekta_RunProcessNoWait                     -> Start a process without wait 
#       -Nekta_MSIInstall                           -> Install msi software
#       -Nekta_SetupInstall                         -> Install exe software
#     -Logging
#       -Nekta_Logging                              -> Write log file
#     -Registry
#       -Nekta_NewRegKey                            -> Create a registry key
#       -Nekta_DeleteRegKey                         -> Delete a registry key
#       -Nekta_DeleteRegKeyValue                    -> Delete a registry value (any data type)
#       -Nekta_ImportRegFile                        -> Import a registry (*.reg) file into the registry
#       -Nekta_RenameRegKey                         -> Rename a registry key
#       -Nekta_RenameRegKeyValue                    -> Rename a registry value
#       -Nekta_SetRegKeyValue                       -> Create or modify a registry value (any data type)
#     -Services
#       -Nekta_ModifyStartupService                 -> Change the startup type of a service (Boot, System, Automatic, Manual and Disabled)
#       -Nekta_StopService                          -> Stop a service (including depend services)
#       -Nekta_StartingService                      -> Start service (including depend services)
#     -System
#       -Nekta_WipePrefetch                         -> Clear prefetch folder
#       -Nekta_StartStopProcess                     -> Start and stop a process     
#       -Nekta_ResolvePath                          -> Resolves a given path (Path or LiteralPath) and checks if it exists.
#     -Downloads
#       -Nekta_ResolveUri                           -> Resolves a URI and retrieves information such as file size, last modified date, and filename.
#       -Nekta_NovaDownloader                       -> Downloading a file with progress bar and some features
#

$global:ErrorActionPreference = "Stop"
if ($verbose) { $global:VerbosePreference = "Continue" }

if (([string]::IsNullOrEmpty($LogFile)) -Or ($LogFile.Length -eq 0)) {
    $LogDir = "$env:TEMP\Logs"
    $LogFileName = "DefaultLogFile_$(Get-Date -format dd-MM-yyyy)_$((Get-Date -format HH:mm:ss).Replace(":","-")).log"
    $LogFile = Join-path $LogDir $LogFileName
}

# FUNCTION Nekta_PurgeFiles
# Description: delete all files and subfolders in one specific directory (e.g. C:\Windows\Temp). Do not delete the main folder itself.
#==========================================================================
Function Nekta_PurgeFiles {
    <#
        .SYNOPSIS
        Delete all files and subfolders in one specific directory, but do not delete the main folder itself
        .DESCRIPTION
        Delete all files and subfolders in one specific directory, but do not delete the main folder itself
        .PARAMETER Directory
        This parameter contains the full path to the directory that needs to cleaned (for example 'C:\Temp')
        .EXAMPLE
        Nekta_PurgeFiles -Directory "C:\Temp"
        Deletes all files and subfolders in the directory 'C:\Temp'
    #>
    [CmdletBinding()]
    Param( 
        [Alias("D")]
        [Parameter(Mandatory = $true, Position = 0)][String]$Directory
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Cleanup directory $Directory" $LogFile
        if (Test-Path $Directory ) {
            try {
                Remove-Item "$Directory\*.*" -Force -Recurse | Out-Null
                Remove-Item "$Directory\*" -Force -Recurse | Out-Null
                Nekta_Logging "SUCCESS" "Successfully deleted all files and subfolders in the directory $Directory" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to delete files and subfolders in the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "INFO" "The directory $Directory does not exist. Nothing to do" $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_UnzipArchive
#==========================================================================

Function Nekta_UnzipArchive {
    <#
        .SYNOPSIS
        Expand an archive file (ZIP).
        .DESCRIPTION
        This function extracts the contents of a compressed archive (ZIP) to a specified destination folder.
        .PARAMETER File
        This parameter contains the full path to the ZIP file that you want to extract.
        .PARAMETER DestinationPath
        This parameter contains the full path to the directory where the contents will be extracted.
        .PARAMETER Pattern
        This parameter specifies whether existing files should be overwritten. The default is 'True'.
        .EXAMPLE
        Nekta_UnzipArchive -File "C:\Temp\MyArchive.zip" -DestinationPath "C:\Temp\ExtractedFiles" -Pattern $true
        Extracts the ZIP file 'MyArchive.zip' to the folder 'ExtractedFiles', overwriting existing files.
    #>
    [CmdletBinding()]
    Param(
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$File,
        [Alias("D")]
        [Parameter(Mandatory = $false, Position = 1)][AllowEmptyString()][String]$DestinationPath,
        [Alias("P")]
        [switch]$Pattern
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Logging source and destination paths
        Nekta_Logging "INFO" "Source file: $File" $LogFile
        Nekta_Logging "INFO" "Destination path: $DestinationPath" $LogFile

        # Check if the source file exists
        if (!(Test-Path $File)) {
            Nekta_Logging "ERROR" "The file '$File' does not exist!" $LogFile
            Exit 1
        }

        # Check if the destination directory exists, if not, create it
        if (!(Test-Path $DestinationPath)) {
            Nekta_Logging "INFO" "The destination directory does not exist. Creating directory: $DestinationPath" $LogFile
            New-Item -ItemType Directory -Path $DestinationPath | Out-Null
        }

        # Expand the archive
        try {
            if ($Pattern) {
                Nekta_Logging "INFO" "Expanding archive '$File' to '$DestinationPath' with overwrite enabled" $LogFile
                Expand-Archive -Path $File -DestinationPath $DestinationPath -Force
            }
            else {
                Nekta_Logging "INFO" "Expanding archive '$File' to '$DestinationPath' without overwriting" $LogFile
                Expand-Archive -Path $File -DestinationPath $DestinationPath
            }
            Nekta_Logging "SUCCESS" "The archive '$File' was successfully extracted to '$DestinationPath'" $LogFile
        }
        catch {
            Nekta_Logging "ERROR" "An error occurred while extracting the archive '$File' to '$DestinationPath': $_" $LogFile
            Exit 1
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_AddStream
#==========================================================================

Function Nekta_AddStream {
    <#
        .SYNOPSIS
        Adds content to a file.
        .DESCRIPTION
        This function adds specified content to a file. If the file does not exist, it will be created automatically.
        .PARAMETER FilePath
        Path to the file where content will be added.
        .PARAMETER Content
        Content to be added to the file.
        .EXAMPLE
        Nekta_AddStream -FilePath "C:\Logs\example.txt" -Content "This is a new line of text."
        Adds the line "This is a new line of text." to the file example.txt at the specified path.
    #>
    [CmdletBinding()]
    Param(
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$FilePath,
        [Alias("C")]
        [Parameter(Mandatory = $true, Position = 1)][String]$Content
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the start of the content-adding process
        Nekta_Logging "INFO" "Adding content to the file '$FilePath'" $LogFile

        try {
            # Add the content to the specified file
            Add-Content -Path $FilePath -Value $Content
            Nekta_Logging "INFO" "Content successfully added to '$FilePath'" $LogFile
        }
        catch {
            # Log any errors encountered during the content addition
            Nekta_Logging "ERROR" "Error adding content to '$FilePath' (error: $($_.Exception.Message))" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_GetStream
#==========================================================================

Function Nekta_GetStream {
    <#
        .SYNOPSIS
        Retrieves content from a file.
        .DESCRIPTION
        This function retrieves the content of a specified file. If the file does not exist, it will log a warning.
        .PARAMETER FilePath
        Path to the file from which content will be retrieved.
        .EXAMPLE
        Nekta_GetStream -FilePath "C:\Logs\example.txt"
        Retrieves and returns the content of the file example.txt at the specified path.
    #>
    [CmdletBinding()]
    Param(
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$FilePath
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the attempt to read content from the file
        Nekta_Logging "INFO" "Retrieving content from the file '$FilePath'" $LogFile

        try {
            # Check if the file exists before reading
            if (Test-Path $FilePath) {
                # Get the content from the specified file
                $Content = Get-Content -Path $FilePath
                Nekta_Logging "INFO" "Content successfully retrieved from '$FilePath'" $LogFile
                return $Content
            }
            else {
                # Log a warning if the file does not exist
                Nekta_Logging "WARNING" "File '$FilePath' does not exist." $LogFile
                return $null
            }
        }
        catch {
            # Log any errors encountered during the content retrieval
            Nekta_Logging "ERROR" "Error retrieving content from '$FilePath' (error: $($_.Exception.Message))" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}


#==========================================================================

# FUNCTION Nekta_MoveArchive
#==========================================================================
Function Nekta_MoveArchive {
    <#
        .SYNOPSIS
        Move one or more files
        .DESCRIPTION
        Move one or more files to a specified destination.
        .PARAMETER SourceFiles
        Specifies the source file(s) or folder(s) to move. Wildcards can be used, and UNC paths are supported.
        .PARAMETER Destination
        Specifies the destination path where the file(s) should be moved. The path may include a file name to rename the file during the move operation.
        .EXAMPLE
        Nekta_MoveArchive -SourceFiles "C:\Temp\MyFile.txt" -Destination "C:\Temp2"
        Moves 'C:\Temp\MyFile.txt' to 'C:\Temp2'.
        .EXAMPLE
        Nekta_MoveArchive -SourceFiles "C:\Temp\MyFile.txt" -Destination "C:\Temp2\MyRenamedFile.txt"
        Moves 'C:\Temp\MyFile.txt' to 'C:\Temp2' and renames it to 'MyRenamedFile.txt'.
        .EXAMPLE
        Nekta_MoveArchive -SourceFiles "C:\Temp\*.txt" -Destination "C:\Temp2"
        Moves all '.txt' files from 'C:\Temp' to 'C:\Temp2'.
    #>
    [CmdletBinding()]
    Param(
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$Files,
        [Alias("D")]
        [Parameter(Mandatory = $true, Position = 1)][String]$Destination
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the source and destination details
        Nekta_Logging "INFO" "Move the source file(s) '$Files' to '$Destination'" $LogFile

        # Determine the destination directory, creating it if needed
        if ($Destination.Contains(".")) {
            # If $Destination contains a dot, treat it as a path with a filename
            $TempFolder = Split-Path -Path $Destination
        }
        else {
            # Otherwise, assume it's a directory path
            $TempFolder = $Destination
        }

        # Check if destination path exists; create it if it does not
        Nekta_Logging "INFO" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if (Test-Path $TempFolder) {
            Nekta_Logging "INFO" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        }
        else {
            Nekta_Logging "INFO" "The destination path '$TempFolder' does not exist" $LogFile
            Nekta_NewDirectory -Directory $TempFolder
        }

        # Move the source files
        Nekta_Logging "INFO" "Start moving the source file(s) '$Files' to '$Destination'" $LogFile
        try {
            Move-Item -Path $Files -Destination $Destination -Force
            Nekta_Logging "SUCCESS" "Successfully moved the source file(s) '$Files' to '$Destination'" $LogFile
        }
        catch {
            # Log the error if the move fails
            Nekta_Logging "ERROR" "An error occurred while moving the source file(s) '$Files' to '$Destination'. Error: $($_.Exception.Message)" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_CopyArchive
#==========================================================================
Function Nekta_CopyArchive {
    <#
        .SYNOPSIS
        Copy one or more files
        .DESCRIPTION
        Copy one or more files
        .PARAMETER SourceFiles
        This parameter can contain multiple file and folder combinations including wildcards. UNC paths can be used as well. Please see the examples for more information.
        To see the examples, please enter the following PowerShell command: Get-Help Nekta_CopyArchive -examples
        .PARAMETER Destination
        This parameter contains the destination path (for example 'C:\Temp2' or 'C:\MyPath\MyApp'). This path may also include a file name.
        This situation occurs when a single file is copied to another directory and renamed in the process (for example '$Destination = C:\Temp2\MyNewFile.txt').
        UNC paths can be used as well. The destination directory is automatically created if it does not exist (in this case the function 'Nekta_NewDirectory' is called). 
        This works both with local and network (UNC) directories. In case the variable $Destination contains a path and a file name, the parent folder is 
        automatically extracted, checked and created if needed. 
        Please see the examples for more information.To see the examples, please enter the following PowerShell command: Get-Help Nekta_CopyArchive -examples
        .EXAMPLE
        Nekta_CopyArchive -Files "C:\Temp\MyFile.txt" -Destination "C:\Temp2"
        Copies the file 'C:\Temp\MyFile.txt' to the directory 'C:\Temp2'
        .EXAMPLE
        Nekta_CopyArchive -Files "C:\Temp\MyFile.txt" -Destination "C:\Temp2\MyNewFileName.txt"
        Copies the file 'C:\Temp\MyFile.txt' to the directory 'C:\Temp2' and renames the file to 'MyNewFileName.txt'
        .EXAMPLE
        Nekta_CopyArchive -Files "C:\Temp\*.txt" -Destination "C:\Temp2"
        Copies all files with the file extension '*.txt' in the directory 'C:\Temp' to the destination directory 'C:\Temp2'
        .EXAMPLE
        Nekta_CopyArchive -Files "C:\Temp\*.*" -Destination "C:\Temp2"
        Copies all files within the root directory 'C:\Temp' to the destination directory 'C:\Temp2'. Subfolders (including files within these subfolders) are NOT copied.
        .EXAMPLE
        Nekta_CopyArchive -Files "C:\Temp\*" -Destination "C:\Temp2"
        Copies all files in the directory 'C:\Temp' to the destination directory 'C:\Temp2'. Subfolders as well as files within these subfolders are also copied.
        .EXAMPLE
        Nekta_CopyArchive -Files "C:\Temp\*.txt" -Destination "\\localhost\Temp2"
        Copies all files with the file extension '*.txt' in the directory 'C:\Temp' to the destination directory '\\localhost\Temp2'. The directory in this example is a network directory (UNC path).
    #>
    [CmdletBinding()]
    Param( 
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$Files,
        [Alias("D")]
        [Parameter(Mandatory = $true, Position = 1)][String]$Destination
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Copy the source file(s) '$Files' to '$Destination'" $LogFile
        # Retrieve the parent folder of the destination path
        if ( $Destination.Contains(".") ) {
            # In case the variable $Destination contains a dot ("."), return the parent folder of the path
            $TempFolder = split-path -path $Destination
        }
        else {
            $TempFolder = $Destination
        }

        # Check if the destination path exists. If not, create it.
        Nekta_Logging "INFO" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if ( Test-Path $TempFolder) {
            Nekta_Logging "INFO" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        }
        else {
            Nekta_Logging "INFO" "The destination path '$TempFolder' does not exist" $LogFile
            Nekta_NewDirectory -Directory $TempFolder
        }

        # Copy the source files
        Nekta_Logging "INFO" "Start copying the source file(s) '$Files' to '$Destination'" $LogFile
        try {
            Copy-Item $Files -Destination $Destination -Force -Recurse
            Nekta_Logging "SUCCESS" "Successfully copied the source files(s) '$Files' to '$Destination'" $LogFile
        }
        catch {
            Nekta_Logging "ERROR" "An error occurred trying to copy the source files(s) '$Files' to '$Destination'" $LogFile
            Exit 1
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_NewDirectory
#==========================================================================
Function Nekta_NewDirectory {
    <#
        .SYNOPSIS
        Create a new directory
        .DESCRIPTION
        Create a new directory
        .PARAMETER Directory
        This parameter contains the name of the new directory including the full path (for example C:\Temp\MyNewFolder).
        .EXAMPLE
        Nekta_NewDirectory -Directory "C:\Temp\MyNewFolder"
        Creates the new directory "C:\Temp\MyNewFolder"
    #>
    [CmdletBinding()]
    Param(
        [Alias("D")]
        [Parameter(Mandatory = $true, Position = 0)][String]$Directory
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Create directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            Nekta_Logging "INFO" "The directory $Directory already exists. Nothing to do" $LogFile
        }
        else {
            try {
                New-Item -ItemType Directory -Path $Directory -Force | Out-Null
                Nekta_Logging "SUCCESS" "Successfully created the directory $Directory" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to create the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_WipeDirectory
# Description: delete the entire directory
#==========================================================================
Function Nekta_WipeDirectory {
    <#
        .SYNOPSIS
        Delete a directory
        .DESCRIPTION
        Delete a directory
        .PARAMETER Directory
        This parameter contains the full path to the directory which needs to be deleted (for example C:\Temp\MyFolder).
        .EXAMPLE
        Nekta_WipeDirectory -Directory "C:\Temp\MyFolder"
        Deletes the directory "C:\Temp\MyFolder"
    #>
    [CmdletBinding()]
    Param( 
        [Alias("D")]
        [Parameter(Mandatory = $true, Position = 0)][String]$Directory
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Delete directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            try {
                Remove-Item $Directory -Force -Recurse | Out-Null
                Nekta_Logging "SUCCESS" "Successfully deleted the directory $Directory" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to delete the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "INFO" "The directory $Directory does not exist. Nothing to do" $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_DeleteFile
# Description: delete one specific file
#==========================================================================
Function Nekta_DeleteFile {
    <#
        .SYNOPSIS
        Delete a file
        .DESCRIPTION
        Delete a file
        .PARAMETER File
        This parameter contains the full path to the file (including the file name and file extension) that needs to be deleted (for example C:\Temp\MyFile.txt).
        .EXAMPLE
        Nekta_DeleteFile -File "C:\Temp\MyFile.txt"
        Deletes the file "C:\Temp\MyFile.txt"
        .EXAMPLE
        Nekta_DeleteFile -File "C:\Temp\*.txt"
        Deletes all files in the directory "C:\Temp" that have the file extension *.txt. *.txt files stored within subfolders of 'C:\Temp' are NOT deleted 
        .EXAMPLE
        Nekta_DeleteFile -File "C:\Temp\*.*"
        Deletes all files in the directory "C:\Temp". This function does NOT remove any subfolders nor files within a subfolder (use the function 'Nekta_PurgeFiles' instead)
    #>
    [CmdletBinding()]
    Param( 
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$File
    )
 
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Delete the file '$File'" $LogFile
        if ( Test-Path $File ) {
            try {
                Remove-Item "$File" | Out-Null
                Nekta_Logging "SUCCESS" "Successfully deleted the file '$File'" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to delete the file '$File' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "INFO" "The file '$File' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_MoveDirectory
#==========================================================================

Function Nekta_MoveDirectory {
    <#
        .SYNOPSIS
        Move one or more directories
        .DESCRIPTION
        Move one or more directories to a specified destination.
        .PARAMETER SourceDirectories
        Specifies the source directory(s) to move. Wildcards can be used, and UNC paths are supported.
        .PARAMETER Destination
        Specifies the destination path where the directory(s) should be moved. The path may include a new directory name.
        .EXAMPLE
        Nekta_MoveDirectory -SourceDirectories "C:\Temp\MyFolder" -Destination "C:\Temp2"
        Moves 'C:\Temp\MyFolder' to 'C:\Temp2'.
        .EXAMPLE
        Nekta_MoveDirectory -SourceDirectories "C:\Temp\MyFolder" -Destination "C:\Temp2\MyRenamedFolder"
        Moves 'C:\Temp\MyFolder' to 'C:\Temp2' and renames it to 'MyRenamedFolder'.
        .EXAMPLE
        Nekta_MoveDirectory -SourceDirectories "C:\Temp\*" -Destination "C:\Temp2"
        Moves all directories from 'C:\Temp' to 'C:\Temp2'.
    #>
    [CmdletBinding()]
    Param(
        [Alias("S")]
        [Parameter(Mandatory = $true, Position = 0)][String]$SourceDirectories,
        [Alias("D")]
        [Parameter(Mandatory = $true, Position = 1)][String]$Destination
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the source and destination details
        Nekta_Logging "INFO" "Move the source directory(s) '$SourceDirectories' to '$Destination'" $LogFile

        # Determine the destination directory
        if ($Destination.Contains(".")) {
            # If $Destination contains a dot, treat it as a path with a directory name
            $TempFolder = Split-Path -Path $Destination
        }
        else {
            # Otherwise, assume it's a directory path
            $TempFolder = $Destination
        }

        # Check if destination path exists; create it if it does not
        Nekta_Logging "INFO" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if (Test-Path $TempFolder) {
            Nekta_Logging "INFO" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        }
        else {
            Nekta_Logging "INFO" "The destination path '$TempFolder' does not exist" $LogFile
            Nekta_NewDirectory -Directory $TempFolder
        }

        # Move the source directories
        Nekta_Logging "INFO" "Start moving the source directory(s) '$SourceDirectories' to '$Destination'" $LogFile
        try {
            Move-Item -Path $SourceDirectories -Destination $Destination -Force
            Nekta_Logging "SUCCESS" "Successfully moved the source directory(s) '$SourceDirectories' to '$Destination'" $LogFile
        }
        catch {
            # Log the error if the move fails
            Nekta_Logging "ERROR" "An error occurred while moving the source directory(s) '$SourceDirectories' to '$Destination'. Error: $($_.Exception.Message)" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_RenameItem
#==========================================================================
Function Nekta_RenameItem {
    <#
        .SYNOPSIS
        Rename files and folders
        .DESCRIPTION
        Rename files and folders
        .PARAMETER ItemPath
        This parameter contains the full path to the file or folder that needs to be renamed (for example 'C:\Temp\MyOldFileName.txt' or 'C:\Temp\MyOldFolderName')
        .PARAMETER NewName
        This parameter contains the new name of the file or folder (for example 'MyNewFileName.txt' or 'MyNewFolderName')
        .EXAMPLE
        Nekta_RenameItem -ItemPath "C:\Temp\MyOldFileName.txt" -NewName "MyNewFileName.txt"
        Renames the file "C:\Temp\MyOldFileName.txt" to "MyNewFileName.txt". The parameter 'NewName' only requires the new file name without specifying the path to the file
        .EXAMPLE
        Nekta_RenameItem -ItemPath "C:\Temp\MyOldFileName.txt" -NewName "MyNewFileName.rtf"
        Renames the file "C:\Temp\MyOldFileName.txt" to "MyNewFileName.rtf". Besides changing the name of the file, the file extension is modified as well. Please make sure that the new file format is compatible with the original file format and can actually be opened after being renamed! The parameter 'NewName' only requires the new file name without specifying the path to the file
        .EXAMPLE
        Nekta_RenameItem -ItemPath "C:\Temp\MyOldFolderName" -NewName "MyNewFolderName"
        Renames the folder "C:\Temp\MyOldFolderName" to "C:\Temp\MyNewFolderName". The parameter 'NewName' only requires the new folder name without specifying the path to the folder
    #>
    [CmdletBinding()]
    Param( 
        [Alias("I")]
        [Parameter(Mandatory = $true, Position = 0)][String]$ItemPath,
        [Alias("N")]
        [Parameter(Mandatory = $true, Position = 1)][String]$NewName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Rename '$ItemPath' to '$NewName'" $LogFile

        # Rename the item (if exist)
        if ( Test-Path $ItemPath ) {
            try {
                Rename-Item -path $ItemPath -NewName $NewName | Out-Null
                Nekta_Logging "SUCCESS" "The item '$ItemPath' was renamed to '$NewName' successfully" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to rename the item '$ItemPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "INFO" "The item '$ItemPath' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ INSTALLATIONS AND EXECUTABLES                        #
#                                                                         #
###########################################################################

Function Nekta_RunProcess {
    <#
        .SYNOPSIS
        Execute a process
        .DESCRIPTION
        Execute a process
        .PARAMETER FileName
        This parameter contains the full path including the file name and file extension of the executable (for example C:\Temp\MyApp.exe).
        .PARAMETER Arguments
        This parameter contains the list of arguments to be executed together with the executable.
        .EXAMPLE
        Nekta_RunProcess -FileName "C:\Temp\MyApp.exe" -Arguments "-silent"
        Executes the file 'MyApp.exe' with arguments '-silent'
    #>
    [CmdletBinding()]
    Param( 
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$FileName,
        [Alias("A")]
        [Parameter(Mandatory = $false, Position = 1)][String]$Arguments
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        if ([string]::IsNullOrEmpty($Arguments)) {
            Nekta_Logging "INFO" "Execute process '$Filename' with no arguments" $LogFile

            if (-not (Test-Path $FileName)) {
                Nekta_Logging "ERROR" "Executable not found: '$FileName'" $LogFile
                Exit 1
            }

            $Process = Start-Process -FilePath $FileName -Wait -NoNewWindow -PassThru
        }
        else {
            Nekta_Logging "INFO" "Execute process '$Filename' with arguments '$Arguments'" $LogFile

            if (-not (Test-Path $FileName)) {
                Nekta_Logging "ERROR" "Executable not found: '$FileName'" $LogFile
                Exit 1
            }

            $Process = Start-Process -FilePath $FileName -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        }
                
        $ProcessExitCode = $Process.ExitCode
        if ($ProcessExitCode -eq 0) {
            Nekta_Logging "SUCCESS" "The process '$Filename' ended successfully" $LogFile
        }
        else {
            Nekta_Logging "ERROR" "An error occurred trying to execute the process '$Filename' (exit code: $ProcessExitCode)!" $LogFile
            Exit 1
        }
    }
 
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_RunProcessNoWait
#==========================================================================
Function Nekta_RunProcessNoWait {
    <#
        .SYNOPSIS
        Execute a process without wait 
        .DESCRIPTION
        Execute a process without wait
        .PARAMETER FileName
        This parameter contains the full path including the file name and file extension of the executable (for example C:\Temp\MyApp.exe).
        .PARAMETER Arguments
        This parameter contains the list of arguments to be executed together with the executable.
        .EXAMPLE
        Nekta_RunProcessNoWait -FileName "C:\Temp\MyApp.exe" -Arguments "-silent"
        Executes the file 'MyApp.exe' with arguments '-silent' with no wait to complete
    #>
    [CmdletBinding()]
    Param( 
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$FileName,
        [Alias("A")]
        [Parameter(Mandatory = $false, Position = 1)][String]$Arguments
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        try {
            if ([string]::IsNullOrEmpty($Arguments)) {
                Nekta_Logging "INFO" "Execute process '$FileName' with no arguments without wait." $LogFile

                if (-not (Test-Path $FileName)) {
                    Nekta_Logging "ERROR" "Executable not found: '$FileName'" $LogFile
                    Exit 1
                }

                Start-Process -FilePath $FileName -NoNewWindow -PassThru
            }
            else {
                Nekta_Logging "INFO" "Execute process '$FileName' with arguments '$Arguments' without wait." $LogFile

                if (-not (Test-Path $FileName)) {
                    Nekta_Logging "ERROR" "Executable not found: '$FileName'" $LogFile
                    Exit 1
                }
                
                Start-Process -FilePath $FileName -ArgumentList $Arguments -NoNewWindow -PassThru
            }

            Nekta_Logging "SUCCESS" "The process '$FileName' was started successfully." $LogFile
        }
        catch {
            Nekta_Logging "ERROR" "Failed to start process '$FileName'. Exception: $_" $LogFile
            Exit 1
        }
    }
 
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

###########################################################################
#                                                                         #
#          WINDOWS \ LOGGING                                              #
#                                                                         #
###########################################################################

#==========================================================================

# FUNCTION Nekta_Logging
#==========================================================================
Function Nekta_Logging {
    <#
        .SYNOPSIS
        Write text to this script's log file
        .DESCRIPTION
        Write text to this script's log file
        .PARAMETER InformationType
        This parameter contains the information type prefix. Possible prefixes and information types are:
            I = Information
            S = Success
            W = Warning
            E = Error
            - = No status
        .PARAMETER Text
        This parameter contains the text (the line) you want to write to the log file. If text in the parameter is omitted, an empty line is written.
        .PARAMETER LogFile
        This parameter contains the full path, the file name and file extension to the log file (e.g. C:\Logs\MyApps\MylogFile.log)
        .EXAMPLE
        Nekta_Logging -InformationType "I" -Text "Copy files to C:\Temp" -LogFile "C:\Logs\MylogFile.log"
        Writes a line containing information to the log file
        .Example
        Nekta_Logging -InformationType "E" -Text "An error occurred trying to copy files to C:\Temp (error: $($Error[0]))!" -LogFile "C:\Logs\MylogFile.log"
        Writes a line containing error information to the log file
        .Example
        Nekta_Logging -InformationType "-" -Text "" -LogFile "C:\Logs\MylogFile.log"
        Writes an empty line to the log file
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "TRACE", "I", "S", "W", "E", "T", IgnoreCase = $True)][String]$InformationType,
        [Parameter(Mandatory = $true, Position = 1)][AllowEmptyString()][String]$Text,
        [Parameter(Mandatory = $false, Position = 2)][String]$LogFile
    )
 
    begin {
    }
 
    process {
        # Create new log file if it doesn't exist
        if (!(Test-Path $LogFile)) {    
            New-Item $LogFile -ItemType File -Force | Out-Null
        }

        $DateTime = (Get-Date -format "dd-MM-yyyy HH:mm:ss")

        # Pad the InformationType to align with the longest type (e.g., WARNING)
        $FormattedType = ($InformationType.ToUpper()).PadRight(7) # Adjust length to 8 (length of 'WARNING')

        if ($Text -eq "") {
            Add-Content $LogFile -value ("") # Write an empty line
        }
        else {
            # Write formatted entry to log file
            $LogEntry = "$DateTime $FormattedType :....$Text"
            Add-Content $LogFile -value $LogEntry
        }
        
        # Display formatted output to the console with colors
        switch ($InformationType.ToUpper()) {
            "I" { Write-Host "$FormattedType :....$Text" -ForegroundColor Yellow }
            "INFO" { Write-Host "$FormattedType :....$Text" -ForegroundColor Yellow }
            "E" { Write-Host "$FormattedType :....$Text" -ForegroundColor Red }
            "ERROR" { Write-Host "$FormattedType :....$Text" -ForegroundColor Red }
            "S" { Write-Host "$FormattedType :....$Text" -ForegroundColor Green }
            "SUCCESS" { Write-Host "$FormattedType :....$Text" -ForegroundColor Green }
            "W" { Write-Host "$FormattedType :....$Text" -ForegroundColor Blue }
            "WARNING" { Write-Host "$FormattedType :....$Text" -ForegroundColor Blue }
            "T" { Write-Host "$FormattedType :....$Text" }
            "TRACE" { Write-Host "$FormattedType :....$Text" }
        }
    }
 
    end {
    }
}

###########################################################################
#                                                                         #
#          WINDOWS \ REGISTRY                                             #
#                                                                         #
###########################################################################

# FUNCTION Nekta_NewRegKey
#==========================================================================
Function Nekta_NewRegKey {
    <#
        .SYNOPSIS
        Create a registry key
        .DESCRIPTION
        Create a registry key
        .PARAMETER RegKeyPath
        This parameter contains the registry path, for example 'hklm:\Software\MyApp'
        .EXAMPLE
        Nekta_NewRegKey -RegKeyPath "hklm:\Software\MyApp"
        Creates the new registry key 'hklm:\Software\MyApp'
    #>
    [CmdletBinding()]
    Param( 
        [Alias("K")]
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Create registry key '$RegKeyPath'" $LogFile
        if ( Test-Path $RegKeyPath ) {
            Nekta_Logging "INFO" "The registry key '$RegKeyPath' already exists. Nothing to do" $LogFile
        }
        else {
            try {
                New-Item -Path $RegkeyPath -Force | Out-Null
                Nekta_Logging "SUCCESS" "The registry key '$RegKeyPath' was created successfully" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to create the registry key '$RegKeyPath' (exit code: $($Error[0]))!" $LogFile
                Nekta_Logging "INFO" "Note: define the registry path as follows: hklm:\Software\MyApp" $LogFile
                Exit 1
            }
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_DeleteRegKeyValue
#==========================================================================
Function Nekta_DeleteRegKeyValue {
    <#
        .SYNOPSIS
        Delete a registry value. This can be a value of any type (e.g. REG_SZ, DWORD, etc.)
        .DESCRIPTION
        Delete a registry value. This can be a value of any type (e.g. REG_SZ, DWORD, etc.)
        .PARAMETER RegKeyPath
        This parameter contains the registry path (for example hklm:\SOFTWARE\MyApp)
        .PARAMETER RegValueName
        This parameter contains the name of the registry value that is to be deleted (for example 'MyValue')
        .EXAMPLE
        Nekta_DeleteRegKeyValue -RegKeyPath "hklm:\SOFTWARE\MyApp" -RegValueName "MyValue"
        Deletes the registry value 'MyValue' from the registry key 'hklm:\SOFTWARE\MyApp'
    #>
    [CmdletBinding()]
    Param( 
        [Alias("K")]
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Alias("N")]
        [Parameter(Mandatory = $true, Position = 1)][String]$RegValueName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Delete registry value '$RegValueName' in '$RegKeyPath'" $LogFile

        # Check if the registry value that is to be renamed actually exists
        $RegValueExists = $False
        try {
            Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty $RegValueName | Out-Null
            $RegValueExists = $True
        }
        catch {
            Nekta_Logging "INFO" "The registry value '$RegValueName' in the registry key '$RegKeyPath' does NOT exist. Nothing to do" $LogFile
        }

        # Delete the registry value (if exist)
        if ( $RegValueExists -eq $True ) {
            try {
                Remove-ItemProperty -Path $RegKeyPath -Name $RegValueName | Out-Null
                Nekta_Logging "SUCCESS" "The registry value '$RegValueName' in the registry key '$RegKeyPath' was deleted successfully" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to delete the registry value '$RegValueName' in the registry key '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Nekta_Logging "INFO" "Note: define the registry path as follows: hklm:\SOFTWARE\MyApp" $LogFile
                Exit 1
            }
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION ImportRegFile
#==========================================================================
Function Nekta_ImportRegFile {
    <#
        .SYNOPSIS
        Import a registry (*.reg) file into the registry
        .DESCRIPTION
        Import a registry (*.reg) file into the registry
        .PARAMETER FileName
        This parameter contains the full path, file name and file extension of the registry file, for example "C:\Temp\MyRegFile.reg"
        .EXAMPLE
        Nekta_ImportRegFile-FileName "C:\Temp\MyRegFile.reg"
        Imports registry settings from the file "C:\Temp\MyRegFile.reg"
    #>
    [CmdletBinding()]
    Param( 
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$FileName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Import registry file '$FileName'" $LogFile
        if ( Test-Path $FileName ) {
            try {
                $process = start-process -FilePath "reg.exe" -ArgumentList "IMPORT ""$FileName""" -WindowStyle Hidden -Wait -PassThru
                if ( $process.ExitCode -eq 0 ) {
                    Nekta_Logging "SUCCESS" "The registry settings were imported successfully (exit code: $($process.ExitCode))" $LogFile
                }
                else {
                    Nekta_Logging "ERROR" "An error occurred trying to import registry settings (exit code: $($process.ExitCode))" $LogFile				
                    Exit 1
                }
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to import the registry file '$FileName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "ERROR" "The file '$FileName' does NOT exist!" $LogFile
            Exit 1
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_RenameRegKey
#==========================================================================
Function Nekta_RenameRegKey {
    <#
        .SYNOPSIS
        Rename a registry key (for registry values use the function 'Nekta_RenameRegKeyValue' instead)
        .DESCRIPTION
        Rename a registry key (for registry values use the function 'Nekta_RenameRegKeyValue' instead)
        .PARAMETER RegKeyPath
        This parameter contains the registry path that needs to be renamed (for example 'hklm:\Software\MyRegKey')
        .PARAMETER NewName
        This parameter contains the new name of the last part of the registry path that is to be renamed (for example 'MyRegKeyNew')
        .EXAMPLE
        Nekta_RenameRegKey -RegKeyPath "hklm:\Software\MyRegKey" -NewName "MyRegKeyNew"
        Renames the registry path "hklm:\Software\MyRegKey" to "hklm:\Software\MyRegKeyNew". The parameter 'NewName' only requires the last part of the registry path without specifying the entire registry path
    #>
    [CmdletBinding()]
    Param( 
        [Alias("K")]
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Alias("N")]
        [Parameter(Mandatory = $true, Position = 1)][String]$NewName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Rename '$RegKeyPath' to '$NewName'" $LogFile

        # Rename the registry path (if exist)
        if ( Test-Path $RegKeyPath ) {
            try {
                Rename-Item -path $RegKeyPath -NewName $NewName | Out-Null
                Nekta_Logging "SUCCESS" "The registry path '$RegKeyPath' was renamed to '$NewName' successfully" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to rename the registry path '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Nekta_Logging "INFO" "Note: define the registry path as follows: hklm:\SOFTWARE\MyApp" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "INFO" "The registry path '$RegKeyPath' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_RenameRegKeyValue
# Note: this function works for registry values only. To rename a registry key, use the function 'Nekta_RenameRegKey'.
#==========================================================================
Function Nekta_RenameRegKeyValue {
    <#
        .SYNOPSIS
        Rename a registry value (all data types). To rename a registry key, use the function 'Nekta_RenameRegKey'
        .DESCRIPTION
        Rename a registry value (all data types). To rename a registry key, use the function 'Nekta_RenameRegKey'
        .PARAMETER RegKeyPath
        This parameter contains the full registry path (for example 'hklm:\SOFTWARE\MyApp')
        .PARAMETER RegValueName
        This parameter contains the name of the registry value that needs to be renamed (for example 'MyRegistryValue')
        .PARAMETER NewName
        This parameter contains the new name of the registry value that is to be renamed (for example 'MyRegistryValueNewName')
        .EXAMPLE
        Nekta_RenameRegKeyValue -RegKeyPath "hklm:\Software\MyRegKey" -RegValueName "MyRegistryValue" -NewName "MyRegistryValueNewName"
        Renames the registry value 'MyRegistryValue' in the registry key "hklm:\Software\MyRegKey" to 'MyRegistryValueNewName'
    #>
    [CmdletBinding()]
    Param( 
        [Alias("K")]
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Alias("V")]
        [Parameter(Mandatory = $true, Position = 1)][String]$RegValueName,
        [Alias("N")]
        [Parameter(Mandatory = $true, Position = 2)][String]$NewName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Rename the registry value '$RegValueName' in the registry key '$RegKeyPath' to '$NewName'" $LogFile

        # Check if the registry value that is to be renamed actually exists
        $RegValueExists = $False
        try {
            Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty $RegValueName | Out-Null
            $RegValueExists = $True
        }
        catch {
            Nekta_Logging "INFO" "The registry value '$RegValueName' in the registry key '$RegKeyPath' does NOT exist. Nothing to do" $LogFile
        }

        # Rename the registry value (if exist)
        if ( $RegValueExists -eq $True ) {
            try {
                Rename-ItemProperty -Path $RegKeyPath -Name $RegValueName -NewName $NewName | Out-Null
                Nekta_Logging "SUCCESS" "The registry value '$RegValueName' in the registry key '$RegKeyPath' was successfully renamed to '$NewName'" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to rename the registry value '$RegValueName' in the registry key '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_SetRegKeyValue
#==========================================================================
Function Nekta_SetRegKeyValue {
    <#
        .SYNOPSIS
        Set a registry value
        .DESCRIPTION
        Set a registry value
        .PARAMETER RegKeyPath
        This parameter contains the registry path, for example 'hklm:\Software\MyApp'
        .PARAMETER RegValueName
        This parameter contains the name of the new registry value, for example 'MyValue'
        .PARAMETER RegValue
        This parameter contains the value of the new registry entry, for example '1'
        .PARAMETER Type
        This parameter contains the type. Possible options are: String | Binary | DWORD | QWORD | MultiString | ExpandString
        .EXAMPLE
        Nekta_SetRegKeyValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyStringValue" -RegValue "Enabled" -Type "String"
        Creates a new string value called 'MyStringValue' with the value of 'Enabled'
        .Example
        Nekta_SetRegKeyValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyBinaryValue" -RegValue "01" -Type "Binary"
        Creates a new binary value called 'MyBinaryValue' with the value of '01'
        .Example
        Nekta_SetRegKeyValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyDWORDValue" -RegValue "1" -Type "DWORD"
        Creates a new DWORD value called 'MyDWORDValue' with the value of 00000001 (or simply 1)
        .Example
        Nekta_SetRegKeyValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyQWORDValue" -RegValue "1" -Type "QWORD"
        Creates a new QWORD value called 'MyQWORDValue' with the value of 1
        .Example
        Nekta_SetRegKeyValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyMultiStringValue" -RegValue "Value1","Value2","Value3" -Type "MultiString"
        Creates a new multistring value called 'MyMultiStringValue' with the value of 'Value1 Value2 Value3'
        .Example
        Nekta_SetRegKeyValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyExpandStringValue" -RegValue "MyValue" -Type "ExpandString"
        Creates a new expandstring value called 'MyExpandStringValue' with the value of 'MyValue'
    #>
    [CmdletBinding()]
    Param( 
        [Alias("K")]
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Alias("V")]
        [Parameter(Mandatory = $true, Position = 1)][String]$RegValueName,
        [Alias("KV")]
        [Parameter(Mandatory = $false, Position = 2)][String[]]$RegValue = "",
        [Alias("T")]
        [Parameter(Mandatory = $true, Position = 3)][String]$Type
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Set registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath" $LogFile

        # Create the registry key in case it does not exist
        if ( !( Test-Path $RegKeyPath ) ) {
            Nekta_NewRegKey $RegKeyPath
        }
    
        # Create the registry value
        try {
            if ( ( "String", "ExpandString", "DWord", "QWord" ) -contains $Type ) {
                New-ItemProperty -Path $RegKeyPath -Name $RegValueName -Value $RegValue[0] -PropertyType $Type -Force | Out-Null
            }
            else {
                New-ItemProperty -Path $RegKeyPath -Name $RegValueName -Value $RegValue -PropertyType $Type -Force | Out-Null
            }
            Nekta_Logging "SUCCESS" "The registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath was set successfully" $LogFile
        }
        catch {
            Nekta_Logging "ERROR" "An error occurred trying to set the registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath" $LogFile
            Nekta_Logging "INFO" "Note: define the registry path as follows: hklm:\Software\MyApp" $LogFile
            Exit 1
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ SERVICES                                             #
#                                                                         #
###########################################################################

# FUNCTION Nekta_ModifyStartupService
# Note: set/change the startup type of a service. Posstible options are: Boot, System, Automatic, Manual and Disabled
#==========================================================================
Function Nekta_ModifyStartupService {
    <#
        .SYNOPSIS
        Change the startup type of a service
        .DESCRIPTION
        Change the startup type of a service
        .PARAMETER ServiceName
        This parameter contains the name of the service (not the display name!) to stop, for example 'Spooler' or 'TermService'. Depend services are stopped automatically as well.
        .PARAMETER StartupType
        This parameter contains the required startup type of the service. Possible values are: Boot | System | Automatic | Manual | Disabled
        .EXAMPLE
        Nekta_ModifyStartupService -ServiceName "Spooler" -StartupType "Disabled"
        Disables the service 'Spooler' (display name: 'Print Spooler')
        .EXAMPLE
        Nekta_ModifyStartupService -ServiceName "Spooler" -StartupType "Manual"
        Sets the startup type of the service 'Spooler' to 'manual' (display name: 'Print Spooler')
    #>
    [CmdletBinding()]
    Param( 
        [Alias("S")]
        [Parameter(Mandatory = $true, Position = 0)][String]$ServiceName,
        [Alias("T")]
        [Parameter(Mandatory = $true, Position = 1)][String]$StartupType
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Change the startup type of the service '$ServiceName' to '$StartupType'" $LogFile

        # Check if the service exists    
        If ( Get-Service $ServiceName -erroraction silentlycontinue) {
            # Change the startup type
            try {
                Set-Service -Name $ServiceName -StartupType $StartupType | Out-Null
                Nekta_Logging "INFO" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            Nekta_Logging "INFO" "The service '$ServiceName' does not exist. Nothing to do" $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_StopService
#==========================================================================
Function Nekta_StopService {
    <#
        .SYNOPSIS
        Stop a service (including depend services)
        .DESCRIPTION
        Stop a service (including depend services)
        .PARAMETER ServiceName
        This parameter contains the name of the service (not the display name!) to stop, for example 'Spooler' or 'TermService'. Depend services are stopped automatically as well.
        Depend services do not need to be specified separately. The function will retrieve them automatically.
        .EXAMPLE
        Nekta_StopService -ServiceName "Spooler"
        Stops the service 'Spooler' (display name: 'Print Spooler')
    #>
    [CmdletBinding()]
    Param( 
        [Alias("S")]
        [Parameter(Mandatory = $true, Position = 0)][String]$ServiceName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Stop service '$ServiceName' ..." $LogFile

        # Check if the service exists    
        If ( Get-Service $ServiceName -erroraction silentlycontinue) {
            # Stop the main service 
            If ( ((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
        
                # Check for depend services and stop them first
                Nekta_Logging "INFO" "Check for depend services for service '$ServiceName' and stop them" $LogFile
                $DependServices = (( Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).DependentServices).name

                If ($DependServices.Count -gt 0 ) {
                    foreach ($Service in $DependServices) {
                        Nekta_Logging "INFO" "Depend service found: $Service" $LogFile
                        Nekta_StopService -ServiceName $Service
                    }
                }
                else {
                    Nekta_Logging "INFO" "No depend service found" $LogFile
                }

                # Stop the (depend) service
                try {
                    Stop-Service $ServiceName | Out-Null
                }
                catch {
                    Nekta_Logging "ERROR" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Check if the service stopped successfully
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Stopped" ) {
                    Nekta_Logging "INFO" "The service $ServiceName was stopped successfully" $LogFile
                }
                else {
                    Nekta_Logging "ERROR" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            }
            else {
                Nekta_Logging "INFO" "The service '$ServiceName' is not running" $LogFile
            }
        }
        else {
            Nekta_Logging "INFO" "The service '$ServiceName' does not exist. Nothing to do" $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION Nekta_StartingService 
#==========================================================================
Function Nekta_StartingService {
    <#
        .SYNOPSIS
        Starts a service (including depend services)
        .DESCRIPTION
        Starts a service (including depend services)
        .PARAMETER ServiceName
        This parameter contains the name of the service (not the display name!) to start, for example 'Spooler' or 'TermService'. Depend services are started automatically as well.
        Depend services do not need to be specified separately. The function will retrieve them automatically.
        .EXAMPLE
        Nekta_StartingService -ServiceName "Spooler"
        Starts the service 'Spooler' (display name: 'Print Spooler')
    #>
    [CmdletBinding()]
    Param( 
        [Alias("S")]
        [Parameter(Mandatory = $true, Position = 0)][String]$ServiceName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        Nekta_Logging "INFO" "Start service $ServiceName ..." $LogFile

        # Check if the service exists    
        If ( Get-Service $ServiceName -erroraction silentlycontinue) {
            # Start the main service 
            If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                Nekta_Logging "INFO" "The service $ServiceName is already running" $LogFile
            }
            else {
                # Check for depend services and start them first
                Nekta_Logging "INFO" "Check for depend services for service $ServiceName and start them" $LogFile
                $DependServices = ( ( Get-Service -Name $ServiceName -ErrorAction SilentlyContinue ).DependentServices ).name

                If ( $DependServices.Count -gt 0 ) {
                    foreach ( $Service in $DependServices ) {
                        Nekta_Logging "INFO" "Depend service found: $Service" $LogFile
                        StartService($Service)
                    }
                }
                else {
                    Nekta_Logging "INFO" "No depend service found" $LogFile
                }

                # Start the (depend) service
                try {
                    Start-Service $ServiceName | Out-Null
                }
                catch {
                    Nekta_Logging "ERROR" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Check if the service started successfully
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                    Nekta_Logging "INFO" "The service $ServiceName was started successfully" $LogFile
                }
                else {
                    Nekta_Logging "ERROR" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            }
        }
        else {
            Nekta_Logging "INFO" "The service $ServiceName does not exist. Nothing to do" $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ SYSTEM                                               #
#                                                                         #
###########################################################################

#==========================================================================

# FUNCTION Nekta_WipePrefetch
#==========================================================================
Function Nekta_WipePrefetch {
    <#
        .SYNOPSIS
        Clear all files from the Windows Prefetch folder.
        .DESCRIPTION
        This function deletes all files in the Windows Prefetch folder without removing the folder itself.
        .EXAMPLE
        Nekta_WipePrefetch
        Clears all files in the Prefetch folder.
    #>
    [CmdletBinding()]
    Param()

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
        $PrefetchFolder = "C:\Windows\Prefetch"
        Nekta_Logging "INFO" "Target folder: $PrefetchFolder" $LogFile
    }

    process {
        # Check if the Prefetch folder exists
        if (!(Test-Path $PrefetchFolder)) {
            Nekta_Logging "ERROR" "The Prefetch folder does not exist at the path: $PrefetchFolder" $LogFile
            Exit 1
        }

        # Get all files in the Prefetch folder
        $Files = Get-ChildItem -Path $PrefetchFolder -File

        # Delete each file
        if ($Files.Count -gt 0) {
            Nekta_Logging "INFO" "Found $($Files.Count) files to delete" $LogFile
            foreach ($File in $Files) {
                try {
                    Remove-Item -Path $File.FullName -Force
                    Nekta_Logging "SUCCESS" "Deleted file: $($File.FullName)" $LogFile
                }
                catch {
                    Nekta_Logging "ERROR" "Failed to delete file: $($File.FullName). Error: $_" $LogFile
                }
            }
        }
        else {
            Nekta_Logging "INFO" "No files found in the Prefetch folder" $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_StartStopProcess
#==========================================================================
Function Nekta_StartStopProcess {
    <#
        .SYNOPSIS
        Start or stop a process.
        .DESCRIPTION
        This function starts or stops a specified process based on the given action.
        .PARAMETER ProcessName
        The name of the process to start or stop.
        .PARAMETER Action
        Defines whether to 'Start' or 'Stop' the process.
        .EXAMPLE
        Nekta_StartStopProcess -ProcessName "notepad" -Action "Start"
        Starts the notepad process.
        .EXAMPLE
        Nekta_StartStopProcess -ProcessName "notepad" -Action "Stop"
        Stops the notepad process.
    #>
    [CmdletBinding()]
    param (
        [Alias("P")]
        [Parameter(Mandatory = $true)][string]$ProcessName,
        [Alias("A")]
        [Parameter(Mandatory = $true)][ValidateSet('Start', 'Stop')][string]$Action
    )

    begin {
        # Start function logging
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
        Nekta_Logging "INFO" "Process Name: $ProcessName" $LogFile
        Nekta_Logging "INFO" "Action: $Action" $LogFile
    }

    process {
        try {
            if ($Action -eq "Start") {
                # Start the process
                Nekta_Logging "INFO" "Starting process $ProcessName" $LogFile
                Start-Process -FilePath $ProcessName -ErrorAction Stop
                Nekta_Logging "SUCCESS" "Process $ProcessName started successfully." $LogFile
            }
            elseif ($Action -eq "Stop") {
                # Stop the process
                $Process = Get-Process -Name $ProcessName -ErrorAction Stop
                if ($Process) {
                    Nekta_Logging "INFO" "Stopping process $ProcessName" $LogFile
                    Stop-Process -Name $ProcessName -Force -ErrorAction Stop
                    Nekta_Logging "SUCCESS" "Process $ProcessName stopped successfully." $LogFile
                }
            }
        }
        catch {
            Nekta_Logging "ERROR" "Error during $Action of process $ProcessName. Error: $_" $LogFile
            throw
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_ResolvePath
#==========================================================================

Function Nekta_ResolvePath {
    <#
        .SYNOPSIS
        Resolves a given path (Path or LiteralPath) and checks if it exists.
        .DESCRIPTION
        This function resolves a given file or directory path using Resolve-Path. It can take either a regular path or a literal path.
        .PARAMETER Path
        The path to be resolved and checked. This is a regular path where characters like wildcards (*) are interpreted.
        .PARAMETER LiteralPath
        A literal path to be resolved and checked, where characters like wildcards (*) are treated as literal characters.
        .EXAMPLE
        Nekta_ResolvePath -Path "C:\Temp\MyFile.txt"
        Checks if "C:\Temp\MyFile.txt" exists and returns the resolved path if it does.
        .EXAMPLE
        Nekta_ResolvePath -LiteralPath "C:\Path[With]SpecialChars"
        Checks if "C:\Path[With]SpecialChars" exists and returns the resolved path if it does.
    #>
    [CmdletBinding()]
    Param(
        [Alias("P")]
        [Parameter(ParameterSetName = "Path", Mandatory = $true, Position = 0)]
        [String]$Path,

        [Alias("LP")]
        [Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, Position = 0)]
        [String]$LiteralPath
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Resolves the path based on the parameter set
        try {
            if ($PSCmdlet.ParameterSetName -eq "Path") {
                Nekta_Logging "INFO" "Resolving path '$Path'" $LogFile
                $ResolvedPath = Resolve-Path -Path $Path -ErrorAction Stop
            }
            elseif ($PSCmdlet.ParameterSetName -eq "LiteralPath") {
                Nekta_Logging "INFO" "Resolving literal path '$LiteralPath'" $LogFile
                $ResolvedPath = Resolve-Path -LiteralPath $LiteralPath -ErrorAction Stop
            }

            Nekta_Logging "SUCCESS" "The resolved path is '$ResolvedPath'" $LogFile            
        }
        catch {
            Nekta_Logging "WARNING" "The specified path could not be resolved." $LogFile
           
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}


#==========================================================================
#
# FUNCTION Nekta_GetFilename
#==========================================================================
Function Nekta_GetFilename {
    <#
        .SYNOPSIS
        Get the name of any file.
        .DESCRIPTION
        This function get the name of any file.
        .PARAMETER File
        The file to be checked.
        .EXAMPLE
        Nekta_GetFileName -File "C:\Temp\MyFile.txt"
        Returns: The name of file: MyFile.txt.
    #>
    [CmdletBinding()]
    Param(
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$File
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        Nekta_Logging "INFO" "Getting name from file '$File'" $LogFile
        $fileName = [System.IO.Path]::GetFileName($File)
        return $fileName

        if ($fileName) {
            Nekta_Logging "SUCCESS" "The name of file: '$filename'." $LogFile
        }
        else {
            Nekta_Logging "WARNING" "The file '$fileName' does not exist." $LogFile
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}



#==========================================================================

# FUNCTION Nekta_MSIInstall 
#==========================================================================

Function Nekta_MSIInstall {
    <#
        .SYNOPSIS
        Installs an MSI package
        .DESCRIPTION
        Installs an MSI package with a default silent mode. If additional arguments are passed, they will be combined with the silent installation options.
        .PARAMETER MSIPath
        The full path to the MSI package.
        .PARAMETER AdditionalArguments
        Additional arguments for the MSI installation. By default, uses silent installation arguments.
        .EXAMPLE
        Nekta_MSIInstall -File "C:\Path\To\Installer.msi"
        Installs the MSI package silently.
        .EXAMPLE
        Nekta_MSIInstall -File "C:\Path\To\Installer.msi" -AdditionalArguments "/norestart"
        Installs the MSI package silently with additional arguments to prevent restart.
    #>
    [CmdletBinding()]
    Param(
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$File,                
        [Alias("A")]
        [Parameter(Mandatory = $false, Position = 1)]
        [String]$AdditionalArguments
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }
    
    process {
        $FileName = ($File.Split("\"))[-1]
        $FileExt = $FileName.SubString(($FileName.Length) - 3, 3)        
        $InstallType = "Install"

        $logInstall = Join-path $LogDir ("$($InstallType)_$($FileName.Substring(0,($FileName.Length)-4))_$($FileExt).log")

        # Logging        
        Nekta_Logging "INFO" "File name: $FileName" $LogFile
        Nekta_Logging "INFO" "File full path: $File" $LogFile
 
        # Check if the installation file exists
        if (!(Test-Path -Path $File)) {    
            Nekta_Logging "ERROR" "The file '$File' does not exist!" $LogFile
            Exit 1
        }
         
        # Install the MSI          
        Nekta_Logging "INFO" "Start the installation" $LogFile
        
        # Define silent installation arguments
        $DefaultArguments = "/quiet /norestart /l*v ""$logInstall"""
        
        # Combine default arguments with any additional arguments provided
        if ([string]::IsNullOrEmpty($AdditionalArguments)) {
            $FinalArguments = $DefaultArguments
            Nekta_Logging "INFO" "Installin of '$File' with default arguments '$FinalArguments'" $LogFile
        }
        else {
            $FinalArguments = "$DefaultArguments $AdditionalArguments"
            Nekta_Logging "INFO" "Installing '$File' with combined arguments '$FinalArguments'" $LogFile
        }

        # Run the MSI installation      
        $Process = Start-Process "msiexec.exe" -ArgumentList "/i `"$File`" $FinalArguments" -Wait -NoNewWindow -PassThru

        # Check exit code
        $ProcessExitCode = $Process.ExitCode
        switch ($ProcessExitCode) {        
            0 { Nekta_Logging "SUCCESS" "The software was installed successfully (exit code: 0)" $LogFile }
            3 { Nekta_Logging "SUCCESS" "The software was installed successfully (exit code: 3)" $LogFile }
            1603 { Nekta_Logging "ERROR" "A fatal error occurred (exit code: 1603). Some applications throw this error when the software is already (correctly) installed! Please check." $LogFile }
            1605 { Nekta_Logging "INFO" "The software is not currently installed on this machine (exit code: 1605)" $LogFile }
            1619 { 
                Nekta_Logging "ERROR" "The installation files cannot be found. The PS1 script should be in the root directory and all source files in the subdirectory 'Files' (exit code: 1619)" $LogFile 
                Exit 1
            }
            3010 { Nekta_Logging "WARNING" "A reboot is required (exit code: 3010)!" $LogFile }
            default { 
                Nekta_Logging "ERROR" "The installation ended in an error (exit code: $ProcessExitCode)!" $LogFile
                Exit 1
            }
        }        
    }
    
    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_SetupInstall
#==========================================================================

Function Nekta_SetupInstall {
    <#
        .SYNOPSIS
        Execute an EXE file with or without arguments.
        .DESCRIPTION
        Executes an EXE file with or without provided arguments.
        .PARAMETER EXEPath
        The full path to the executable file (e.g., C:\Temp\MyApp.exe).
        .PARAMETER Arguments
        Optional arguments to pass to the executable.
        .EXAMPLE
        Nekta_SetupInstall -File "C:\Temp\MyApp.exe" -Arguments "/silent /install"
        Executes 'MyApp.exe' with the specified arguments.
    #>
    [CmdletBinding()]
    Param( 
        [Alias("F")]
        [Parameter(Mandatory = $true, Position = 0)][String]$File,
        [Alias("A")]
        [Parameter(Mandatory = $false, Position = 1)][String]$Arguments
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        $FileName = ($File.Split("\"))[-1]

        # Logging        
        Nekta_Logging "INFO" "File name: $FileName" $LogFile
        Nekta_Logging "INFO" "File full path: $File" $LogFile
 
        # Check if the installation file exists
        if (!(Test-Path -Path $File)) {    
            Nekta_Logging "ERROR" "The file '$File' does not exist!" $LogFile
            Exit 1
        }
         
        # Install the MSI          
        Nekta_Logging "INFO" "Start the installation" $LogFile
        
        if ([string]::IsNullOrEmpty($Arguments)) {
            Nekta_Logging "INFO" "Installing '$File' with no arguments" $LogFile
            $Process = Start-Process -FilePath $File -Wait -NoNewWindow -PassThru
        }
        else {
            Nekta_Logging "INFO" "Installing '$File' with arguments '$Arguments'" $LogFile
            $Process = Start-Process -FilePath $File -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        }

        # Checking if the process exited successfully
        $ProcessExitCode = $Process.ExitCode
        if ($ProcessExitCode -eq 0) {
            Nekta_Logging "SUCCESS" "The process '$File' completed successfully" $LogFile
        }
        else {
            Nekta_Logging "ERROR" "An error occurred while executing '$File' (exit code: $ProcessExitCode)!" $LogFile
            Exit 1
        }
    }

    end {
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }    
}

#==========================================================================

# FUNCTION Nekta_ISOSetupInstall
#==========================================================================
Function Nekta_ISOSetupInstall {
    <#
        .SYNOPSIS
        Execute an EXE file located on a ISO image, with or without arguments.
        .DESCRIPTION
        Executes an EXE file located on a ISO image, with or without provided arguments.
        .PARAMETER ISO
        The full path to the ISO imae (e.g. C:\Temp\MyApp.iso)
        .PARAMETER EXEName
        The full name to the executable file (e.g., MyApp.exe).
        .PARAMETER ExeArgs
        Optional arguments to pass to the executable.
        .EXAMPLE
        Nekta_ISOSetupInstall -ISO "C:\Temp\MyApp.iso" -ExeName "MyApp.exe" -ExeArgs "/silent /install"
        Executes 'MyApp.exe' located on a iso image, with the specified arguments 
    #>
    param (
        [parameter(Mandatory = $True)]
        [Alias("I")]
        [string] $ISO,  
        [parameter(Mandatory = $True)]
        [Alias("N")]
        [string] $ExeName,  		
        [Alias("A")]
        [parameter(Mandatory = $False)]
        [string] $ExeArgs = ""
    )

    Nekta_Logging "INFO" "Mounting $ISO." $LogFile
    Mount-DiskImage -ImagePath $ISO -ErrorAction Stop
    Nekta_Logging "SUCCESS" "$ISO mounted successfully" $LogFile

    $driveLetter = (Get-DiskImage $ISO | Get-Volume).DriveLetter   

    if ($driveLetter) {
        $exeFullPath = "$($driveLetter):\$ExeName"      
       
        if (Test-Path -Path $exeFullPath) {
            if ([string]::IsNullOrEmpty($ExeArgs)) {
                Start-Process -FilePath $exeFullPath -Wait -NoNewWindow -PassThru                
            }
            else {
                Start-Process -FilePath $exeFullPath -ArgumentList $ExeArgs -Wait -NoNewWindow -PassThru
            }
        }
        else {
            Nekta_Logging "ERROR" "The file '$exeFullPath' don't exists." $LogFile
        }
    }
    else {
        Nekta_Logging "ERROR" "Unable to determine the drive letter of the ISO image." $LogFile
    }
    
    Nekta_Logging "INFO" "Unmounting $ISO." $LogFile
    Dismount-DiskImage -ImagePath $ISO -ErrorAction Stop   
    Nekta_Logging "SUCCESS" "Unmounting $ISO successfully." $LogFile
}

#=========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ DOWNLOADERS                                          #
#                                                                         #
###########################################################################

#==========================================================================

# FUNCTION Nekta_ResolveUrl
#==========================================================================
Function Nekta_ResolveUrl {
    <#
        .SYNOPSIS
        Nekta_ResolveUrl resolves a URI and retrieves information such as file size, last modified date, and filename.
        .DESCRIPTION
        The Nekta_ResolveUrl function resolves the given URI and retrieves information such as file size, last modified date, and filename. It sends a GET request to the URL and retrieves the headers to extract the required information.
        .PARAMETER Uri
        The URI to resolve. This parameter is mandatory. URL is accepted as an alias.
        .PARAMETER UserAgent
        The user agent string to use for the request. By default, it uses two user agent strings: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' and 'Googlebot/2.1 (+http://www.google.com/bot.html)'. You can specify multiple user agent strings as an array.
        .PARAMETER Headers
        Additional headers to include in the request. Default is @{'accept' = '*/*'}, which is needed to trick some servers into serving a download, such as from FileZilla.
        .OUTPUTS
        The function outputs a custom object with the following properties:
            - Uri: The original URL.
            - AbsoluteUri: The resolved URL after any redirections.
            - FileName: The extracted filename from the URL or headers.
            - FileSizeBytes: The file size in bytes.
            - FileSizeReadable: The file size in a human-readable format.
            - LastModified: The last modified date of the file.
        .EXAMPLE
        Nekta_ResolveUrl -Uri 'https://example.com/file.txt'
        Resolves the URL 'https://example.com/file.txt' and retrieves the file information.
        .EXAMPLE
        Nekta_ResolveUrl -Uri 'https://example.com/file.txt' -UserAgent 'My User Agent'
        Resolves the URL 'https://example.com/file.txt' using the specified user agent string.
        .EXAMPLE
        Nekta_ResolveUrl -Uri 'https://example.com/file.txt' -Headers @{ 'Authorization' = 'Bearer token' }
        Resolves the URL 'https://example.com/file.txt' and includes the 'Authorization' header in the request.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("U")]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter(Position = 1, Mandatory = $false)]
        [string[]]$UserAgent = @($null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36', 'Googlebot/2.1 (+http://www.google.com/bot.html)'),
        
        [Parameter(Position = 2, Mandatory = $false)]
        [hashtable]$Headers = @{accept = '*/*' }
    )	
	
    begin {
        #[string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        #Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile

        # Required on Windows Powershell only
        if ($PSEdition -eq 'Desktop') {
            Add-Type -AssemblyName System.Net.Http
            Add-Type -AssemblyName System.Web
        }        
       
        # Enable TLS 1.2 in addition to whatever is pre-configured
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

        # Create one single client object for the pipeline
        $HttpClient = New-Object System.Net.Http.HttpClient

        if ($null -ne $Headers) {
            foreach ($Header in $Headers.GetEnumerator()) {
                $HttpClient.DefaultRequestHeaders.Add($Header.Key, $Header.Value)
            }
        }
    }

    process {
        # Reset variables
        $FileName = $FileSizeBytes = $FileSizeReadable = $LastModified = $null

        Nekta_Logging "INFO" "Requesting headers from URL '$Uri'" $LogFile

        foreach ($UserAgentString in $UserAgent) {
            $HttpClient.DefaultRequestHeaders.Remove('User-Agent') | Out-Null
            if ($UserAgentString) {
                Nekta_Logging "INFO" "Using UserAgent '$UserAgentString'" $LogFile
                $HttpClient.DefaultRequestHeaders.Add('User-Agent', $UserAgentString)
            }

            # This sends a GET request but only retrieves the headers
            $ResponseHeader = $HttpClient.GetAsync($Uri, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

            # Exit the foreach if success
            if ($ResponseHeader.IsSuccessStatusCode) {
                break
            }
        }

        if ($ResponseHeader.IsSuccessStatusCode) {
            Nekta_Logging "INFO" "Successfully retrieved headers" $LogFile

            if ($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri -ne $Uri) {
                Nekta_Logging "INFO" "URL '$Uri' redirects to '$($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri)'" $LogFile
            }

            try {
                $FileSizeBytes = $null
                $FileSizeBytes = [int]$ResponseHeader.Content.Headers.GetValues('Content-Length')[0]
                $FileSizeReadable = Format-Bytes($FileSizeBytes)
                Nekta_Logging "INFO" "File size: $($FileSizeReadable)" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "Unable to determine file size" $LogFile
            }

            # Try to get the last modified date from the "Last-Modified" header, use error handling in case string is in invalid format
            try {
                $LastModified = $null
                $LastModified = [DateTime]::ParseExact($ResponseHeader.Content.Headers.GetValues('Last-Modified')[0], 'r', [System.Globalization.CultureInfo]::InvariantCulture)
                Nekta_Logging "INFO" "Last modified: $($LastModified.ToString())" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "Last-Modified header not found" $LogFile
            }

            if ($FileName) {
                $FileName = $FileName.Trim()
                Nekta_Logging "INFO" "Will use supplied filename '$FileName'"  $LogFile
            }
            else {
                # Get the file name from the "Content-Disposition" header if available
                try {
                    $ContentDispositionHeader = $null
                    $ContentDispositionHeader = $ResponseHeader.Content.Headers.GetValues('Content-Disposition')[0]
                    Nekta_Logging "INFO" "Content-Disposition header found: $ContentDispositionHeader" $LogFile
                }
                catch {
                    Nekta_Logging "INFO" "Content-Disposition header not found" $LogFile
                }
                if ($ContentDispositionHeader) {
                    $ContentDispositionRegEx = @'
^.*filename\*?\s*=\s*"?(?:UTF-8|iso-8859-1)?(?:'[^']*?')?([^";]+)
'@
                    if ($ContentDispositionHeader -match $ContentDispositionRegEx) {
                        # GetFileName ensures we are not getting a full path with slashes. UrlDecode will convert characters like %20 back to spaces.
                        $FileName = [System.IO.Path]::GetFileName([System.Web.HttpUtility]::UrlDecode($matches[1]))
                        # If any further invalid filename characters are found, convert them to spaces.
                        [IO.Path]::GetinvalidFileNameChars() | ForEach-Object { $FileName = $FileName.Replace($_, ' ') }
                        $FileName = $FileName.Trim()
                        Nekta_Logging "INFO" "Extracted filename '$FileName' from Content-Disposition header" $LogFile
                    }
                    else {
                        Nekta_Logging "ERROR" "Failed to extract filename from Content-Disposition header" $LogFile
                    }
                }
    
                if ([string]::IsNullOrEmpty($FileName)) {
                    # If failed to parse Content-Disposition header or if it's not available, extract the file name from the absolute URL to capture any redirections.
                    # GetFileName ensures we are not getting a full path with slashes. UrlDecode will convert characters like %20 back to spaces. The URL is split with ? to ensure we can strip off any API parameters.
                    $FileName = [System.IO.Path]::GetFileName([System.Web.HttpUtility]::UrlDecode($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri.Split('?')[0]))
                    [IO.Path]::GetinvalidFileNameChars() | ForEach-Object { $FileName = $FileName.Replace($_, ' ') }
                    $FileName = $FileName.Trim()
                    Nekta_Logging "INFO" "Extracted filename '$FileName' from absolute URL '$($ResponseHeader.RequestMessage.RequestUri.AbsoluteUri)'" $LogFile
                }
            }
        }
        else {
            throw "Failed to retrieve headers from $($Uri): $([int]$ResponseHeader.StatusCode): $($ResponseHeader.ReasonPhrase)"
        }

        if ([string]::IsNullOrEmpty($FileName)) {
            # If still no filename set, extract the file name from the original URL.
            # GetFileName ensures we are not getting a full path with slashes. UrlDecode will convert characters like %20 back to spaces. The URL is split with ? to ensure we can strip off any API parameters.
            $FileName = [System.IO.Path]::GetFileName([System.Web.HttpUtility]::UrlDecode($Uri.Split('?')[0]))
            [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object { $FileName = $FileName.Replace($_, ' ') }
            $FileName = $FileName.Trim()
            Nekta_Logging "INFO" "Extracted filename '$FileName' from original URL '$Uri'" $LogFile
        }

        [PSCustomObject]@{
            Uri              = $Uri
            AbsoluteUri      = $ResponseHeader.RequestMessage.RequestUri.AbsoluteUri
            FileName         = $FileName
            FileSizeBytes    = $FileSizeBytes
            FileSizeReadable = $FileSizeReadable
            LastModified     = $LastModified
        }    
    }

    end {
        $HttpClient.Dispose()
        #Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Nekta_NovaDownloader
#==========================================================================
Function Nekta_NovaDownloader {
    <#
        .SYNOPSIS
        Downloads a file from a specified URI.
        .DESCRIPTION
        The Nekta_NovaDownloader function downloads a file from a specified URI and saves it to the specified destination.
        .PARAMETER Uri
        The URI of the file to download. URL is accepted as an alias.
        .PARAMETER Destination
        The destination folder where the downloaded file will be saved. Default is the current working directory.
        .PARAMETER FileName
        The name of the downloaded file. If not provided, the function will attempt to extract the filename from the URI.
        .PARAMETER UserAgent
        The user agent string to use for the request. By default, it uses two user agent strings: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' and 'Googlebot/2.1 (+http://www.google.com/bot.html)'. You can specify multiple user agent strings as an array.
        .PARAMETER Headers
        Additional headers to include in the request. Default is @{'accept' = '*/*'}, which is needed to trick some servers into serving a download, such as from FileZilla.
        .PARAMETER TempPath
        The temporary folder path to use for storing the downloaded file temporarily. Default is the user's temp folder.
        .PARAMETER IgnoreDate
        If specified, the function will not set the last modified date of the downloaded file.
        .PARAMETER NoProgress
        If specified, the function will not display a progress bar during the download.
        .PARAMETER PassThru
        If specified, the function will return the downloaded file object.
        .EXAMPLE
        Nekta_NovaDownloader -Uri 'https://example.com/file.txt' -Destination 'C:\Downloads'
        This example downloads the file from the specified URI and saves it to the 'C:\Downloads' folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("U")]                
        [ValidateNotNullOrEmpty()]
        [string]$Uri,        
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias("D")]
        [string]$Destination = $pwd.Path,        
        [Parameter(Position = 2)]
        [string[]]$UserAgent = @($null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36', 'Googlebot/2.1 (+http://www.google.com/bot.html)'),             
        [hashtable]$Headers = @{accept = '*/*' },        
        [Alias("TEMP")]
        [string]$TempPath = $env:TEMP,        
        [Alias("ID")]
        [switch]$IgnoreDate,               
        [Alias("NP")]
        [switch]$NoProgress,        
        [Alias("TH")]
        [switch]$PassThru
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        Nekta_Logging "INFO" "START FUNCTION - $FunctionName" $LogFile

        if ($PSEdition -eq 'Desktop') {
            Add-Type -AssemblyName System.Net.Http
            Add-Type -AssemblyName System.Web
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $HttpClient = New-Object System.Net.Http.HttpClient
        foreach ($Header in $Headers.GetEnumerator()) {
            $HttpClient.DefaultRequestHeaders.Add($Header.Key, $Header.Value)
        }
    }

    process {
        $ResolveUriSplat = @{
            Uri       = $Uri
            UserAgent = $UserAgent
            Headers   = $Headers
        }
        $Properties = Nekta_ResolveUrl @ResolveUriSplat -ErrorAction Stop

        if ([string]::IsNullOrEmpty($FileName)) {
            if ([string]::IsNullOrEmpty($Properties.FileName)) {
                Nekta_Logging "ERROR" "No filename found for $Uri" $LogFile
                return
            }
            else {
                $FileName = $Properties.FileName
            }
        }

        $DestinationFilePath = Join-Path $Destination $FileName       

        foreach ($UserAgentString in $UserAgent) {
            $HttpClient.DefaultRequestHeaders.Remove('User-Agent') | Out-Null
            if ($UserAgentString) {
                Nekta_Logging "INFO" "Using UserAgent '$UserAgentString'" $LogFile
                $HttpClient.DefaultRequestHeaders.Add('User-Agent', $UserAgentString)
            }

            $ResponseStream = $HttpClient.GetStreamAsync($Uri)

            if ($ResponseStream.Result.CanRead) {
                break
            }
            else {
                continue
            }
        }

        if (!$ResponseStream.Result.CanRead) {
            throw "$($ResponseStream.Exception.InnerException.Message)"
        }        
        
        # Generate temp file name
        $TempFileName = (New-Guid).ToString('N') + ".tmp"
        $TempFilePath = Join-Path $TempPath $TempFileName
        
        # Check Destination exists and create it if not
        if (-not (Test-Path -Path $Destination)) {
            Nekta_Logging "INFO" "Output folder '$Destination' does not exist" $LogFile
            try {
                Nekta_NewDirectory -Directory $Destination
                Nekta_Logging "INFO" "Created output folder '$Destination'" $LogFile
            }
            catch {
                Nekta_Logging "ERROR" "Unable to create output folder '$Destination': $_" $LogFile
                return
            }
        }
        
        # Open file stream
        try {
            $FileStream = [System.IO.File]::Create($TempFilePath)
        }
        catch {
            Nekta_Logging "ERROR" "Unable to create file '$TempFilePath': $_" $LogFile
            return
        }
                
        if ($FileStream.CanWrite) {
            Nekta_Logging "INFO" "Downloading to temp file '$TempFilePath'..." $LogFile        
            $Buffer = New-Object byte[] 64KB
            $BytesDownloaded = 0
            $ProgressIntervalMs = 250
            $ProgressTimer = (Get-Date).AddMilliseconds(-$ProgressIntervalMs)
        
            while ($true) {
                try {
                    # Read stream into buffer
                    $ReadBytes = $ResponseStream.Result.Read($Buffer, 0, $Buffer.Length)                   
        
                    # Track bytes downloaded and display progress bar if enabled and file size is known
                    $BytesDownloaded += $ReadBytes
                    if (!$NoProgress -and (Get-Date) -gt $ProgressTimer.AddMilliseconds($ProgressIntervalMs)) {
                        if ($Properties.FileSizeBytes) {
                            $PercentComplete = [System.Math]::Floor($BytesDownloaded / $Properties.FileSizeBytes * 100)
                            $TotalSize = Format-Bytes($Properties.FileSizeBytes)
                            $ReceivedBytes = Format-Bytes($BytesDownloaded)                                                  
                            Write-Progress -Activity "Downloading $FileName" -Status "$ReceivedBytes of $($TotalSize) ($PercentComplete%)" -PercentComplete $PercentComplete
                        }
                        else {
                            Write-Progress -Activity "Downloading $FileName" -Status "$ReceivedBytes of ? bytes" -PercentComplete 0
                        }
                        $ProgressTimer = Get-Date
                    }
        
                    # If end of stream
                    if ($ReadBytes -eq 0) {
                        Write-Progress -Activity "Downloading $FileName" -Completed
                        $FileStream.Close()
                        $FileStream.Dispose()
                        try {
                            Nekta_Logging "INFO" "Moving temp file to destination '$DestinationFilePath'" $LogFile
                            $DownloadedFile = Move-Item -LiteralPath $TempFilePath -Destination $DestinationFilePath -Force -PassThru
                        }
                        catch {
                            Nekta_Logging "ERROR" "Error moving file from '$TempFilePath' to '$DestinationFilePath': $_" $LogFile
                            return
                        }
                       
                        if ($Properties.LastModified -and -not $IgnoreDate) {
                            Nekta_Logging "INFO" "Setting Last Modified date" $LogFile
                            $DownloadedFile.LastWriteTime = $Properties.LastModified
                        }
                        Nekta_Logging "INFO" "Download complete!" $LogFile
                        
                        if ($PassThru) {
                            $DownloadedFile
                        }
                        break
                    }
                    $FileStream.Write($Buffer, 0, $ReadBytes)
                }
                catch {
                    Nekta_Logging "ERROR" "Error downloading file: $_" $LogFile
                    Write-Progress -Activity "Downloading $FileName" -Completed
                    $FileStream.Close()
                    $FileStream.Dispose()
                    break
                }
            }            
        }
    }

    end {
        $HttpClient.Dispose()       
        Nekta_Logging "INFO" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION Format-Bytes
#==========================================================================
Function Format-Bytes {
    param
    (
        [Parameter(
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [long]$number
    )
    begin {        
        # Unidades IEC com sufixos específicos
        $sizes = 'B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'
    }
    
    process {
        # Loop para determinar a unidade apropriada
        for ($x = 0; $x -lt $sizes.Count; $x++) {
            # Verifica se o valor é menor que 1024^(x+1), indicando que a unidade atual é a mais apropriada
            if ($number -lt [math]::Pow(1024, $x + 1)) {
                # Formata o número com a unidade IEC apropriada
                $num = $number / [math]::Pow(1024, $x)
                $num = "{0:N2}" -f $num
                return "$num $($sizes[$x])"
            }
        }
    }
    end {}
}
#==========================================================================

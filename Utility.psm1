#==========================================================================
# List of all functions in this script:
# -------------------------------------
# -Windows functions
#     -Files and folders
#       -DS_CleanupDirectory                  -> Delete files in a directory
#       -DS_CopyFile                          -> Copy a file or multiple files
#       -DS_CreateDirectory                   -> Create a directory
#       -DS_DeleteDirectory                   -> Delete a directory
#       -DS_MoveDirectory                     -> Move a directory
#       -DS_DeleteFile                        -> Delete a file
#       -DS_RenameItem                        -> Rename a file or registry value
#       -DS_ExpandArchive                     -> Expand a zip file 
#       -DS_AddContentToFile                  -> Add content to a file
#       -DS_GetContentFromFile                -> Get content from file 
#       -DS_MoveFile                          -> Move a file or multiple files
#     -Installations and executables
#       -DS_ExecuteProcess                    -> Start a process
#       -DS_InstallOrUninstallSoftware        -> Install or uninstall software
#     -Logging
#       -DS_WriteLog                          -> Write log file
#     -Registry
#       -DS_CreateRegistryKey                 -> Create a registry key
#       -DS_DeleteRegistryKey                 -> Delete a registry key
#       -DS_DeleteRegistryValue               -> Delete a registry value (any data type)
#       -DS_ImportRegistryFile                -> Import a registry (*.reg) file into the registry
#       -DS_RenameRegistryKey                 -> Rename a registry key
#       -DS_RenameRegistryValue               -> Rename a registry value
#       -DS_SetRegistryValue                  -> Create or modify a registry value (any data type)
#     -Services
#       -DS_ChangeServiceStartupType          -> Change the startup type of a service (Boot, System, Automatic, Manual and Disabled)
#       -DS_StopService                       -> Stop a service (including depend services)
#       -DS_StartService                      -> Start service (including depend services)
#     -System
#       -DS_ClearPrefetchFolder               -> Clear a prefetch folder
#       -DS_StartStopProcess                  -> Start and stop a process     
#       -DS_CheckPathExist                    -> Checks if path exists
#       -DS_JoinPath                          -> Join path

# define Error handling
# note: do not change these values
$global:ErrorActionPreference = "Stop"
if ($verbose) { $global:VerbosePreference = "Continue" }

# Set default log directory (in case the variable $LogFile has not been defined)
if ( ([string]::IsNullOrEmpty($LogFile)) -Or ($LogFile.Length -eq 0) ) {
    $LogDir = "$env:TEMP\Logs"
    $LogFileName = "DefaultLogFile_$(Get-Date -format dd-MM-yyyy)_$((Get-Date -format HH:mm:ss).Replace(":","-")).log"
    $LogFile = Join-path $LogDir $LogFileName
}

###########################################################################
#                                                                         #
#     WINDOWS FUNCTIONS                                                   #
#                                                                         #
###########################################################################
###########################################################################
#                                                                         #
#          WINDOWS \ FILES AND FOLDERS                                    #
#                                                                         #
###########################################################################

# FUNCTION DS_CleanupDirectory
# Description: delete all files and subfolders in one specific directory (e.g. C:\Windows\Temp). Do not delete the main folder itself.
#==========================================================================
Function DS_CleanupDirectory {
    <#
        .SYNOPSIS
        Delete all files and subfolders in one specific directory, but do not delete the main folder itself
        .DESCRIPTION
        Delete all files and subfolders in one specific directory, but do not delete the main folder itself
        .PARAMETER Directory
        This parameter contains the full path to the directory that needs to cleaned (for example 'C:\Temp')
        .EXAMPLE
        DS_CleanupDirectory -Directory "C:\Temp"
        Deletes all files and subfolders in the directory 'C:\Temp'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$Directory
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Cleanup directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            try {
                Remove-Item "$Directory\*.*" -force -recurse | Out-Null
                Remove-Item "$Directory\*" -force -recurse | Out-Null
                DS_WriteLog "S" "Successfully deleted all files and subfolders in the directory $Directory" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to delete files and subfolders in the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The directory $Directory does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_ExpandArchive
#==========================================================================

Function DS_ExpandArchive {
    <#
        .SYNOPSIS
        Expand an archive file (ZIP).
        .DESCRIPTION
        This function extracts the contents of a compressed archive (ZIP) to a specified destination folder.
        .PARAMETER SourceFile
        This parameter contains the full path to the ZIP file that you want to extract.
        .PARAMETER DestinationPath
        This parameter contains the full path to the directory where the contents will be extracted.
        .PARAMETER Overwrite
        This parameter specifies whether existing files should be overwritten. The default is 'False'.
        .EXAMPLE
        DS_ExpandArchive -SourceFile "C:\Temp\MyArchive.zip" -DestinationPath "C:\Temp\ExtractedFiles" -Overwrite $true
        Extracts the ZIP file 'MyArchive.zip' to the folder 'ExtractedFiles', overwriting existing files.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$SourceFile,
        [Parameter(Mandatory = $false, Position = 1)][AllowEmptyString()][String]$DestinationPath,
        [Parameter(Mandatory = $false, Position = 2)][Bool]$Overwrite = $false
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Logging source and destination paths
        DS_WriteLog "I" "Source file: $SourceFile" $LogFile
        DS_WriteLog "I" "Destination path: $DestinationPath" $LogFile

        # Check if the source file exists
        if (!(Test-Path $SourceFile)) {
            DS_WriteLog "E" "The file '$SourceFile' does not exist!" $LogFile
            Exit 1
        }

        # Check if the destination directory exists, if not, create it
        if (!(Test-Path $DestinationPath)) {
            DS_WriteLog "I" "The destination directory does not exist. Creating directory: $DestinationPath" $LogFile
            New-Item -ItemType Directory -Path $DestinationPath | Out-Null
        }

        # Expand the archive
        try {
            if ($Overwrite) {
                DS_WriteLog "I" "Expanding archive '$SourceFile' to '$DestinationPath' with overwrite enabled" $LogFile
                Expand-Archive -Path $SourceFile -DestinationPath $DestinationPath -Force
            }
            else {
                DS_WriteLog "I" "Expanding archive '$SourceFile' to '$DestinationPath' without overwriting" $LogFile
                Expand-Archive -Path $SourceFile -DestinationPath $DestinationPath
            }
            DS_WriteLog "S" "The archive '$SourceFile' was successfully extracted to '$DestinationPath'" $LogFile
        }
        catch {
            DS_WriteLog "E" "An error occurred while extracting the archive '$SourceFile' to '$DestinationPath': $_" $LogFile
            Exit 1
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_AddContentToFile
#==========================================================================

Function DS_AddContentToFile {
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
        DS_AddContentToFile -FilePath "C:\Logs\example.txt" -Content "This is a new line of text."
        Adds the line "This is a new line of text." to the file example.txt at the specified path.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$FilePath,
        [Parameter(Mandatory = $true, Position = 1)][String]$Content
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the start of the content-adding process
        DS_WriteLog "I" "Adding content to the file '$FilePath'" $LogFile

        try {
            # Add the content to the specified file
            Add-Content -Path $FilePath -Value $Content
            DS_WriteLog "I" "Content successfully added to '$FilePath'" $LogFile
        }
        catch {
            # Log any errors encountered during the content addition
            DS_WriteLog "E" "Error adding content to '$FilePath' (error: $($_.Exception.Message))" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_GetContentFromFile
#==========================================================================

Function DS_GetContentFromFile {
    <#
        .SYNOPSIS
        Retrieves content from a file.
        .DESCRIPTION
        This function retrieves the content of a specified file. If the file does not exist, it will log a warning.
        .PARAMETER FilePath
        Path to the file from which content will be retrieved.
        .EXAMPLE
        DS_GetContentFromFile -FilePath "C:\Logs\example.txt"
        Retrieves and returns the content of the file example.txt at the specified path.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$FilePath
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the attempt to read content from the file
        DS_WriteLog "I" "Retrieving content from the file '$FilePath'" $LogFile

        try {
            # Check if the file exists before reading
            if (Test-Path $FilePath) {
                # Get the content from the specified file
                $Content = Get-Content -Path $FilePath
                DS_WriteLog "I" "Content successfully retrieved from '$FilePath'" $LogFile
                return $Content
            }
            else {
                # Log a warning if the file does not exist
                DS_WriteLog "W" "File '$FilePath' does not exist." $LogFile
                return $null
            }
        }
        catch {
            # Log any errors encountered during the content retrieval
            DS_WriteLog "E" "Error retrieving content from '$FilePath' (error: $($_.Exception.Message))" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}


#==========================================================================

# FUNCTION DS_MoveFile
#==========================================================================
Function DS_MoveFile {
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
        DS_MoveFile -SourceFiles "C:\Temp\MyFile.txt" -Destination "C:\Temp2"
        Moves 'C:\Temp\MyFile.txt' to 'C:\Temp2'.
        .EXAMPLE
        DS_MoveFile -SourceFiles "C:\Temp\MyFile.txt" -Destination "C:\Temp2\MyRenamedFile.txt"
        Moves 'C:\Temp\MyFile.txt' to 'C:\Temp2' and renames it to 'MyRenamedFile.txt'.
        .EXAMPLE
        DS_MoveFile -SourceFiles "C:\Temp\*.txt" -Destination "C:\Temp2"
        Moves all '.txt' files from 'C:\Temp' to 'C:\Temp2'.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$SourceFiles,
        [Parameter(Mandatory = $true, Position = 1)][String]$Destination
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the source and destination details
        DS_WriteLog "I" "Move the source file(s) '$SourceFiles' to '$Destination'" $LogFile

        # Determine the destination directory, creating it if needed
        if ($Destination.Contains(".")) {
            # If $Destination contains a dot, treat it as a path with a filename
            $TempFolder = Split-Path -Path $Destination
        } else {
            # Otherwise, assume it's a directory path
            $TempFolder = $Destination
        }

        # Check if destination path exists; create it if it does not
        DS_WriteLog "I" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if (Test-Path $TempFolder) {
            DS_WriteLog "I" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        } else {
            DS_WriteLog "I" "The destination path '$TempFolder' does not exist" $LogFile
            DS_CreateDirectory -Directory $TempFolder
        }

        # Move the source files
        DS_WriteLog "I" "Start moving the source file(s) '$SourceFiles' to '$Destination'" $LogFile
        try {
            Move-Item -Path $SourceFiles -Destination $Destination -Force
            DS_WriteLog "S" "Successfully moved the source file(s) '$SourceFiles' to '$Destination'" $LogFile
        }
        catch {
            # Log the error if the move fails
            DS_WriteLog "E" "An error occurred while moving the source file(s) '$SourceFiles' to '$Destination'. Error: $($_.Exception.Message)" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_CopyFile
#==========================================================================
Function DS_CopyFile {
    <#
        .SYNOPSIS
        Copy one or more files
        .DESCRIPTION
        Copy one or more files
        .PARAMETER SourceFiles
        This parameter can contain multiple file and folder combinations including wildcards. UNC paths can be used as well. Please see the examples for more information.
        To see the examples, please enter the following PowerShell command: Get-Help DS_CopyFile -examples
        .PARAMETER Destination
        This parameter contains the destination path (for example 'C:\Temp2' or 'C:\MyPath\MyApp'). This path may also include a file name.
        This situation occurs when a single file is copied to another directory and renamed in the process (for example '$Destination = C:\Temp2\MyNewFile.txt').
        UNC paths can be used as well. The destination directory is automatically created if it does not exist (in this case the function 'DS_CreateDirectory' is called). 
        This works both with local and network (UNC) directories. In case the variable $Destination contains a path and a file name, the parent folder is 
        automatically extracted, checked and created if needed. 
        Please see the examples for more information.To see the examples, please enter the following PowerShell command: Get-Help DS_CopyFile -examples
        .EXAMPLE
        DS_CopyFile -SourceFiles "C:\Temp\MyFile.txt" -Destination "C:\Temp2"
        Copies the file 'C:\Temp\MyFile.txt' to the directory 'C:\Temp2'
        .EXAMPLE
        DS_CopyFile -SourceFiles "C:\Temp\MyFile.txt" -Destination "C:\Temp2\MyNewFileName.txt"
        Copies the file 'C:\Temp\MyFile.txt' to the directory 'C:\Temp2' and renames the file to 'MyNewFileName.txt'
        .EXAMPLE
        DS_CopyFile -SourceFiles "C:\Temp\*.txt" -Destination "C:\Temp2"
        Copies all files with the file extension '*.txt' in the directory 'C:\Temp' to the destination directory 'C:\Temp2'
        .EXAMPLE
        DS_CopyFile -SourceFiles "C:\Temp\*.*" -Destination "C:\Temp2"
        Copies all files within the root directory 'C:\Temp' to the destination directory 'C:\Temp2'. Subfolders (including files within these subfolders) are NOT copied.
        .EXAMPLE
        DS_CopyFile -SourceFiles "C:\Temp\*" -Destination "C:\Temp2"
        Copies all files in the directory 'C:\Temp' to the destination directory 'C:\Temp2'. Subfolders as well as files within these subfolders are also copied.
        .EXAMPLE
        DS_CopyFile -SourceFiles "C:\Temp\*.txt" -Destination "\\localhost\Temp2"
        Copies all files with the file extension '*.txt' in the directory 'C:\Temp' to the destination directory '\\localhost\Temp2'. The directory in this example is a network directory (UNC path).
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$SourceFiles,
        [Parameter(Mandatory = $true, Position = 1)][String]$Destination
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Copy the source file(s) '$SourceFiles' to '$Destination'" $LogFile
        # Retrieve the parent folder of the destination path
        if ( $Destination.Contains(".") ) {
            # In case the variable $Destination contains a dot ("."), return the parent folder of the path
            $TempFolder = split-path -path $Destination
        }
        else {
            $TempFolder = $Destination
        }

        # Check if the destination path exists. If not, create it.
        DS_WriteLog "I" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if ( Test-Path $TempFolder) {
            DS_WriteLog "I" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        }
        else {
            DS_WriteLog "I" "The destination path '$TempFolder' does not exist" $LogFile
            DS_CreateDirectory -Directory $TempFolder
        }

        # Copy the source files
        DS_WriteLog "I" "Start copying the source file(s) '$SourceFiles' to '$Destination'" $LogFile
        try {
            Copy-Item $SourceFiles -Destination $Destination -Force -Recurse
            DS_WriteLog "S" "Successfully copied the source files(s) '$SourceFiles' to '$Destination'" $LogFile
        }
        catch {
            DS_WriteLog "E" "An error occurred trying to copy the source files(s) '$SourceFiles' to '$Destination'" $LogFile
            Exit 1
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_CreateDirectory
#==========================================================================
Function DS_CreateDirectory {
    <#
        .SYNOPSIS
        Create a new directory
        .DESCRIPTION
        Create a new directory
        .PARAMETER Directory
        This parameter contains the name of the new directory including the full path (for example C:\Temp\MyNewFolder).
        .EXAMPLE
        DS_CreateDirectory -Directory "C:\Temp\MyNewFolder"
        Creates the new directory "C:\Temp\MyNewFolder"
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$Directory
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Create directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            DS_WriteLog "I" "The directory $Directory already exists. Nothing to do" $LogFile
        }
        else {
            try {
                New-Item -ItemType Directory -Path $Directory -force | Out-Null
                DS_WriteLog "S" "Successfully created the directory $Directory" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to create the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_DeleteDirectory
# Description: delete the entire directory
#==========================================================================
Function DS_DeleteDirectory {
    <#
        .SYNOPSIS
        Delete a directory
        .DESCRIPTION
        Delete a directory
        .PARAMETER Directory
        This parameter contains the full path to the directory which needs to be deleted (for example C:\Temp\MyFolder).
        .EXAMPLE
        DS_DeleteDirectory -Directory "C:\Temp\MyFolder"
        Deletes the directory "C:\Temp\MyFolder"
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$Directory
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Delete directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            try {
                Remove-Item $Directory -force -recurse | Out-Null
                DS_WriteLog "S" "Successfully deleted the directory $Directory" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to delete the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The directory $Directory does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_DeleteFile
# Description: delete one specific file
#==========================================================================
Function DS_DeleteFile {
    <#
        .SYNOPSIS
        Delete a file
        .DESCRIPTION
        Delete a file
        .PARAMETER File
        This parameter contains the full path to the file (including the file name and file extension) that needs to be deleted (for example C:\Temp\MyFile.txt).
        .EXAMPLE
        DS_DeleteFile -File "C:\Temp\MyFile.txt"
        Deletes the file "C:\Temp\MyFile.txt"
        .EXAMPLE
        DS_DeleteFile -File "C:\Temp\*.txt"
        Deletes all files in the directory "C:\Temp" that have the file extension *.txt. *.txt files stored within subfolders of 'C:\Temp' are NOT deleted 
        .EXAMPLE
        DS_DeleteFile -File "C:\Temp\*.*"
        Deletes all files in the directory "C:\Temp". This function does NOT remove any subfolders nor files within a subfolder (use the function 'DS_CleanupDirectory' instead)
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$File
    )
 
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Delete the file '$File'" $LogFile
        if ( Test-Path $File ) {
            try {
                Remove-Item "$File" | Out-Null
                DS_WriteLog "S" "Successfully deleted the file '$File'" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to delete the file '$File' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The file '$File' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_MoveDirectory
#==========================================================================

Function DS_MoveDirectory {
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
        DS_MoveDirectory -SourceDirectories "C:\Temp\MyFolder" -Destination "C:\Temp2"
        Moves 'C:\Temp\MyFolder' to 'C:\Temp2'.
        .EXAMPLE
        DS_MoveDirectory -SourceDirectories "C:\Temp\MyFolder" -Destination "C:\Temp2\MyRenamedFolder"
        Moves 'C:\Temp\MyFolder' to 'C:\Temp2' and renames it to 'MyRenamedFolder'.
        .EXAMPLE
        DS_MoveDirectory -SourceDirectories "C:\Temp\*" -Destination "C:\Temp2"
        Moves all directories from 'C:\Temp' to 'C:\Temp2'.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$SourceDirectories,
        [Parameter(Mandatory = $true, Position = 1)][String]$Destination
    )

    begin {
        # Log the start of the function
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Log the source and destination details
        DS_WriteLog "I" "Move the source directory(s) '$SourceDirectories' to '$Destination'" $LogFile

        # Determine the destination directory
        if ($Destination.Contains(".")) {
            # If $Destination contains a dot, treat it as a path with a directory name
            $TempFolder = Split-Path -Path $Destination
        } else {
            # Otherwise, assume it's a directory path
            $TempFolder = $Destination
        }

        # Check if destination path exists; create it if it does not
        DS_WriteLog "I" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if (Test-Path $TempFolder) {
            DS_WriteLog "I" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        } else {
            DS_WriteLog "I" "The destination path '$TempFolder' does not exist" $LogFile
            DS_CreateDirectory -Directory $TempFolder
        }

        # Move the source directories
        DS_WriteLog "I" "Start moving the source directory(s) '$SourceDirectories' to '$Destination'" $LogFile
        try {
            Move-Item -Path $SourceDirectories -Destination $Destination -Force
            DS_WriteLog "S" "Successfully moved the source directory(s) '$SourceDirectories' to '$Destination'" $LogFile
        }
        catch {
            # Log the error if the move fails
            DS_WriteLog "E" "An error occurred while moving the source directory(s) '$SourceDirectories' to '$Destination'. Error: $($_.Exception.Message)" $LogFile
            Exit 1
        }
    }

    end {
        # Log the end of the function
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_RenameItem
#==========================================================================
Function DS_RenameItem {
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
        DS_RenameItem -ItemPath "C:\Temp\MyOldFileName.txt" -NewName "MyNewFileName.txt"
        Renames the file "C:\Temp\MyOldFileName.txt" to "MyNewFileName.txt". The parameter 'NewName' only requires the new file name without specifying the path to the file
        .EXAMPLE
        DS_RenameItem -ItemPath "C:\Temp\MyOldFileName.txt" -NewName "MyNewFileName.rtf"
        Renames the file "C:\Temp\MyOldFileName.txt" to "MyNewFileName.rtf". Besides changing the name of the file, the file extension is modified as well. Please make sure that the new file format is compatible with the original file format and can actually be opened after being renamed! The parameter 'NewName' only requires the new file name without specifying the path to the file
        .EXAMPLE
        DS_RenameItem -ItemPath "C:\Temp\MyOldFolderName" -NewName "MyNewFolderName"
        Renames the folder "C:\Temp\MyOldFolderName" to "C:\Temp\MyNewFolderName". The parameter 'NewName' only requires the new folder name without specifying the path to the folder
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$ItemPath,
        [Parameter(Mandatory = $true, Position = 1)][String]$NewName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Rename '$ItemPath' to '$NewName'" $LogFile

        # Rename the item (if exist)
        if ( Test-Path $ItemPath ) {
            try {
                Rename-Item -path $ItemPath -NewName $NewName | Out-Null
                DS_WriteLog "S" "The item '$ItemPath' was renamed to '$NewName' successfully" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to rename the item '$ItemPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The item '$ItemPath' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ INSTALLATIONS AND EXECUTABLES                        #
#                                                                         #
###########################################################################

# FUNCTION DS_ExecuteProcess
#==========================================================================
Function DS_ExecuteProcess {
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
        DS_ExecuteProcess -FileName "C:\Temp\MyApp.exe" -Arguments "-silent"
        Executes the file 'MyApp.exe' with arguments '-silent'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$FileName,
        [Parameter(Mandatory = $false, Position = 1)][String]$Arguments
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        if ([string]::IsNullOrEmpty($Arguments)) {
            DS_WriteLog "I" "Execute process '$Filename' with no arguments" $LogFile
            $Process = Start-Process $FileName -Wait -NoNewWindow -PassThru
        }
        else {
            DS_WriteLog "I" "Execute process '$Filename' with arguments '$Arguments'" $LogFile
            $Process = Start-Process $FileName -ArgumentList $Arguments -Wait -NoNewWindow -PassThru
        }

        $Process.HasExited
        $ProcessExitCode = $Process.ExitCode
        if ($ProcessExitCode -eq 0) {
            DS_WriteLog "S" "The process '$Filename' ended successfully" $LogFile
        }
        else {
            DS_WriteLog "E" "An error occurred trying to execute the process '$Filename' (exit code: $ProcessExitCode)!" $LogFile
            Exit 1
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_ExecuteProcessNoWait
#==========================================================================
Function DS_ExecuteProcessNoWait {
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
        DS_ExecuteProcess -FileName "C:\Temp\MyApp.exe" -Arguments "-silent"
        Executes the file 'MyApp.exe' with arguments '-silent'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$FileName,
        [Parameter(Mandatory = $false, Position = 1)][String]$Arguments
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        if ([string]::IsNullOrEmpty($Arguments)) {
            DS_WriteLog "I" "Execute process '$Filename' with no arguments" $LogFile
            $Process = Start-Process $FileName -NoNewWindow -PassThru
        }
        else {
            DS_WriteLog "I" "Execute process '$Filename' with arguments '$Arguments'" $LogFile
            $Process = Start-Process $FileName -ArgumentList $Arguments -NoNewWindow -PassThru
        }

        $Process.HasExited
        $ProcessExitCode = $Process.ExitCode
        if ($ProcessExitCode -eq 0) {
            DS_WriteLog "S" "The process '$Filename' ended successfully" $LogFile
        }
        else {
            DS_WriteLog "E" "An error occurred trying to execute the process '$Filename' (exit code: $ProcessExitCode)!" $LogFile
            Exit 1
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_InstallOrUninstallSoftware
#==========================================================================
Function DS_InstallOrUninstallSoftware {
    <#
        .SYNOPSIS
        Install or uninstall software (MSI or SETUP.exe)
        .DESCRIPTION
        Install or uninstall software (MSI or SETUP.exe)
        .PARAMETER File
        This parameter contains the file name including the path and file extension, for example 'C:\Temp\MyApp\Files\MyApp.msi' or 'C:\Temp\MyApp\Files\MyApp.exe'.
        .PARAMETER Installationtype
        This parameter contains the installation type, which is either 'Install' or 'Uninstall'.
        .PARAMETER Arguments
        This parameter contains the command line arguments. The arguments list can remain empty.
        In case of an MSI, the following parameters are automatically included in the function and do not have
        to be specified in the 'Arguments' parameter: /i (or /x) /qn /norestart /l*v "c:\Logs\MyLogFile.log"
        .EXAMPLE
        DS_InstallOrUninstallSoftware -File "C:\Temp\MyApp\Files\MyApp.msi" -InstallationType "Install" -Arguments ""
        Installs the MSI package 'MyApp.msi' with no arguments (the function already includes the following default arguments: /i /qn /norestart /l*v $LogFile)
        .Example
        DS_InstallOrUninstallSoftware -File "C:\Temp\MyApp\Files\MyApp.msi" -InstallationType "Uninstall" -Arguments ""
        Uninstalls the MSI package 'MyApp.msi' (the function already includes the following default arguments: /x /qn /norestart /l*v $LogFile)
        .Example
        DS_InstallOrUninstallSoftware -File "C:\Temp\MyApp\Files\MyApp.exe" -InstallationType "Install" -Arguments "/silent /logfile:C:\Logs\MyApp\log.log"
        Installs the SETUP file 'MyApp.exe'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$File,
        [Parameter(Mandatory = $true, Position = 1)][AllowEmptyString()][String]$Installationtype,
        [Parameter(Mandatory = $true, Position = 2)][AllowEmptyString()][String]$Arguments
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        $FileName = [System.IO.Path]::GetFileName($File)
        $FileExt = $FileName.SubString(($FileName.Length) - 3, 3)    
 
        # Prepare variables
        if (-not($FileExt -eq "MSI")) { 
            $FileExt = "SETUP" 
        }

        if ($Installationtype -eq "Uninstall" ) {
            $Result1 = "uninstalled"
            $Result2 = "uninstallation"
        }
        else {
            $Result1 = "installed"
            $Result2 = "installation"
        }
        $LogFileAPP = Join-path $LogDir ("$($Installationtype)_$($FileName.Substring(0,($FileName.Length)-4))_$($FileExt).log" )
     
        # Verify the complete path
        $FilePath = Join-Path -Path $env:TEMP -ChildPath $FileName
        try {
            $ResolvedFilePath = Resolve-Path $FilePath -ErrorAction Stop
        }
        catch {
            DS_WriteLog "E" "The file '$FilePath' could not be resolved!" $LogFile
            Exit 1
        }
     
        # Logging
        DS_WriteLog "I" "File name: $FileName" $LogFile
        DS_WriteLog "I" "File full path: $File" $LogFile

        DS_WriteLog "I" "Resolved file path: $ResolvedFilePath" $LogFile

        # Verify if file exists    
        if (!(Test-Path $ResolvedFilePath)) {
            DS_WriteLog "E" "The file '$ResolvedFilePath' does not exist!" $LogFile
            Exit 1
        }
 
        # Check if the installation file exists
        if (! (Test-Path $File) ) {    
            DS_WriteLog "E" "The file '$File' does not exist!" $LogFile
            Exit 1
        }
    
        # Check if custom arguments were defined
        if ([string]::IsNullOrEmpty($Arguments)) {
            DS_WriteLog "I" "File arguments: <no arguments defined>" $LogFile
        }
        Else {
            DS_WriteLog "I" "File arguments: $Arguments" $LogFile
        }
 
        # Install the MSI or SETUP.exe
        DS_WriteLog "-" "" $LogFile
        DS_WriteLog "I" "Start the $Result2" $LogFile
        if ( $FileExt -eq "MSI" ) {
            if ( $Installationtype -eq "Uninstall" ) {
                $FixedArguments = "/x ""$File"" /qn /norestart /l*v ""$LogFileAPP"""
            }
            else {
                $FixedArguments = "/i ""$File"" /qn /norestart /l*v ""$LogFileAPP"""
            }
            if ([string]::IsNullOrEmpty($Arguments)) {
                # check if custom arguments were defined
                $arguments = $FixedArguments
                DS_WriteLog "I" "Command line: Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
            }
            Else {
                $arguments = $FixedArguments + " " + $arguments
                DS_WriteLog "I" "Command line: Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
            }
        }
        Else {
            if ([string]::IsNullOrEmpty($Arguments)) {
                # check if custom arguments were defined
                DS_WriteLog "I" "Command line: Start-Process -FilePath ""$File"" -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath "$File" -Wait -PassThru
            }
            Else {
                DS_WriteLog "I" "Command line: Start-Process -FilePath ""$File"" -ArgumentList $arguments -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath "$File" -ArgumentList $arguments -Wait -PassThru
            }
        }
 
        # Check the result (the exit code) of the installation
        switch ($Process.ExitCode) {        
            0 { DS_WriteLog "S" "The software was $Result1 successfully (exit code: 0)" $LogFile }
            3 { DS_WriteLog "S" "The software was $Result1 successfully (exit code: 3)" $LogFile } # Some Citrix products exit with 3 instead of 0
            1603 { DS_WriteLog "E" "A fatal error occurred (exit code: 1603). Some applications throw this error when the software is already (correctly) installed! Please check." $LogFile }
            1605 { DS_WriteLog "I" "The software is not currently installed on this machine (exit code: 1605)" $LogFile }
            1619 { 
                DS_WriteLog "E" "The installation files cannot be found. The PS1 script should be in the root directory and all source files in the subdirectory 'Files' (exit code: 1619)" $LogFile 
                Exit 1
            }
            3010 { DS_WriteLog "W" "A reboot is required (exit code: 3010)!" $LogFile }
            default { 
                [string]$ExitCode = $Process.ExitCode
                DS_WriteLog "E" "The $Result2 ended in an error (exit code: $ExitCode)!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ LOGGING                                              #
#                                                                         #
###########################################################################

#==========================================================================

# FUNCTION DS_WriteLog
#==========================================================================
Function DS_WriteLog {
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
        DS_WriteLog -InformationType "I" -Text "Copy files to C:\Temp" -LogFile "C:\Logs\MylogFile.log"
        Writes a line containing information to the log file
        .Example
        DS_WriteLog -InformationType "E" -Text "An error occurred trying to copy files to C:\Temp (error: $($Error[0]))!" -LogFile "C:\Logs\MylogFile.log"
        Writes a line containing error information to the log file
        .Example
        DS_WriteLog -InformationType "-" -Text "" -LogFile "C:\Logs\MylogFile.log"
        Writes an empty line to the log file
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][ValidateSet("I", "S", "W", "E", "-", IgnoreCase = $True)][String]$InformationType,
        [Parameter(Mandatory = $true, Position = 1)][AllowEmptyString()][String]$Text,
        [Parameter(Mandatory = $false, Position = 2)][String]$LogFile
    )
 
    begin {
    }
 
    process {
        # Create new log file (overwrite existing one should it exist)
        if (! (Test-Path $LogFile) ) {    
            # Note: the 'New-Item' cmdlet also creates any missing (sub)directories as well (works from W7/W2K8R2 to W10/W2K16 and higher)
            New-Item $LogFile -ItemType "file" -Force | Out-Null
        }

        $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss)
 
        if ( $Text -eq "" ) {
            Add-Content $LogFile -value ("") # Write an empty line
        }
        else {
            Add-Content $LogFile -value ($DateTime + " " + $InformationType.ToUpper() + " - " + $Text)
        }
        
        # Besides writing output to the log file also write it to the console
        #Write-host "$($InformationType.ToUpper()) - $Text"
        switch ($InformationType.ToUpper()) {
            "I" { Write-Host "$($InformationType.ToUpper()) - $Text" -ForegroundColor Yellow }
            "E" { Write-Host "$($InformationType.ToUpper()) - $Text" -ForegroundColor Red }
            "S" { Write-Host "$($InformationType.ToUpper()) - $Text" -ForegroundColor Green }
            "W" { Write-Host "$($InformationType.ToUpper()) - $Text" -ForegroundColor Blue }
            "-" { Write-Host "$($InformationType.ToUpper()) - $Text" }
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

# FUNCTION DS_CreateRegistryKey
#==========================================================================
Function DS_CreateRegistryKey {
    <#
        .SYNOPSIS
        Create a registry key
        .DESCRIPTION
        Create a registry key
        .PARAMETER RegKeyPath
        This parameter contains the registry path, for example 'hklm:\Software\MyApp'
        .EXAMPLE
        DS_CreateRegistryKey -RegKeyPath "hklm:\Software\MyApp"
        Creates the new registry key 'hklm:\Software\MyApp'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Create registry key '$RegKeyPath'" $LogFile
        if ( Test-Path $RegKeyPath ) {
            DS_WriteLog "I" "The registry key '$RegKeyPath' already exists. Nothing to do" $LogFile
        }
        else {
            try {
                New-Item -Path $RegkeyPath -Force | Out-Null
                DS_WriteLog "S" "The registry key '$RegKeyPath' was created successfully" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to create the registry key '$RegKeyPath' (exit code: $($Error[0]))!" $LogFile
                DS_WriteLog "I" "Note: define the registry path as follows: hklm:\Software\MyApp" $LogFile
                Exit 1
            }
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_DeleteRegistryKey
#==========================================================================
Function DS_DeleteRegistryKey {
    <#
        .SYNOPSIS
        Delete a registry key
        .DESCRIPTION
        Delete a registry key
        .PARAMETER RegKeyPath
        This parameter contains the registry path, for example 'hklm:\Software\MyApp'
        .EXAMPLE
        DS_DeleteRegistryKey -RegKeyPath "hklm:\Software\MyApp"
        Deletes the registry key 'hklm:\Software\MyApp'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Delete registry key $RegKeyPath" $LogFile
        if ( Test-Path $RegKeyPath ) {
            try {
                Remove-Item -Path $RegkeyPath -recurse | Out-Null
                DS_WriteLog "S" "The registry key $RegKeyPath was deleted successfully" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to delete the registry key $RegKeyPath (exit code: $($Error[0]))!" $LogFile
                DS_WriteLog "I" "Note: define the registry path as follows: hklm:\Software\MyApp" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The registry key $RegKeyPath does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_DeleteRegistryValue
#==========================================================================
Function DS_DeleteRegistryValue {
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
        DS_DeleteRegistryValue -RegKeyPath "hklm:\SOFTWARE\MyApp" -RegValueName "MyValue"
        Deletes the registry value 'MyValue' from the registry key 'hklm:\SOFTWARE\MyApp'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Parameter(Mandatory = $true, Position = 1)][String]$RegValueName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Delete registry value '$RegValueName' in '$RegKeyPath'" $LogFile

        # Check if the registry value that is to be renamed actually exists
        $RegValueExists = $False
        try {
            Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty $RegValueName | Out-Null
            $RegValueExists = $True
        }
        catch {
            DS_WriteLog "I" "The registry value '$RegValueName' in the registry key '$RegKeyPath' does NOT exist. Nothing to do" $LogFile
        }

        # Delete the registry value (if exist)
        if ( $RegValueExists -eq $True ) {
            try {
                Remove-ItemProperty -Path $RegKeyPath -Name $RegValueName | Out-Null
                DS_WriteLog "S" "The registry value '$RegValueName' in the registry key '$RegKeyPath' was deleted successfully" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to delete the registry value '$RegValueName' in the registry key '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                DS_WriteLog "I" "Note: define the registry path as follows: hklm:\SOFTWARE\MyApp" $LogFile
                Exit 1
            }
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_ImportRegistryFile
#==========================================================================
Function DS_ImportRegistryFile {
    <#
        .SYNOPSIS
        Import a registry (*.reg) file into the registry
        .DESCRIPTION
        Import a registry (*.reg) file into the registry
        .PARAMETER FileName
        This parameter contains the full path, file name and file extension of the registry file, for example "C:\Temp\MyRegFile.reg"
        .EXAMPLE
        DS_ImportRegistryFile -FileName "C:\Temp\MyRegFile.reg"
        Imports registry settings from the file "C:\Temp\MyRegFile.reg"
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$FileName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Import registry file '$FileName'" $LogFile
        if ( Test-Path $FileName ) {
            try {
                $process = start-process -FilePath "reg.exe" -ArgumentList "IMPORT ""$FileName""" -WindowStyle Hidden -Wait -PassThru
                if ( $process.ExitCode -eq 0 ) {
                    DS_WriteLog "S" "The registry settings were imported successfully (exit code: $($process.ExitCode))" $LogFile
                }
                else {
                    DS_WriteLog "E" "An error occurred trying to import registry settings (exit code: $($process.ExitCode))" $LogFile				
                    Exit 1
                }
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to import the registry file '$FileName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "E" "The file '$FileName' does NOT exist!" $LogFile
            Exit 1
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_RenameRegistryKey
#==========================================================================
Function DS_RenameRegistryKey {
    <#
        .SYNOPSIS
        Rename a registry key (for registry values use the function 'DS_RenameRegistryValue' instead)
        .DESCRIPTION
        Rename a registry key (for registry values use the function 'DS_RenameRegistryValue' instead)
        .PARAMETER RegKeyPath
        This parameter contains the registry path that needs to be renamed (for example 'hklm:\Software\MyRegKey')
        .PARAMETER NewName
        This parameter contains the new name of the last part of the registry path that is to be renamed (for example 'MyRegKeyNew')
        .EXAMPLE
        DS_RenameRegistryKey -RegKeyPath "hklm:\Software\MyRegKey" -NewName "MyRegKeyNew"
        Renames the registry path "hklm:\Software\MyRegKey" to "hklm:\Software\MyRegKeyNew". The parameter 'NewName' only requires the last part of the registry path without specifying the entire registry path
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Parameter(Mandatory = $true, Position = 1)][String]$NewName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Rename '$RegKeyPath' to '$NewName'" $LogFile

        # Rename the registry path (if exist)
        if ( Test-Path $RegKeyPath ) {
            try {
                Rename-Item -path $RegKeyPath -NewName $NewName | Out-Null
                DS_WriteLog "S" "The registry path '$RegKeyPath' was renamed to '$NewName' successfully" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to rename the registry path '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                DS_WriteLog "I" "Note: define the registry path as follows: hklm:\SOFTWARE\MyApp" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The registry path '$RegKeyPath' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_RenameRegistryValue
# Note: this function works for registry values only. To rename a registry key, use the function 'DS_RenameRegistryKey'.
#==========================================================================
Function DS_RenameRegistryValue {
    <#
        .SYNOPSIS
        Rename a registry value (all data types). To rename a registry key, use the function 'DS_RenameRegistryKey'
        .DESCRIPTION
        Rename a registry value (all data types). To rename a registry key, use the function 'DS_RenameRegistryKey'
        .PARAMETER RegKeyPath
        This parameter contains the full registry path (for example 'hklm:\SOFTWARE\MyApp')
        .PARAMETER RegValueName
        This parameter contains the name of the registry value that needs to be renamed (for example 'MyRegistryValue')
        .PARAMETER NewName
        This parameter contains the new name of the registry value that is to be renamed (for example 'MyRegistryValueNewName')
        .EXAMPLE
        DS_RenameRegistryValue -RegKeyPath "hklm:\Software\MyRegKey" -RegValueName "MyRegistryValue" -NewName "MyRegistryValueNewName"
        Renames the registry value 'MyRegistryValue' in the registry key "hklm:\Software\MyRegKey" to 'MyRegistryValueNewName'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Parameter(Mandatory = $true, Position = 1)][String]$RegValueName,
        [Parameter(Mandatory = $true, Position = 2)][String]$NewName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Rename the registry value '$RegValueName' in the registry key '$RegKeyPath' to '$NewName'" $LogFile

        # Check if the registry value that is to be renamed actually exists
        $RegValueExists = $False
        try {
            Get-ItemProperty -Path $RegKeyPath | Select-Object -ExpandProperty $RegValueName | Out-Null
            $RegValueExists = $True
        }
        catch {
            DS_WriteLog "I" "The registry value '$RegValueName' in the registry key '$RegKeyPath' does NOT exist. Nothing to do" $LogFile
        }

        # Rename the registry value (if exist)
        if ( $RegValueExists -eq $True ) {
            try {
                Rename-ItemProperty -Path $RegKeyPath -Name $RegValueName -NewName $NewName | Out-Null
                DS_WriteLog "S" "The registry value '$RegValueName' in the registry key '$RegKeyPath' was successfully renamed to '$NewName'" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to rename the registry value '$RegValueName' in the registry key '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_SetRegistryValue
#==========================================================================
Function DS_SetRegistryValue {
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
        DS_SetRegistryValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyStringValue" -RegValue "Enabled" -Type "String"
        Creates a new string value called 'MyStringValue' with the value of 'Enabled'
        .Example
        DS_SetRegistryValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyBinaryValue" -RegValue "01" -Type "Binary"
        Creates a new binary value called 'MyBinaryValue' with the value of '01'
        .Example
        DS_SetRegistryValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyDWORDValue" -RegValue "1" -Type "DWORD"
        Creates a new DWORD value called 'MyDWORDValue' with the value of 00000001 (or simply 1)
        .Example
        DS_SetRegistryValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyQWORDValue" -RegValue "1" -Type "QWORD"
        Creates a new QWORD value called 'MyQWORDValue' with the value of 1
        .Example
        DS_SetRegistryValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyMultiStringValue" -RegValue "Value1","Value2","Value3" -Type "MultiString"
        Creates a new multistring value called 'MyMultiStringValue' with the value of 'Value1 Value2 Value3'
        .Example
        DS_SetRegistryValue -RegKeyPath "hklm:\Software\MyApp" -RegValueName "MyExpandStringValue" -RegValue "MyValue" -Type "ExpandString"
        Creates a new expandstring value called 'MyExpandStringValue' with the value of 'MyValue'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$RegKeyPath,
        [Parameter(Mandatory = $true, Position = 1)][String]$RegValueName,
        [Parameter(Mandatory = $false, Position = 2)][String[]]$RegValue = "",
        [Parameter(Mandatory = $true, Position = 3)][String]$Type
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Set registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath" $LogFile

        # Create the registry key in case it does not exist
        if ( !( Test-Path $RegKeyPath ) ) {
            DS_CreateRegistryKey $RegKeyPath
        }
    
        # Create the registry value
        try {
            if ( ( "String", "ExpandString", "DWord", "QWord" ) -contains $Type ) {
                New-ItemProperty -Path $RegKeyPath -Name $RegValueName -Value $RegValue[0] -PropertyType $Type -Force | Out-Null
            }
            else {
                New-ItemProperty -Path $RegKeyPath -Name $RegValueName -Value $RegValue -PropertyType $Type -Force | Out-Null
            }
            DS_WriteLog "S" "The registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath was set successfully" $LogFile
        }
        catch {
            DS_WriteLog "E" "An error occurred trying to set the registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath" $LogFile
            DS_WriteLog "I" "Note: define the registry path as follows: hklm:\Software\MyApp" $LogFile
            Exit 1
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ SERVICES                                             #
#                                                                         #
###########################################################################

# FUNCTION DS_ChangeServiceStartupType
# Note: set/change the startup type of a service. Posstible options are: Boot, System, Automatic, Manual and Disabled
#==========================================================================
Function DS_ChangeServiceStartupType {
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
        DS_ChangeServiceStartupType -ServiceName "Spooler" -StartupType "Disabled"
        Disables the service 'Spooler' (display name: 'Print Spooler')
        .EXAMPLE
        DS_ChangeServiceStartupType -ServiceName "Spooler" -StartupType "Manual"
        Sets the startup type of the service 'Spooler' to 'manual' (display name: 'Print Spooler')
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$ServiceName,
        [Parameter(Mandatory = $true, Position = 1)][String]$StartupType
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Change the startup type of the service '$ServiceName' to '$StartupType'" $LogFile

        # Check if the service exists    
        If ( Get-Service $ServiceName -erroraction silentlycontinue) {
            # Change the startup type
            try {
                Set-Service -Name $ServiceName -StartupType $StartupType | out-Null
                DS_WriteLog "I" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
        else {
            DS_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_StopService
#==========================================================================
Function DS_StopService {
    <#
        .SYNOPSIS
        Stop a service (including depend services)
        .DESCRIPTION
        Stop a service (including depend services)
        .PARAMETER ServiceName
        This parameter contains the name of the service (not the display name!) to stop, for example 'Spooler' or 'TermService'. Depend services are stopped automatically as well.
        Depend services do not need to be specified separately. The function will retrieve them automatically.
        .EXAMPLE
        DS_StopService -ServiceName "Spooler"
        Stops the service 'Spooler' (display name: 'Print Spooler')
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$ServiceName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Stop service '$ServiceName' ..." $LogFile

        # Check if the service exists    
        If ( Get-Service $ServiceName -erroraction silentlycontinue) {
            # Stop the main service 
            If ( ((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
        
                # Check for depend services and stop them first
                DS_WriteLog "I" "Check for depend services for service '$ServiceName' and stop them" $LogFile
                $DependServices = ( ( Get-Service -Name $ServiceName -ErrorAction SilentlyContinue ).DependentServices ).name

                If ( $DependServices.Count -gt 0 ) {
                    foreach ( $Service in $DependServices ) {
                        DS_WriteLog "I" "Depend service found: $Service" $LogFile
                        DS_StopService -ServiceName $Service
                    }
                }
                else {
                    DS_WriteLog "I" "No depend service found" $LogFile
                }

                # Stop the (depend) service
                try {
                    Stop-Service $ServiceName | out-Null
                }
                catch {
                    DS_WriteLog "E" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Check if the service stopped successfully
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Stopped" ) {
                    DS_WriteLog "I" "The service $ServiceName was stopped successfully" $LogFile
                }
                else {
                    DS_WriteLog "E" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            }
            else {
                DS_WriteLog "I" "The service '$ServiceName' is not running" $LogFile
            }
        }
        else {
            DS_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_StartService
#==========================================================================
Function DS_StartService {
    <#
        .SYNOPSIS
        Starts a service (including depend services)
        .DESCRIPTION
        Starts a service (including depend services)
        .PARAMETER ServiceName
        This parameter contains the name of the service (not the display name!) to start, for example 'Spooler' or 'TermService'. Depend services are started automatically as well.
        Depend services do not need to be specified separately. The function will retrieve them automatically.
        .EXAMPLE
        DS_StartService -ServiceName "Spooler"
        Starts the service 'Spooler' (display name: 'Print Spooler')
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$ServiceName
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Start service $ServiceName ..." $LogFile

        # Check if the service exists    
        If ( Get-Service $ServiceName -erroraction silentlycontinue) {
            # Start the main service 
            If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                DS_WriteLog "I" "The service $ServiceName is already running" $LogFile
            }
            else {
                # Check for depend services and start them first
                DS_WriteLog "I" "Check for depend services for service $ServiceName and start them" $LogFile
                $DependServices = ( ( Get-Service -Name $ServiceName -ErrorAction SilentlyContinue ).DependentServices ).name

                If ( $DependServices.Count -gt 0 ) {
                    foreach ( $Service in $DependServices ) {
                        DS_WriteLog "I" "Depend service found: $Service" $LogFile
                        StartService($Service)
                    }
                }
                else {
                    DS_WriteLog "I" "No depend service found" $LogFile
                }

                # Start the (depend) service
                try {
                    Start-Service $ServiceName | out-Null
                }
                catch {
                    DS_WriteLog "E" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Check if the service started successfully
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                    DS_WriteLog "I" "The service $ServiceName was started successfully" $LogFile
                }
                else {
                    DS_WriteLog "E" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            }
        }
        else {
            DS_WriteLog "I" "The service $ServiceName does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ SYSTEM                                               #
#                                                                         #
###########################################################################

#==========================================================================

# FUNCTION DS_ReassignDriveLetter
# Note: reassign the drive letter of a specific drive (e.g. change Z: to M:)
#==========================================================================
Function DS_ReassignDriveLetter {
    <#
        .SYNOPSIS
        Re-assign an existing drive letter to a new drive letter
        .DESCRIPTION
        Re-assign an existing drive letter to a new drive letter
        .PARAMETER CurrentDriveLetter
        This parameter contains the drive letter that needs to be re-assigned
        .PARAMETER NewDriveLetter
        This parameter contains the new drive letter that needs to be assigned to the current drive letter
        .EXAMPLE
        DS_ReassignDriveLetter -CurrentDriveLetter "D:" -NewDriveLetter "Z:"
        Re-assigns drive letter D: to drive letter Z:
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$CurrentDriveLetter,
        [Parameter(Mandatory = $true, Position = 1)][String]$NewDriveLetter
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Reassign drive $CurrentDriveLetter to $NewDriveLetter" $LogFile

        $CurrentDriveLetter = $CurrentDriveLetter.Replace("\", "") # Remove the trailing backslash (in case it exists)
        $Drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$CurrentDriveLetter'"
        if ( [string]::IsNullOrEmpty($Drive) ) {
            DS_WriteLog "I" "Drive $CurrentDriveLetter cannot be found. Nothing to do" $LogFile
        }
        else {
            try {
                Set-WmiInstance -input $Drive -Arguments @{DriveLetter = $NewDriveLetter } | Out-Null
                DS_WriteLog "S" "Drive $CurrentDriveLetter has been successfully reassigned to $NewDriveLetter" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to reassign drive $CurrentDriveLetter to $NewDriveLetter (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_RenameVolumeLabel
# Note: rename the label (name) of a specific volume
#==========================================================================
Function DS_RenameVolumeLabel {
    <#
        .SYNOPSIS
        Rename the volume label of an existing volume
        .DESCRIPTION
        Rename the volume label of an existing volume
        .PARAMETER DriveLetter
        This parameter contains the drive letter of the volume that needs to be renamed
        .PARAMETER NewVolumeLabel
        This parameter contains the new name for the volume
        .EXAMPLE
        DS_RenameVolumeLabel -DriveLetter "C:" -NewVolumeLabel "SYSTEM"
        Renames the volume connected to drive C: to 'SYSTEM'
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory = $true, Position = 0)][String]$DriveLetter,
        [Parameter(Mandatory = $true, Position = 1)][String]$NewVolumeLabel
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Rename volume label of drive $DriveLetter to '$NewVolumeLabel'" $LogFile

        $DriveLetter = $DriveLetter.Replace("\", "") # Remove the trailing backslash (in case it exists)
    
        # Retrieve drive information
        try {
            $Drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$DriveLetter'"
            $CurrentLabel = $Drive.Label
        }
        catch {
            DS_WriteLog "E" "An error occurred trying to retrieve drive information from drive $DriveLetter (error: $($Error[0]))!" $LogFile
            Exit 1
        }

        # Rename volume label
        if ( $CurrentLabel -eq $NewVolumeLabel ) {       
            DS_WriteLog "I" "The drive label is already set to $NewVolumeLabel. Nothing to do" $LogFile
        }
        else {
            try {
                Set-WmiInstance -input $Drive -Arguments @{Label = $NewVolumeLabel } | Out-Null
                DS_WriteLog "S" "The volume label of drive $DriveLetter has been renamed to '$NewVolumeLabel'" $LogFile
            }
            catch {
                DS_WriteLog "E" "An error occurred trying to rename the volume label of drive $DriveLetter to '$NewVolumeLabel' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_ClearPrefetchFolder
#==========================================================================
Function DS_ClearPrefetchFolder {
    <#
        .SYNOPSIS
        Clear all files from the Windows Prefetch folder.
        .DESCRIPTION
        This function deletes all files in the Windows Prefetch folder without removing the folder itself.
        .EXAMPLE
        DS_ClearPrefetchFolder
        Clears all files in the Prefetch folder.
    #>
    [CmdletBinding()]
    Param()

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
        $PrefetchFolder = "C:\Windows\Prefetch"
        DS_WriteLog "I" "Target folder: $PrefetchFolder" $LogFile
    }

    process {
        # Check if the Prefetch folder exists
        if (!(Test-Path $PrefetchFolder)) {
            DS_WriteLog "E" "The Prefetch folder does not exist at the path: $PrefetchFolder" $LogFile
            Exit 1
        }

        # Get all files in the Prefetch folder
        $Files = Get-ChildItem -Path $PrefetchFolder -File

        # Delete each file
        if ($Files.Count -gt 0) {
            DS_WriteLog "I" "Found $($Files.Count) files to delete" $LogFile
            foreach ($File in $Files) {
                try {
                    Remove-Item -Path $File.FullName -Force
                    DS_WriteLog "S" "Deleted file: $($File.FullName)" $LogFile
                }
                catch {
                    DS_WriteLog "E" "Failed to delete file: $($File.FullName). Error: $_" $LogFile
                }
            }
        }
        else {
            DS_WriteLog "I" "No files found in the Prefetch folder" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================

# FUNCTION DS_StartStopProcess
#==========================================================================
Function DS_StartStopProcess {
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
        DS_StartStopProcess -ProcessName "notepad" -Action "Start"
        Starts the notepad process.
        .EXAMPLE
        DS_StartStopProcess -ProcessName "notepad" -Action "Stop"
        Stops the notepad process.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$ProcessName,
        [Parameter(Mandatory = $true)][ValidateSet('Start', 'Stop')][string]$Action
    )

    begin {
        # Start function logging
        DS_WriteLog "I" "START FUNCTION - DS_StartStopProcesss" $LogFile
        DS_WriteLog "I" "Process Name: $ProcessName" $LogFile
        DS_WriteLog "I" "Action: $Action" $LogFile
    }

    process {
        try {
            if ($Action -eq "Start") {
                # Start the process
                DS_WriteLog "I" "Starting process $ProcessName" $LogFile
                Start-Process -FilePath $ProcessName -ErrorAction Stop
                DS_WriteLog "S" "Process $ProcessName started successfully." $LogFile
            }
            elseif ($Action -eq "Stop") {
                # Stop the process
                $Process = Get-Process -Name $ProcessName -ErrorAction Stop
                if ($Process) {
                    DS_WriteLog "I" "Stopping process $ProcessName" $LogFile
                    Stop-Process -Name $ProcessName -Force -ErrorAction Stop
                    DS_WriteLog "S" "Process $ProcessName stopped successfully." $LogFile
                }
            }
        }
        catch {
            DS_WriteLog "E" "Error during $Action of process $ProcessName. Error: $_" $LogFile
            throw
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - Start-StopProcess" $LogFile
    }
}

#==========================================================================
# FUNCTION DS_JoinPath
#==========================================================================
Function DS_JoinPath {
    <#
        .SYNOPSIS
        Combines multiple paths into a single path.
        .DESCRIPTION
        This function combines two or more paths into a single path using Join-Path.
        .PARAMETER Paths
        An array of paths to be combined. Each path segment should be provided as a string.
        .EXAMPLE
        DS_JoinPath -Path "C:\Temp", "SubFolder", "File.txt"
        Returns: "C:\Temp\SubFolder\File.txt"
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String[]]$Path
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Initialize the combined path with the first path
        $CombinedPath = $Path[0]

        # Combine each path in the array
        For ($i = 1; $i -lt $Path.Length; $i++) {
            $CombinedPath = Join-Path -Path $CombinedPath -ChildPath $Path[$i]
        }

        DS_WriteLog "S" "Combined path result: '$CombinedPath'" $LogFile
        Write-Output $CombinedPath
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================
# FUNCTION DS_CheckPathExist
#==========================================================================
Function DS_CheckPathExist {
    <#
        .SYNOPSIS
        Checks if a specified path exists.
        .DESCRIPTION
        This function checks whether a given file or directory path exists using Test-Path.
        .PARAMETER Path
        The path to be checked.
        .EXAMPLE
        DS_CheckPathExist -Path "C:\Temp\MyFile.txt"
        Returns: True if the path exists, False otherwise.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][String]$Path
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        DS_WriteLog "I" "Checking if the path '$Path' exists" $LogFile
        $PathExists = Test-Path -Path $Path

        if ($PathExists) {
            DS_WriteLog "S" "The path '$Path' exists." $LogFile
        } else {
            DS_WriteLog "W" "The path '$Path' does not exist." $LogFile
        }

        Write-Output $PathExists
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

#==========================================================================
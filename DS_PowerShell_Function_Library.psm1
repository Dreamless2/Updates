#==========================================================================
#
# DENNIS SPAN (DS) POWERSHELL FUNCTION LIBRARY
#
# Version: v1.0.0 (published on 29.05.2018)
#
# Function Library change log:       http://dennisspan.com/powershell-function-library-change-log
# Documentation (Windows functions): http://dennisspan.com/powershell-functions-for-windows
# Documentation (Citrix functions):  http://dennisspan.com/powershell-functions-for-citrix
#
# AUTHOR: Dennis Span (http://dennisspan.com)
# DATE  : 29.05.2018
#
#
# COMMENT: This module file (*.PSM1) contains all functions required for the various PowerShell scripts (*.PS1) on Dennisspan.com
#          To be able to use these functions in a PowerShell script, the following steps are required:
#
#          1) Copy this file on your local server, e.g. to the folder 'C:\Scripts'
#          2) Add the following command to the beginning of the script: Import-Module "C:\Scripts\DS_PowerShell_Function_Library.psm1"
#
#          Another way to use these functions is as follows:
#          1) Copy this file on your local server, e.g. to the folder 'C:\Scripts'
#          2) Add the path 'C:\Scripts' to the environment variable PSModulePath
#          3) Add the following command to the beginning of the script: Import-Module DS_PowerShell_Function_Library
#
#
# List of all functions in this script:
# -------------------------------------
# -Windows functions
#     -Certificates
#       -DS_BindCertificateToIISPort          -> Bind a certificate to an IIS port
#       -DS_InstallCertificate                -> Install a certificate
#     -Files and folders
#       -DS_CleanupDirectory                  -> Delete files in a directory
#       -DS_CompactDirectory                  -> Compact a directory (using the Microsoft 'compact.exe')
#       -DS_CopyFile                          -> Copy a file or multiple files
#       -DS_CreateDirectory                   -> Create a directory
#       -DS_DeleteDirectory                   -> Delete a directory
#       -DS_DeleteFile                        -> Delete a file
#       -DS_RenameItem                        -> Rename a file or registry value
#     -Firewall
#       -DS_CreateFirewallRule                -> Create a new local firewall rule (using NetSh for W2K8R2 and PowerShell for newer operating systems)
#     -Installations and executables
#       -DS_ExecuteProcess                    -> Start a process
#       -DS_InstallOrUninstallSoftware        -> Install or uninstall software
#     -Logging
#       -DS_ClearAllMainEventLogs             -> Clear the contents of the main event logs
#       -DS_WriteLog                          -> Write log file
#       -DS_WriteToEventLog                   -> Write an entry into the Windows event log
#     -Miscellaneous
#       -DS_SendMail                          -> Send an e-mail
#     -Printing
#       -DS_InstallPrinterDriver              -> Install a printer driver
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
#       -DS_DeleteScheduledTask               -> Delete a scheduled task (in any of the folders including subfolders)
#       -DS_GetAllScheduledTaskSubFolders     -> Only to be used in combination with the function DS_DeleteScheduledTask
#       -DS_ReassignDriveLetter               -> Reassign a drive letter to a different letter
#       -DS_RenameVolumeLabel                 -> Rename a volume label
# -Citrix functions
#     -Provisioning Server
#       -DS_CreatePVSAuthGroup                -> Create a new Provisioning Server authorization group
#       -DS_GrantPVSAuthGroupAdminRights      -> Grant an existing Provisioning Server authorization group farm, site or collection admin rights
#    -StoreFront
#       -DS_CreateStoreFrontStore             -> Create a single-site or multi-site StoreFront deployment, stores, farms and the Authentication, Receiver for Web and PNAgent services
#
# Change log:
# -----------
# <DATE> <NAME>: <CHANGE DESCRIPTION>    
#==========================================================================

# define Error handling
# note: do not change these values
$global:ErrorActionPreference = "Stop"
if($verbose){ $global:VerbosePreference = "Continue" }

# Set default log directory (in case the variable $LogFile has not been defined)
if ( ([string]::IsNullOrEmpty($LogFile)) -Or ($LogFile.Length -eq 0) ) {
    $LogDir = "C:\Logs"
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
#          WINDOWS \ CERTIFICATES                                         #
#                                                                         #
###########################################################################

# Function DS_BindCertificateToIISPort
#==========================================================================
# Reference: https://weblog.west-wind.com/posts/2016/Jun/23/Use-Powershell-to-bind-SSL-Certificates-to-an-IIS-Host-Header-Site#BindtheWebSitetotheHostHeaderIP
Function DS_BindCertificateToIISPort {
    <#
        .SYNOPSIS
        Bind a certificate to an IIS port
        .DESCRIPTION
        Bind a certificate to an IIS port
        .PARAMETER URL
        [Mandatory] This parameter contains the URL (e.g. apps.myurl.com) of the certificate
        If this parameter contains the prefix 'http://' or 'https://' or any suffixes, these are automatically deleted
        .PARAMETER Port
        [Optional] This parameter contains the port of the IIS site to which the certificate should be bound (e.g. 443)
        If this parameter is omitted, the value 443 is used
        .EXAMPLE
        DS_BindCertificateToIISSite -URL "myurl.com" -Port 443
        Binds the certificate containing the URL 'myurl.com' to port 443. The function automatically determines the hash value of the certificate
        .EXAMPLE
        DS_BindCertificateToIISSite -URL "anotherurl.com" -Port 12345
        Binds the certificate containing the URL 'anotherurl.com' to port 12345. The function automatically determines the hash value of the certificate
    #>
    [CmdletBinding()]  
	param (
        [Parameter(Mandatory=$True)]
        [string]$URL,
        [Parameter(Mandatory=$True)]
        [int]$Port = 443
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }

    process {
        # Import the PowerShell module 'WebAdministration' for IIS
        try {
            Import-Module WebAdministration
        } catch {
            DS_WriteLog "E" "An error occurred trying to import the PowerShell module 'WebAdministration' for IIS (error: $($Error[0]))!" $LogFile
            Exit 1
        }

        # Retrieve the domain name of the host base URL
        if ( $URL.StartsWith("http") ) {
            [string]$Domain = ([System.URI]$URL).host                                     # Retrieve the domain name from the URL. For example: if the host base URL is "http://apps.mydomain.com/folder/", using the data type [System.URI] and the property "host", the resulting value would be "www.mydomain.com"
        } else {
            [string]$Domain = $URL                                                        # Retrieve the domain name from the URL. For example: if the host base URL is "http://apps.mydomain.com/folder/", using the data type [System.URI] and the property "host", the resulting value would be "www.mydomain.com"
        }

        # Retrieve the certificate hash value
        DS_WriteLog "I" "Retrieve the hash value of the certificate for the host base URL '$URL' (check for the domain name '$Domain')" $LogFile
        try {
            If ( $Domain.StartsWith("*") ) {
                $Hash = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -match "\*.$($Domain)" } | Select-Object -First 1).Thumbprint
            } else {
                $Hash = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -like "*$Domain*" } | Select-Object -First 1).Thumbprint
            }
        } catch {
            DS_WriteLog "E" "An error occurred trying to retrieve the certificate hash value (error: $($Error[0]))!" $LogFile
            Exit 1
        }

        #  Check the hash value. In case it does not exist, try to see if perhaps a wildcard certificate or SAN certificate is installed
        if ( !($Hash) ) {
            DS_WriteLog "I" "A hash value for a certificate with the subject name '$Domain' could not be retrieved. You may be using a wildcard or a SAN certificate" $LogFile
            [string[]]$Domain = $Domain.Split(".")                                         # Split the domain name on the dot (.)
            [string]$Domain = "$($Domain[-2]).$($Domain[-1])"                              # Read the last two items in the newly created array to retrieve the root level domain name (in our example this would be "mydomain.com")
            DS_WriteLog "I" "Let's try to retrieve the hash value for a certificate with the domain name '*.$($Domain)'" $LogFile
            try {
                $Hash = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -match "\*.$($Domain)" } | Select-Object -First 1).Thumbprint
            } catch {
                DS_WriteLog "E" "An error occurred trying to retrieve the certificate hash value (error: $($Error[0]))!" $LogFile
                Exit 1
            }
            if ( !($Hash) ) {
                DS_WriteLog "E" "The hash value could not be retrieved. The most likely cause is that the certificate for the host base URL '$URL' is not installed." $LogFile
                Exit 1
            } else {
                DS_WriteLog "S" "The hash value of the certificate for the host base URL '$URL' is $Hash" $LogFile
            }
        } else {
            DS_WriteLog "S" "The hash value of the certificate for the host base URL '$URL' is $Hash" $LogFile
        }

        # Bind the certificate to the IIS site   
        DS_WriteLog "I" "Bind the certificate to the IIS site" $LogFile
        try {
            Get-Item iis:\sslbindings\* | where { $_.Port -eq $Port } | Remove-Item
            Get-Item "cert:\LocalMachine\MY\$Hash" | New-Item "iis:\sslbindings\0.0.0.0!$Port" | Out-Null
            DS_WriteLog "S" "The certificate with hash $Hash was successfully bound to port $Port" $LogFile
        } catch {
            DS_WriteLog "E" "An error occurred trying to bind the certificate with hash $Hash to port $Port (error: $($Error[0]))!" $LogFile
            Exit 1
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# Function DS_InstallCertificate
#==========================================================================
# The following main certificate stores exist:
# -"CA" = Intermediate Certificates Authorities
# -"My" = Personal
# -"Root" = Trusted Root Certificates Authorities
# -"TrustedPublisher" = Trusted Publishers
# Note: to find the names of all existing certificate stores, use the following PowerShell command: Get-Childitem cert:\localmachine
# Note: to secure passwords in a PowerShell script, see my article http://dennisspan.com/encrypting-passwords-in-a-powershell-script/
Function DS_InstallCertificate {
    <#
        .SYNOPSIS
        Install a certificate
        .DESCRIPTION
        Install a certificate
        .PARAMETER StoreScope
        This parameter determines whether the local machine or the current user store is to be used (possible values are: CurrentUser | LocalMachine)
        .PARAMETER StoreName
        This parameter contains the name of the store (possible values are: CA | My | Root | TrustedPublisher and more)
        .PARAMETER CertFile
        This parameter contains the name, including path and file extension, of the certificate file (e.g. C:\MyCert.cer)
        .PARAMETER CertPassword
        This parameter is optional and is required in case the exported certificate is password protected. The password has to be parsed as a secure-string
        For more information see the article 'http://dennisspan.com/encrypting-passwords-in-a-powershell-script/'
        .EXAMPLE
        DS_InstallCertificate -StoreScope "LocalMachine" -StoreName "Root" -CertFile "C:\Temp\MyRootCert.cer"
        Installs the root certificate 'MyRootCert.cer' in the Trusted Root Certificates Authorities store of the local machine
        .EXAMPLE
        DS_InstallCertificate -StoreScope "LocalMachine" -StoreName "CA" -CertFile "C:\Temp\MyIntermediateCert.cer"
        Installs the intermediate certificate 'MyIntermediateCert.cer' in the Intermediate Certificates Authorities store of the local machine
        .EXAMPLE
        $Password = "mypassword" | ConvertTo-SecureString -AsPlainText -Force
        DS_InstallCertificate -StoreScope "LocalMachine" -StoreName "My" -CertFile "C:\Temp\MyServerCert.pfx" -CertPassword $Password
        Installs the password protected certificate 'MyServerCert.pfx' in the Personal store of the local machine
        The password has to be parsed as a secure-string. See the article 'http://dennisspan.com/encrypting-passwords-in-a-powershell-script/' for more information
        .EXAMPLE
        $Password = "mypassword" | ConvertTo-SecureString -AsPlainText -Force
        DS_InstallCertificate -StoreScope "CurrentUser" -StoreName "My" -CertFile "C:\Temp\MyUserCert.pfx" -CertPassword $Password
        Installs the password protected certificate 'MyUserCert.pfx' in the Personal store of the current user
        The password has to be parsed as a secure-string. See the article 'http://dennisspan.com/encrypting-passwords-in-a-powershell-script/' for more information
    #>
    [CmdletBinding()]  
	param (
		[parameter(mandatory=$True,Position=1)]
		[string] $StoreScope,
		[parameter(mandatory=$True,Position=2)]
		[string] $StoreName,
		[parameter(mandatory=$True,Position=3)]  
		[string] $CertFile,
        [parameter(mandatory=$False,Position=4)]  
		[SecureString] $CertPassword
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        # Store translation table (used for logging only)
        switch ($StoreName)
        {
            "CA" { $StoreNameForLogging = "Intermediate Certificates Authorities" }
            "My" { $StoreNameForLogging = "Personal" }
            "Root" { $StoreNameForLogging = "Trusted Root Certificates Authorities" }
            "TrustedPublisher" { $StoreNameForLogging = "Trusted Publishers" }
            default {
                $StoreNameForLogging = $StoreName
            }
        }

        # Determine OS
	    DS_WriteLog "I" "Import the certificate '$CertFile' in the '$StoreScope' store '$StoreNameForLogging'" $LogFile
        $OSName = (Get-WmiObject Win32_OperatingSystem).Caption
        DS_WriteLog "I" "Operating system: $OSName" $LogFile

        # Install certificate        
        $Store = "cert:\$($StoreScope)\$($StoreName)"
        if ( Test-Path $Store ) {                                                                                                                      # Check if the store exists
            if ( Test-Path $CertFile ) {                                                                                                               # Check if the certificate file exists
                # This section only runs on Windows 10/2016 server and higher
                [int]$WindowsVersion = ([environment]::OSVersion.Version).Major                                                                        # Check the windows version
                if ( $WindowsVersion -ge 10 ) {                                                                                                        # If the version equals 10 or higher this means that the OS is W10 / W2K16 or higher
                    # For a PFX file, a different PowerShell cmdlet is used than for a non-PFX file
                    if ( $CertFile.Substring($CertFile.length -4,4) -eq ".pfx" ) {                                                                     # Check if the current certificate file is a PFX file (this type of certificate contains a private key)
                        # Import the certificate
                        try {
                            DS_WriteLog "I" "Import the PFX certificate using the 'Import-PfxCertificate' cmdlet (for systems running W10/W2K16 and higher)" $LogFile
                            Import-PfxCertificate -FilePath $CertFile -CertStoreLocation "Cert:\$($StoreScope)\$($StoreName)" -Password $CertPassword | Out-Null
                            DS_WriteLog "S" "The certificate '$CertFile' was imported successfully in the '$StoreScope' store '$StoreNameForLogging'" $LogFile
                        } catch {
                            DS_WriteLog "E" "An error occurred trying to import the certificate '$CertFile' in the '$StoreScope' store '$StoreNameForLogging' (error: $($Error[0]))!" $LogFile
                            Exit 1
                        }
                    } else {
                        try {
                            DS_WriteLog "I" "Import the certificate using the 'Import-Certificate' cmdlet (for systems running W10/W2K16 and higher)" $LogFile
                            Import-Certificate -FilePath $CertFile -CertStoreLocation "Cert:\$($StoreScope)\$($StoreName)" | Out-Null
                            DS_WriteLog "S" "The certificate '$CertFile' was imported successfully in the '$StoreScope' store '$StoreNameForLogging'" $LogFile
                        } catch {
                            DS_WriteLog "E" "An error occurred trying to import the certificate '$CertFile' in the '$StoreScope' store '$StoreNameForLogging' (error: $($Error[0]))!" $LogFile
                            Exit 1
                        }
                    }
                } else {                                                                                                                                # Run the following code when the OS is lower than W10/W2K16
                    try {
                        DS_WriteLog "I" "Import the certificate using the 'X509Certificate' .Net class (not used for systems running W10/W2K16 and higher)" $LogFile
                        $Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $CertFile,$CertPassword
                        $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store $StoreName,$StoreScope
                        $Store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
                        $Store.Add($Cert)
                        $Store.Close()
                        DS_WriteLog "S" "The certificate '$CertFile' was imported successfully in the '$StoreScope' store '$StoreNameForLogging'" $LogFile
                    } catch {
                        DS_WriteLog "E" "An error occurred trying to import the certificate '$CertFile' in the '$StoreScope' store '$StoreNameForLogging' (error: $($Error[0]))!" $LogFile
                        DS_WriteLog "I" "An unknown error may be the result of an incorrect password!" $LogFile
                        Exit 1
                    }
                }
            } else {
                DS_WriteLog "E" "The certificate file '$CertFile' does not exist. This script will now quit" $LogFile
                Exit 1
            }
        } else {
            DS_WriteLog "E" "The store '$Store' does not exist. This script will now quit" $LogFile
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
		[Parameter(Mandatory=$true, Position = 0)][String]$Directory
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
            } catch {
                DS_WriteLog "E" "An error occurred trying to delete files and subfolders in the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
           DS_WriteLog "I" "The directory $Directory does not exist. Nothing to do" $LogFile
        }
    }

    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# FUNCTION DS_CompactDirectory
# Description: compress files in a specific directory
#==========================================================================
Function DS_CompactDirectory {
    <#
        .SYNOPSIS
        Execute a process
        .DESCRIPTION
        Execute a process
        .PARAMETER Directory
        This parameter contains the full path to the directory that needs to be compacted (for example C:\Windows\WinSxS)
        .EXAMPLE
        DS_CompactDirectory -Directory "C:\Windows\WinSxS"
        Compacts the directory 'C:\Windows\WinSxS'
    #>
    [CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position = 0)][String]$Directory
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Compress files in the directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            try {
                $params = " /C /S /I /Q /F $($Directory)\*"
                start-process "$WinDir\System32\compact.exe" $params -WindowStyle Hidden -Wait
                DS_WriteLog "S" "Successfully compressed all files in the directory $Directory" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to compress the files in the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
           DS_WriteLog "I" "The directory $Directory does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$SourceFiles,
        [Parameter(Mandatory=$true, Position = 1)][String]$Destination
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
        } else {
            $TempFolder = $Destination
        }

        # Check if the destination path exists. If not, create it.
        DS_WriteLog "I" "Check if the destination path '$TempFolder' exists. If not, create it" $LogFile
        if ( Test-Path $TempFolder) {
            DS_WriteLog "I" "The destination path '$TempFolder' already exists. Nothing to do" $LogFile
        } else {
            DS_WriteLog "I" "The destination path '$TempFolder' does not exist" $LogFile
            DS_CreateDirectory -Directory $TempFolder
        }

        # Copy the source files
        DS_WriteLog "I" "Start copying the source file(s) '$SourceFiles' to '$Destination'" $LogFile
        try {
            Copy-Item $SourceFiles -Destination $Destination -Force -Recurse
            DS_WriteLog "S" "Successfully copied the source files(s) '$SourceFiles' to '$Destination'" $LogFile
        } catch {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$Directory
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Create directory $Directory" $LogFile
        if ( Test-Path $Directory ) {
            DS_WriteLog "I" "The directory $Directory already exists. Nothing to do" $LogFile
        } else {
            try {
                New-Item -ItemType Directory -Path $Directory -force | Out-Null
                DS_WriteLog "S" "Successfully created the directory $Directory" $LogFile
            } catch {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$Directory
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
            } catch {
                DS_WriteLog "E" "An error occurred trying to delete the directory $Directory (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
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
        Deletes all files in the directory "C:\Temp". This function does NOT remove any subfolders nor files within a subfolder (use the function 'DS_CleanupDirectory' instead)
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$true, Position = 0)][String]$File
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
            } catch {
                DS_WriteLog "E" "An error occurred trying to delete the file '$File' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
           DS_WriteLog "I" "The file '$File' does not exist. Nothing to do" $LogFile
        }
    }
 
    end {
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
        This parameter contains the full path to the file or folder that needs to be renamed (for example 'C:\Temp\MyOldFileName.txt' or 'C:\Temp\MyOldFolderName')
        .PARAMETER NewName
        This parameter contains the new name of the file or folder (for example 'MyNewFileName.txt' or 'MyNewFolderName')
        .EXAMPLE
        DS_RenameItem -ItemPath "C:\Temp\MyOldFileName.txt" -NewName "MyNewFileName.txt"
        Renames the file "C:\Temp\MyOldFileName.txt" to "MyNewFileName.txt". The parameter 'NewName' only requires the new file name without specifying the path to the file
        .EXAMPLE
        DS_RenameItem -ItemPath "C:\Temp\MyOldFileName.txt" -NewName "MyNewFileName.rtf"
        Renames the file "C:\Temp\MyOldFileName.txt" to "MyNewFileName.rtf". Besides changing the name of the file, the file extension is modified as well. Please make sure that the new file format is compatible with the original file format and can actually be opened after being renamed! The parameter 'NewName' only requires the new file name without specifying the path to the file
        .EXAMPLE
        DS_RenameItem -ItemPath "C:\Temp\MyOldFolderName" -NewName "MyNewFolderName"
        Renames the folder "C:\Temp\MyOldFolderName" to "C:\Temp\MyNewFolderName". The parameter 'NewName' only requires the new folder name without specifying the path to the folder
    #>
    [CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position = 0)][String]$ItemPath,
	    [Parameter(Mandatory=$true, Position = 1)][String]$NewName
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
            } catch {
                DS_WriteLog "E" "An error occurred trying to rename the item '$ItemPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
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
#          WINDOWS \ FIREWALL                                             #
#                                                                         #
###########################################################################

# FUNCTION DS_CreateFirewallRule
#==========================================================================
Function DS_CreateFirewallRule {
    <#
        .SYNOPSIS
        Create a local firewall rule on the local server
        .DESCRIPTION
        Create a local firewall rule on the local server. On Windows Server 2008 (R2) the NetSh command
        is used. For operating systems from Windows Server 2012 and later, the PowerShell cmdlet 
        'New-NetFirewallRule' is used. The firewall profile is automatically set to 'any'.
        .PARAMETER Name
        This parameter contains the name of the firewall rule (the name must be unique and cannot be 'All').
        The parameter name is used for both the 'name' as well as the 'display name'.
        .PARAMETER Description
        This parameter contains the description of the firewall rule. The description can be an empty string.
        .PARAMETER Ports
        This parameter contains the port or ports which should be allowed or denied. Possible notations are:
            Example 1: 80,81,82,90,93
            Example 2: 80-82,90,93
        .PARAMETER Protocol
        This parameter contains the name of the protocol. The most used options are 'TCP' or 'UDP', but more options are available.
        .PARAMETER Direction
        This parameter contains the direction. Possible options are 'Inbound' or 'Outbound'.
        .PARAMETER Action
        This parameter contains the action. Possible options are 'Allow' or 'Block'.
        .EXAMPLE
        DS_CreateFirewallRule -Name "Citrix example firewall rules" -Description "Examples firewall rules for Citrix" -Ports "80-82,99" -Protocol "UDP" -Direction "Inbound" -Action "Allow"
        Creates an inbound firewall rule for the UDP protocol
    #>
    [CmdletBinding()]
	Param( 
        [Parameter(Mandatory=$true, Position = 0)][String]$Name,
        [Parameter(Mandatory=$true, Position = 1)][AllowEmptyString()][String]$Description,
        [Parameter(Mandatory=$true, Position = 2)][String]$Ports,
        [Parameter(Mandatory=$true, Position = 3)][String]$Protocol,
        [Parameter(Mandatory=$true, Position = 4)][ValidateSet("Inbound","Outbound",IgnoreCase = $True)][String]$Direction,
        [Parameter(Mandatory=$true, Position = 5)][ValidateSet("Allow","Block",IgnoreCase = $True)][String]$Action
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Create the firewall rule '$Name' ..." $LogFile
        DS_WriteLog "I" "Parameters:" $LogFile
        DS_WriteLog "I" "-Name: $Name" $LogFile
        DS_WriteLog "I" "-Description: $Description" $LogFile
        DS_WriteLog "I" "-Ports: $Ports" $LogFile
        DS_WriteLog "I" "-Protocol: $Protocol" $LogFile
        DS_WriteLog "I" "-Direction: $Direction" $LogFile
        DS_WriteLog "I" "-Action: $Action" $LogFile

        [string]$WindowsVersion = ( Get-WmiObject -class Win32_OperatingSystem ).Version
        if ( ($WindowsVersion -like "*6.1*") -Or ($WindowsVersion -like "*6.0*") ) {
            # Configure the local firewall using the NetSh command if the operating system is Windows Server 2008 (R2)
            if ( $Direction -eq "Inbound" ) { $DirectionNew = "In" }
            if ( $Direction -eq "Outbound" ) { $DirectionNew = "Out" }
            DS_WriteLog "I" "The operating system is Windows Server 2008 (R2). Use the Netsh command to configure the firewall." $LogFile
            DS_WriteLog "I" "Check if the firewall rule '$Name' already exists." $LogFile
            try {
                [string]$Rule = netsh advfirewall firewall show rule name=$Name
                if ( $Rule.Contains("No rules match") ) {
                    DS_WriteLog "I" "The firewall rule '$Name' does not exist." $LogFile
                    DS_WriteLog "I" "Create the firewall rule '$Name' ..." $LogFile
                    try {
                        netsh advfirewall firewall add rule name=$Name description=$Description localport=$Ports protocol=$Protocol dir=$DirectionNew action=$Action | Out-Null
                        DS_WriteLog "S" "The firewall rule '$Name' was created successfully" $LogFile
                    } catch  {
                        DS_WriteLog "E" "An error occurred trying to create the firewall rule '$Name' (error: $($Error[0]))!" $LogFile
                        Exit 1
                    }
                } else {
                    DS_WriteLog "I" "The firewall rule '$Name' already exists. Nothing to do" $LogFile
                }
            } catch {
                DS_WriteLog "E" "An error occurred trying to check the firewall rule '$Name' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
            # Configure the local firewall using PowerShell if the operating system is Windows Server 2012 or higher
            DS_WriteLog "I" "The operating system is Windows Server 2012 or higher. Use PowerShell to configure the firewall." $LogFile
            DS_WriteLog "I" "Check if the firewall rule '$Name' already exists." $LogFile
            if ( (Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue) -Or (Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue)) {
	            DS_WriteLog "I" "The firewall rule '$Name' already exists. Nothing to do" $LogFile
            } else {
                DS_WriteLog "I" "The firewall rule '$Name' does not exist." $LogFile
                DS_WriteLog "I" "Create the firewall rule '$Name' ..." $LogFile
                [array]$Ports = $Ports.split(',')  # Convert the string value $Ports to an array (required by the PowerShell cmdlet 'New-NetFirewallRule')
                try {
	                New-NetFirewallRule -Name $Name -DisplayName $Name -Description $Description -LocalPort $Ports -Protocol $Protocol -Direction $Direction -Action $Action | Out-Null
                    DS_WriteLog "S" "The firewall rule '$Name' was created successfully" $LogFile
                } catch  {
                    DS_WriteLog "E" "An error occurred trying to create the firewall rule '$Name' (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
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
        This parameter contains the list of arguments to be executed together with the executable
        .EXAMPLE
        DS_ExecuteProcess -FileName "C:\Temp\MyApp.exe" -Arguments "-silent"
        Executes the file 'MyApp.exe' with arguments '-silent'
    #>
    [CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position = 0)][String]$FileName,
	    [Parameter(Mandatory=$true, Position = 1)][String]$Arguments
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Execute process '$Filename' with arguments '$Arguments'" $LogFile
        $Process = Start-Process $FileName -ArgumentList $Arguments -wait -NoNewWindow -PassThru
        $Process.HasExited
        $ProcessExitCode = $Process.ExitCode
        if ( $ProcessExitCode -eq 0 ) {
            DS_WriteLog "S" "The process '$Filename' with arguments '$Arguments' ended successfully" $LogFile
        } else {
            DS_WriteLog "E" "An error occurred trying to execute the process '$Filename' with arguments '$Arguments' (exit code: $ProcessExitCode)!" $LogFile
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
        [Parameter(Mandatory=$true, Position = 0)][String]$File,
        [Parameter(Mandatory=$true, Position = 1)][AllowEmptyString()][String]$Installationtype,
        [Parameter(Mandatory=$true, Position = 2)][AllowEmptyString()][String]$Arguments
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
    
    process {
        $FileName = ($File.Split("\"))[-1]
        $FileExt = $FileName.SubString(($FileName.Length)-3,3)
 
        # Prepare variables
        if ( !( $FileExt -eq "MSI") ) { $FileExt = "SETUP" }
        if ( $Installationtype -eq "Uninstall" ) {
            $Result1 = "uninstalled"
            $Result2 = "uninstallation"
        } else {
            $Result1 = "installed"
            $Result2 = "installation"
        }
        $LogFileAPP = Join-path $LogDir ( "$($Installationtype)_$($FileName.Substring(0,($FileName.Length)-4))_$($FileExt).log" )
     
        # Logging
        DS_WriteLog "I" "File name: $FileName" $LogFile
        DS_WriteLog "I" "File full path: $File" $LogFile
 
        # Check if the installation file exists
        if (! (Test-Path $File) ) {    
            DS_WriteLog "E" "The file '$File' does not exist!" $LogFile
            Exit 1
        }
    
        # Check if custom arguments were defined
        if ([string]::IsNullOrEmpty($Arguments)) {
            DS_WriteLog "I" "File arguments: <no arguments defined>" $LogFile
        } Else {
            DS_WriteLog "I" "File arguments: $Arguments" $LogFile
        }
 
        # Install the MSI or SETUP.exe
        DS_WriteLog "-" "" $LogFile
        DS_WriteLog "I" "Start the $Result2" $LogFile
        if ( $FileExt -eq "MSI" ) {
            if ( $Installationtype -eq "Uninstall" ) {
                $FixedArguments = "/x ""$File"" /qn /norestart /l*v ""$LogFileAPP"""
            } else {
                $FixedArguments = "/i ""$File"" /qn /norestart /l*v ""$LogFileAPP"""
            }
            if ([string]::IsNullOrEmpty($Arguments)) {   # check if custom arguments were defined
                $arguments = $FixedArguments
                DS_WriteLog "I" "Command line: Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
            } Else {
                $arguments =  $FixedArguments + " " + $arguments
                DS_WriteLog "I" "Command line: Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru
            }
        } Else {
            if ([string]::IsNullOrEmpty($Arguments)) {   # check if custom arguments were defined
                DS_WriteLog "I" "Command line: Start-Process -FilePath ""$File"" -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath "$File" -Wait -PassThru
            } Else {
                DS_WriteLog "I" "Command line: Start-Process -FilePath ""$File"" -ArgumentList $arguments -Wait -PassThru" $LogFile
                $process = Start-Process -FilePath "$File" -ArgumentList $arguments -Wait -PassThru
            }
        }
 
        # Check the result (the exit code) of the installation
        switch ($Process.ExitCode)
        {        
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

# FUNCTION DS_ClearAllMainEventLogs
#==========================================================================
Function DS_ClearAllMainEventLogs() {
    <#
        .SYNOPSIS
        Clear all main event logs
        .DESCRIPTION
        Clear all main event logs
        .EXAMPLE
        DS_ClearAllMainEventLogs
        Loops through all event logs on the local system and clears (deletes) all entries in each of the logs founds
    #>
    [CmdletBinding()]
	Param( 
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Clear all main event logs" $LogFile
    
        # Retrieve all event logs on the current system
        $EventlogList = Get-EventLog -List

        Foreach ($EventLog in $EventlogList) {
            $EventLogName = $EventLog.Log
            DS_WriteLog "I" "Clear the event log $EventLogName" $LogFile
            try {
                Clear-EventLog -LogName $EventLogName | Out-Null
                DS_WriteLog "S" "The event log $EventLogName was cleared successfully" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to clear the event log $EventLogName (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
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
        [Parameter(Mandatory=$true, Position = 0)][ValidateSet("I","S","W","E","-",IgnoreCase = $True)][String]$InformationType,
        [Parameter(Mandatory=$true, Position = 1)][AllowEmptyString()][String]$Text,
        [Parameter(Mandatory=$false, Position = 2)][String]$LogFile
    )
 
    begin {
    }
 
    process {
        # Create new log file (overwrite existing one should it exist)
        if (! (Test-Path $LogFile) ) {    
            # Note: the 'New-Item' cmdlet also creates any missing (sub)directories as well (works from W7/W2K8R2 to W10/W2K16 and higher)
            New-Item $LogFile -ItemType "file" -force | Out-Null
        }

        $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss)
 
        if ( $Text -eq "" ) {
            Add-Content $LogFile -value ("") # Write an empty line
        } else {
            Add-Content $LogFile -value ($DateTime + " " + $InformationType.ToUpper() + " - " + $Text)
        }
        
        # Besides writing output to the log file also write it to the console
        Write-host "$($InformationType.ToUpper()) - $Text"
    }
 
    end {
    }
}
#==========================================================================

# FUNCTION DS_WriteToEventLog
#==========================================================================
Function DS_WriteToEventLog {
    <#
        .SYNOPSIS
        Write an entry into the Windows event log. New event logs as well as new event sources are automatically created.
        .DESCRIPTION
        Write an entry into the Windows event log. New event logs as well as new event sources are automatically created.
        .PARAMETER EventLog
        This parameter contains the name of the event log the entry should be written to (e.g. Application, Security, System or a custom one)
        .PARAMETER Source
        This parameter contains the source (e.g. 'MyScript')
        .PARAMETER EventID
        This parameter contains the event ID number (e.g. 3000)
        .PARAMETER Type
        This parameter contains the type of message. Possible values are: Information | Warning | Error
        .PARAMETER Message
        This parameter contains the event log description explaining the issue
        .Example
        DS_WriteToEventLog -EventLog "System" -Source "MyScript" -EventID "3000" -Type "Error" -Message "An error occurred"
        Write an error message to the System event log with the source 'MyScript' and event ID 3000. The unknown source 'MyScript' is automatically created
        .Example
        DS_WriteToEventLog -EventLog "Application" -Source "Something" -EventID "250" -Type "Information" -Message "Information: action completed successfully"
        Write an information message to the Application event log with the source 'Something' and event ID 250. The unknown source 'Something' is automatically created
        .Example
        DS_WriteToEventLog -EventLog "MyNewEventLog" -Source "MyScript" -EventID "1000" -Type "Warning" -Message "Warning. There seems to be an issue"
        Write an warning message to the event log called 'MyNewEventLog' with the source 'MyScript' and event ID 1000. The unknown event log 'MyNewEventLog' and source 'MyScript' are automatically created
    #>
    [CmdletBinding()]
    Param( 
        [parameter(mandatory=$True)]  
		[ValidateNotNullorEmpty()]
		[String]$EventLog,
        [parameter(mandatory=$True)]  
		[ValidateNotNullorEmpty()]
		[String]$Source,
		[parameter(mandatory=$True)]
		[Int]$EventID,
		[parameter(mandatory=$True)]
		[ValidateNotNullorEmpty()]
		[String]$Type,
		[parameter(mandatory=$True)]
		[ValidateNotNullorEmpty()]
		[String]$Message
	)
 
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        # Create a new event entry:
        DS_WriteLog "I" "Create a new event entry:" $LogFile
        DS_WriteLog "I" "-Event log: $EventLog" $LogFile
        DS_WriteLog "I" "-Source   : $Source" $LogFile
        DS_WriteLog "I" "-EventID  : $EventID" $LogFile
        DS_WriteLog "I" "-Type     : $Type" $LogFile
        DS_WriteLog "I" "-Message  : $Message" $LogFile
        
        # Check if the event log exist. If not, create it.
        DS_WriteLog "I" "Check if the event log $EventLog exists. If not, create it" $LogFile
        if ( !( [System.Diagnostics.EventLog]::Exists( $EventLog ) ) ) {
            DS_WriteLog "I" "The event log '$EventLog' does not exist" $LogFile
			try {
                New-EventLog -LogName $EventLog -Source $EventLog
                DS_WriteLog "I" "The event log '$EventLog' was created successfully" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the event log '$EventLog' (error: $($Error[0]))!" $LogFile

            }
		} else {
            DS_WriteLog "I" "The event log '$EventLog' already exists. Nothing to do" $LogFile
        }

        # Check if the event source exist. If not, create it.
        DS_WriteLog "I" "Check if the event source '$Source' exists. If not, create it" $LogFile
        if ( !( [System.Diagnostics.EventLog]::SourceExists( $Source ) ) ) {
            DS_WriteLog "I" "The event source '$Source' does not exist" $LogFile
			try {
                [System.Diagnostics.EventLog]::CreateEventSource( $Source, $EventLog )
                DS_WriteLog "I" "The event source '$Source' was created successfully" $LogFile	
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the event source '$Source' (error: $($Error[0]))!" $LogFile
            }
		} else {
            DS_WriteLog "I" "The event source '$Source' already exists. Nothing to do" $LogFile
        }
        		
		# Write the event log entry
        DS_WriteLog "I" "Write the event log entry" $LogFile   	
		try {
            Write-EventLog -LogName $EventLog -Source $Source -eventID $EventID -EntryType $Type -message $Message
            DS_WriteLog "I" "The event log entry was written successfully" $LogFile
        } catch {
            DS_WriteLog "E" "An error occurred trying to write the event log entry (error: $($Error[0]))!" $LogFile
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

###########################################################################
#                                                                         #
#          WINDOWS \ MISCELLANEOUS                                        #
#                                                                         #
###########################################################################

# FUNCTION DS_SendMail
#==========================================================================
Function DS_SendMail {
    <#
        .SYNOPSIS
        Send an e-mail to one or more recipients
        .DESCRIPTION
        Send an e-mail to one or more recipients
        .PARAMETER Sender
        This parameter contains the e-mail address of the sender (e.g. mymail@mydomain.com).
        .PARAMETER Recipients
        This parameter contains the e-mail address or addresses of the recipients (e.g. "<name>@mycompany.com" or "<name>@mycompany.com", "<name>@mycompany.com")
        .PARAMETER Subject
        This parameter contains the subject of the e-mail
        .PARAMETER Text
        This parameter contains the body (= content / text) of the e-mail
        .PARAMETER SMTPServer
        This parameter contains the name or the IP-address of the SMTP server (e.g. 'smtp.mycompany.com' or '192.168.0.110')
        .EXAMPLE
        DS_SendMail -Sender "me@mycompany.com" -Recipients "someone@mycompany.com" -Subject "Something important" -Text "This is the text for the e-mail" -SMTPServer "smtp.mycompany.com"
        Sends an e-mail to one recipient
        .EXAMPLE
        DS_SendMail -Sender "me@mycompany.com" -Recipients "someone@mycompany.com","someoneelse@mycompany.com" -Subject "Something important" -Text "This is the text for the e-mail" -SMTPServer "smtp.mycompany.com"
        Sends an e-mail to two recipients
        .EXAMPLE
        DS_SendMail -Sender "Dennis Span <me@mycompany.com>" -Recipients "someone@mycompany.com","someoneelse@mycompany.com" -Subject "Something important" -Text "This is the text for the e-mail" -SMTPServer "smtp.mycompany.com"
        Sends an e-mail to two recipients with the sender's name included in the sender's e-mail address
        .EXAMPLE
        DS_SendMail -Sender "Error report <me@mycompany.com>" -Recipients "someone@mycompany.com","someoneelse@mycompany.com" -Subject "Something important" -Text "This is the text for the e-mail" -SMTPServer "smtp.mycompany.com"
        Sends an e-mail to two recipients with a description included in the sender's e-mail address
    #>
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$true, Position = 0)][String]$Sender,
        [Parameter(Mandatory=$true, Position = 1)][String[]]$Recipients,
        [Parameter(Mandatory=$true, Position = 2)][String]$Subject,
        [Parameter(Mandatory=$true, Position = 3)][String]$Text,
        [Parameter(Mandatory=$true, Position = 4)][String]$SMTPServer
    )
 
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        # Send mail
        try {
            Send-MailMessage -From $Sender -to $Recipients -subject $Subject -body $Text -smtpServer $SMTPServer -BodyAsHtml
            DS_WriteLog "S" "E-mail successfully sent" $LogFile
            Exit 0
        } catch {
            DS_WriteLog "E" "An error occurred trying to send the e-mail (exit code: $($Error[0]))!" $LogFile
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
#          WINDOWS \ PRINTING                                             #
#                                                                         #
###########################################################################

# Function DS_InstallPrinterDriver
#==========================================================================
Function DS_InstallPrinterDriver {
    <#
        .SYNOPSIS
        Install a Windows printer driver
        .DESCRIPTION
        Install a Windows printer driver
        .PARAMETER Name
        This parameter contains the name of the printer driver as found in the accompanying INF file, for example "HP Universal Printing PCL 6 (v5.5.0)"
        .PARAMETER Path
        This parameter contains the path to the printer driver, for example "C:\Temp\PrinterDrivers\HP\UP_PCL6"
        .PARAMETER INF_Name
        This parameter contains the name of the INF file located within the directory defined in the variable 'Path', for example "hpcu130u.INF"
        .EXAMPLE
        DS_InstallPrinterDriver -Name "HP Universal Printing PCL 6 (v5.5.0)" -Path "C:\Temp\PrinterDrivers\HP\UP_PCL6" -INF_Name "hpcu130u.INF"
        Installs the printer driver 'HP Universal Printing PCL 6 (v5.5.0)' using the file in the directory 'C:\Temp\PrinterDrivers\HP\UP_PCL6'
    #>
    [CmdletBinding()]  
	param (
		[parameter(mandatory=$True,Position=1)]
		[IO.FileInfo] $Name,
		[parameter(mandatory=$True,Position=2)]
		[ValidateNotNullorEmpty()]  
		[string[]] $Path,
		[parameter(mandatory=$True,Position=3)]  
		[string] $INF_Name
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
	    DS_WriteLog "I" "Install printer driver $Name ($Path\$INF_Name)" $LogFile

        # Instal the printer driver
	    try {
		    $DriverClass = [WMIClass]"Win32_PrinterDriver"
		    $DriverClass.Scope.Options.EnablePrivileges = $true
		    $DriverObj = $DriverClass.createinstance()
		    $DriverObj.Name = $Name
		    $DriverObj.DriverPath= $Path
		    $DriverObj.Infname = Join-Path $Path $INF_Name
		    $ReturnValue = $DriverClass.AddPrinterDriver($driverobj)
		    $Null = $DriverClass.Put()
		    if ( $ReturnValue.ReturnValue -eq 0 ) {
                DS_WriteLog "S" "Successfully installed printer driver $Name" $LogFile
		    } else {
                DS_WriteLog "E" "An error occurred trying to install printer driver $Name (error: $($ReturnValue.ReturnValue))" $LogFile
			    Exit 1
		    }
	    } catch {
            DS_WriteLog "E" "An error occurred trying to install printer driver $Name (error: $($Error[0]))!" $LogFile
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
		[Parameter(Mandatory=$true, Position = 0)][String]$RegKeyPath
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Create registry key '$RegKeyPath'" $LogFile
        if ( Test-Path $RegKeyPath ) {
            DS_WriteLog "I" "The registry key '$RegKeyPath' already exists. Nothing to do" $LogFile
        } else {
            try {
                New-Item -Path $RegkeyPath -Force | Out-Null
		        DS_WriteLog "S" "The registry key '$RegKeyPath' was created successfully" $LogFile
	        }
	        catch{
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
		[Parameter(Mandatory=$true, Position = 0)][String]$RegKeyPath
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
	        catch{
                DS_WriteLog "E" "An error occurred trying to delete the registry key $RegKeyPath (exit code: $($Error[0]))!" $LogFile
                DS_WriteLog "I" "Note: define the registry path as follows: hklm:\Software\MyApp" $LogFile
                Exit 1
	        }
        } else {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$RegKeyPath,
		[Parameter(Mandatory=$true, Position = 1)][String]$RegValueName
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
        } catch {
            DS_WriteLog "I" "The registry value '$RegValueName' in the registry key '$RegKeyPath' does NOT exist. Nothing to do" $LogFile
        }

        # Delete the registry value (if exist)
        if ( $RegValueExists -eq $True ) {
            try {
                Remove-ItemProperty -Path $RegKeyPath -Name $RegValueName | Out-Null
                DS_WriteLog "S" "The registry value '$RegValueName' in the registry key '$RegKeyPath' was deleted successfully" $LogFile
            } catch {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$FileName
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
			    } else {
                    DS_WriteLog "E" "An error occurred trying to import registry settings (exit code: $($process.ExitCode))" $LogFile				
                    Exit 1
			    }
	        } catch {
                DS_WriteLog "E" "An error occurred trying to import the registry file '$FileName' (exit code: $($Error[0]))!" $LogFile
                Exit 1
	        }
        } else {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$RegKeyPath,
	    [Parameter(Mandatory=$true, Position = 1)][String]$NewName
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
            } catch {
                DS_WriteLog "E" "An error occurred trying to rename the registry path '$RegKeyPath' to '$NewName' (exit code: $($Error[0]))!" $LogFile
                DS_WriteLog "I" "Note: define the registry path as follows: hklm:\SOFTWARE\MyApp" $LogFile
                Exit 1
            }
        } else {
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
        Renames the registry value 'MyRegistryValue' in the registry key "hklm:\Software\MyRegKey" to 'MyRegistryValueNewName'
    #>
    [CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position = 0)][String]$RegKeyPath,
        [Parameter(Mandatory=$true, Position = 1)][String]$RegValueName,
	    [Parameter(Mandatory=$true, Position = 2)][String]$NewName
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
        } catch {
            DS_WriteLog "I" "The registry value '$RegValueName' in the registry key '$RegKeyPath' does NOT exist. Nothing to do" $LogFile
        }

        # Rename the registry value (if exist)
        if ( $RegValueExists -eq $True ) {
            try {
                Rename-ItemProperty -Path $RegKeyPath -Name $RegValueName -NewName $NewName | Out-Null
                DS_WriteLog "S" "The registry value '$RegValueName' in the registry key '$RegKeyPath' was successfully renamed to '$NewName'" $LogFile
            } catch {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$RegKeyPath,
		[Parameter(Mandatory=$true, Position = 1)][String]$RegValueName,
		[Parameter(Mandatory=$false, Position = 2)][String[]]$RegValue = "",
		[Parameter(Mandatory=$true, Position = 3)][String]$Type
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
	        } else {
		        New-ItemProperty -Path $RegKeyPath -Name $RegValueName -Value $RegValue -PropertyType $Type -Force | Out-Null
	        }
            DS_WriteLog "S" "The registry value $RegValueName = $RegValue (type $Type) in $RegKeyPath was set successfully" $LogFile
        } catch {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$ServiceName,
		[Parameter(Mandatory=$true, Position = 1)][String]$StartupType
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
            } catch {
                DS_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$ServiceName
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
            If  ( ((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
        
                # Check for depend services and stop them first
                DS_WriteLog "I" "Check for depend services for service '$ServiceName' and stop them" $LogFile
                $DependServices = ( ( Get-Service -Name $ServiceName -ErrorAction SilentlyContinue ).DependentServices ).name

                If ( $DependServices.Count -gt 0 ) {
                    foreach ( $Service in $DependServices ) {
                        DS_WriteLog "I" "Depend service found: $Service" $LogFile
                        DS_StopService -ServiceName $Service
                    }
                } else {
                    DS_WriteLog "I" "No depend service found" $LogFile
                }

                # Stop the (depend) service
                try {
                    Stop-Service $ServiceName | out-Null
                } catch {
                    DS_WriteLog "E" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Check if the service stopped successfully
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Stopped" ) {
                    DS_WriteLog "I" "The service $ServiceName was stopped successfully" $LogFile
                } else {
                    DS_WriteLog "E" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            } else {
                DS_WriteLog "I" "The service '$ServiceName' is not running" $LogFile
            }
        } else {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$ServiceName
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
            If  (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                DS_WriteLog "I" "The service $ServiceName is already running" $LogFile
            } else {
                # Check for depend services and start them first
                DS_WriteLog "I" "Check for depend services for service $ServiceName and start them" $LogFile
                $DependServices = ( ( Get-Service -Name $ServiceName -ErrorAction SilentlyContinue ).DependentServices ).name

                If ( $DependServices.Count -gt 0 ) {
                    foreach ( $Service in $DependServices ) {
                        DS_WriteLog "I" "Depend service found: $Service" $LogFile
                        StartService($Service)
                    }
                } else {
                    DS_WriteLog "I" "No depend service found" $LogFile
                }

                # Start the (depend) service
                try {
                    Start-Service $ServiceName | out-Null
                } catch {
                    DS_WriteLog "E" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Check if the service started successfully
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                    DS_WriteLog "I" "The service $ServiceName was started successfully" $LogFile
                } else {
                    DS_WriteLog "E" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            }
        } else {
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

# Function DS_GetAllScheduledTaskSubFolders and DS_DeleteScheduledTask
# Note:List all delete all scheduled tasks and delete the one specified in the parameter when the function is called
# Reference: Get scheduled tasks from remote computer
#            https://gallery.technet.microsoft.com/scriptcenter/Get-Scheduled-tasks-from-3a377294
#==========================================================================
Function DS_GetAllScheduledTaskSubFolders {
    <#
        .SYNOPSIS
        Get all scheduled tasks in all subfolders
        .DESCRIPTION
        Get all scheduled tasks in all subfolders
        .PARAMETER FolderRef
        This parameter contains the starting point (folder)
        .EXAMPLE
        DS_GetAllScheduledTaskSubFolders
        Retrieves all scheduled tasks in all subfolders
    #>
    [cmdletbinding()]
    param (
        # Set to use $Schedule as default parameter so it automatically list all files
        # For current schedule object if it exists.
        $FolderRef = $Schedule.getfolder("\")
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        if ($FolderRef.Path -eq '\') {
            $FolderRef
        }
        if (-not $RootFolder) {
            $ArrFolders = @()
            if(($Folders = $folderRef.getfolders(1))) {
                $Folders | ForEach-Object {
                    $ArrFolders += $_
                    if($_.getfolders(1)) {
                        DS_GetAllScheduledTaskSubFolders -FolderRef $_
                    }
                }
            }
            $ArrFolders
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}

Function DS_DeleteScheduledTask {
    <#
        .SYNOPSIS
        Delete a scheduled task
        .DESCRIPTION
        Delete a scheduled task
        .PARAMETER Name
        This parameter contains the name of the scheduled task that is to be deleted
        .EXAMPLE
        DS_DeleteScheduledTask -Name "GoogleUpdateTaskMachineCore"
        Deletes the scheduled task 'GoogleUpdateTaskMachineCore'
    #>
    [CmdletBinding()]
	Param( 
        [Parameter(Mandatory=$true, Position = 0)][String]$Name
    )

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Delete the scheduled task $Name" $LogFile
        try {
	        $Schedule = New-Object -ComObject 'Schedule.Service'
        } catch {
            DS_WriteLog "E" "An error occurred trying to create the Schedule.Service COM Object (error: $($Error[0]))!" $LogFile
            Exit 1
        }

        $Schedule.connect($env:ComputerName) 
        $AllFolders = DS_GetAllScheduledTaskSubFolders

        foreach ($Folder in $AllFolders) {
            if (($Tasks = $Folder.GetTasks(1))) {
                foreach ($Task in $Tasks) {
                    $TaskName = $Task.Name
                    #DS_WriteLog "I" "Task name (including folder): $($Folder.Name)\$($TaskName)" $LogFile
                    if ($TaskName -eq $Name) {
                        try {
                            $Folder.DeleteTask($TaskName,0)
                            DS_WriteLog "I" "The scheduled task $TaskName was deleted successfully" $LogFile
                        } catch {
                            DS_WriteLog "E" "An error occurred trying to delete the scheduled task $TaskName (error: $($Error[0]))!" $LogFile
                            Exit 1
                        }
                    }
                }
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
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
		[Parameter(Mandatory=$true, Position = 0)][String]$CurrentDriveLetter,
	    [Parameter(Mandatory=$true, Position = 1)][String]$NewDriveLetter
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Reassign drive $CurrentDriveLetter to $NewDriveLetter" $LogFile

        $CurrentDriveLetter = $CurrentDriveLetter.Replace("\","") # Remove the trailing backslash (in case it exists)
        $Drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$CurrentDriveLetter'"
        if ( [string]::IsNullOrEmpty($Drive) ) {
            DS_WriteLog "I" "Drive $CurrentDriveLetter cannot be found. Nothing to do" $LogFile
        } else {
            try {
                Set-WmiInstance -input $Drive -Arguments @{DriveLetter=”$NewDriveLetter”} | Out-Null
                DS_WriteLog "S" "Drive $CurrentDriveLetter has been successfully reassigned to $NewDriveLetter" $LogFile
            } catch {
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
		[Parameter(Mandatory=$true, Position = 0)][String]$DriveLetter,
	    [Parameter(Mandatory=$true, Position = 1)][String]$NewVolumeLabel
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Rename volume label of drive $DriveLetter to '$NewVolumeLabel'" $LogFile

        $DriveLetter = $DriveLetter.Replace("\","") # Remove the trailing backslash (in case it exists)
    
        # Retrieve drive information
        try {
            $Drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$DriveLetter'"
            $CurrentLabel = $Drive.Label
        } catch {
            DS_WriteLog "E" "An error occurred trying to retrieve drive information from drive $DriveLetter (error: $($Error[0]))!" $LogFile
            Exit 1
        }

        # Rename volume label
        if ( $CurrentLabel -eq $NewVolumeLabel ) {       
            DS_WriteLog "I" "The drive label is already set to $NewVolumeLabel. Nothing to do" $LogFile
        } else {
            try {
                Set-WmiInstance -input $Drive -Arguments @{Label=$NewVolumeLabel} | Out-Null
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

###########################################################################
#                                                                         #
#     CITRIX FUNCTIONS                                                    #
#                                                                         #
###########################################################################

###########################################################################
#                                                                         #
#     CITRIX \ PROVISIONING SERVICES                                      #
#                                                                         #
###########################################################################

# Function DS_CreatePVSAuthGroup
# Note: Create a new Provisioning Server authorization group
#==========================================================================
Function DS_CreatePVSAuthGroup {
    <#
        .SYNOPSIS
        Create a new Provisioning Server authorization group
        .DESCRIPTION
        Create a new Provisioning Server authorization group
        .PARAMETER GroupName
        This parameter contains the name of the Active Directory group which is to be added as an authorization group in the Provisioning Server farm.
        Please be aware that the notation "MyDomain\MyGroup" does not work! The string has be LDAP-like: MyDomain.com/MyOU/MyOU/MyGroup
        .EXAMPLE
        DS_CreatePVSAuthGroup -GroupName "company.com/AdminGroup/CTXFarmAdmins"
        Creates the authorization group 'company.com/AdminGroup/CTXFarmAdmins'
    #>
    [CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position = 0)][String]$GroupName
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        DS_WriteLog "I" "Create a new authorization group" $LogFile
        DS_WriteLog "I" "Group name: $GroupName" $LogFile
        try { 
            Get-PvsAuthGroup -Name $GroupName | Out-Null
            DS_WriteLog "I" "The authorization group '$GroupName' already exists. Nothing to do" $LogFile
        } catch {
            try {
                New-PvsAuthGroup -Name $GroupName | Out-Null
                DS_WriteLog "S" "The authorization group '$GroupName' has been created" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the authorization group '$Groupname' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

# Function DS_GrantPVSAuthGroupAdminRights
# Note: Grant an existing Provisioning Server authorization group farm, site or collection admin rights
#==========================================================================
Function DS_GrantPVSAuthGroupAdminRights {
    <#
        .SYNOPSIS
        Grant an existing Provisioning Server authorization group farm, site or collection admin rights
        .DESCRIPTION
        Grant an existing Provisioning Server authorization group farm, site or collection admin rights
        .PARAMETER GroupName
        This parameter contains the name of the existing Provisioning Server authorization group that is to be granted
        farm, site or collection admin rights. If the parameters 'Sitename' and 'CollectionName' are left empty, the
        authorization group is granted farm admin rights.
        Please be aware that the notation "MyDomain\MyGroup" does not work! The string has be LDAP-like: MyDomain.com/MyOU/MyOU/MyGroup
        .PARAMETER SiteName
        This parameter is optional and contains the site name. If only the site name is specified (without the CollectionName parameter),
        the Provisioning Server authorization group is granted site admin rights.
        .PARAMETER CollectionName
        This parameter is optional and contains the name of the collection. You also have to specify the site name if your want to grant
        collection admin rights.
        .EXAMPLE
        DS_GrantPVSAuthGroupAdminRights -GroupName "company.com/AdminGroup/CTXFarmAdmins"
        Grants the authorization group 'company.com/AdminGroup/CTXFarmAdmins' farm admin rights
        .EXAMPLE
        DS_GrantPVSAuthGroupAdminRights -GroupName "company.com/AdminGroup/CTXSiteAdmins" -SiteName "MySite"
        Grants the authorization group 'company.com/AdminGroup/CTXSiteAdmins' site admin rights
        .EXAMPLE
        DS_GrantPVSAuthGroupAdminRights -GroupName "company.com/AdminGroup/CTXCollectionAdmins" -SiteName "MySite" -CollectionName "MyCollection"
        Grants the authorization group 'company.com/AdminGroup/CTXCollectionAdmins' collection admin rights
    #>
    [CmdletBinding()]
	Param( 
		[Parameter(Mandatory=$true, Position = 0)][String]$GroupName,
		[Parameter(Mandatory=$false)][String]$SiteName,
		[Parameter(Mandatory=$false)][String]$CollectionName
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        # Before attempting to grant admin rights, make sure that the authorization group exists
        try {
            Get-PvsAuthGroup -Name $GroupName | Out-Null
        } catch {
            DS_CreatePVSAuthGroup -GroupName $GroupName
            DS_WriteLog "-" "" $LogFile
        }

        # Grant admin rights to the authorization group
        try {
            if ( ([string]::IsNullOrEmpty($SiteName)) -And ([string]::IsNullOrEmpty($CollectionName)) ) { 
                # Grant farm admin rights when both parameters 'SiteName' and 'CollectionName' are empty
                $result = "farm"
                DS_WriteLog "I" "Grant the authorization group '$GroupName' $result admin rights" $LogFile
                Grant-PvsAuthGroup -authGroupName $GroupName | Out-Null
            } Elseif ( !([string]::IsNullOrEmpty($CollectionName)) ) {
                # Grant collection admin rights when the parameter 'CollectionName' is NOT empty
                $result = "collection"
                DS_WriteLog "I" "Grant the authorization group '$GroupName' $result admin rights" $LogFile
                Grant-PvsAuthGroup -authGroupName $GroupName -SiteName $SiteName -CollectionName $CollectionName | Out-Null
            } Else {
                # Grant site admin rights in all other cases
                $result = "site"
                DS_WriteLog "I" "Grant the authorization group '$GroupName' $result admin rights" $LogFile
                Grant-PvsAuthGroup -authGroupName $GroupName -SiteName $SiteName | Out-Null
            }
            DS_WriteLog "S" "The authorization group '$GroupName' has been granted $result admin rights" $LogFile
        } catch {
            [string]$ErrorText = $Error[0]
            If ( $ErrorText.Contains("duplicate")) {
                DS_WriteLog "I" "The authorization group '$GroupName' already has been granted $result admin rights. Nothing to do" $LogFile
            } else {
                DS_WriteLog "E" "An error occurred trying to grant the authorization group '$GroupName' $result admin rights (error: $($Error[0]))!" $LogFile
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
#     CITRIX \ STOREFRONT                                                 #
#                                                                         #
###########################################################################

# Function DS_CreateStoreFrontStore
#==========================================================================
# Note: this function is based on the example script "SimpleDeployment.ps1" located in the following StoreFront installation subdirectory: "C:\Program Files\Citrix\Receiver StoreFront\PowerShellSDK\Examples".
Function DS_CreateStoreFrontStore {
    <#
        .SYNOPSIS
        Creates a single-site or multi-site StoreFront deployment, stores, farms and the Authentication, Receiver for Web and PNAgent services
        .DESCRIPTION
        Creates a single-site or multi-site StoreFront deployment, stores, farms and the Authentication, Receiver for Web and PNAgent services
        .PARAMETER FriendlyName
        [Optional] This parameter configures the friendly name of the store, for example "MyStore" or "Marketing"
        If this parameter is omitted, the script generates the friendly name automatically based on the farm name. For example, if the farm name is "MyFarm", the friendly name would be "Store - MyFarm" 
        .PARAMETER HostBaseUrl
        [Mandatory] This parameter determines the URL of the IIS site (the StoreFront "deployment"), for example "https://mysite.com" or "http://mysite.com"
        .PARAMETER CertSubjectName
        [Optional] This parameter determines the Certificate Subject Name of the certificate you want to bind to the IIS SSL port on the local StoreFront server
        Possible values are:
        -Local machine name: $($env:ComputerName).mydomain.local
        -Wilcard / Subject Alternative Name (SAN) certificate: *.mydomain.local or portal.mydomain.local
        If this parameter is omitted, the Certificate Subject Name will be automatically extracted from the host base URL.
        .PARAMETER AddHostHeaderToIISSiteBinding
        [Optional] This parameter determines whether the host base URl (the host name) is added to IIS site binding
        If this parameter is omitted, the value is set to '$false' and the host base URl (the host name) is NOT added to IIS site binding
        .PARAMETER IISSiteDir
        [Optional] This parameter contains the directory path to the IIS site. This parameter is only used in multiple deployment configurations whereby multiple IIS sites are created.
        If this parameter is omitted, a directory will be automatically generated by the script
        .PARAMETER Farmtype
        [Optional] This parameter determines the farm type. Possible values are: XenDesktop | XenApp | AppController | VDIinaBox.
        If this parameter is omitted, the default value "XenDesktop" is used
        .PARAMETER FarmName
        [Mandatory] This parameter contains the name of the farm within the store. The farm name should be unique within a store.
        .PARAMETER FarmServers
        [Mandatory] This parameter, which data type is an array, contains a list of farm servers (XML brokers or Delivery Controller). Enter the list comma separated (e.g. -FarmServers "Server1","Server2","Server3")
        .PARAMETER StoreVirtualPath
        [Optional] This parameter contains the partial path of the StoreFront store, for example: -StoreVirtualPath "/Citrix/MyStore" or -StoreVirtualPath "/Citrix/Store1".
        If this parameter is omitted, the default value "/Citrix/Store" is used
        .PARAMETER ReceiverVirtualPath
        [Optional] This parameter contains the partial path of the Receiver for Web site in the StoreFront store, for example: -ReceiverVirtualPath "/Citrix/MyStoreWeb" or -ReceiverVirtualPath "/Citrix/Store1ReceiverWeb". 
        If this parameter is omitted, the default value "/Citrix/StoreWeb" is used        
        .PARAMETER SSLRelayPort
        [Mandatory] This parameter contains the SSL Relay port (XenApp 6.5 only) used for communicating with the XenApp servers. Default value is 443 (HTTPS).
        .PARAMETER LoadBalanceServers
        [Optional] This parameter determines whether to load balance the Delivery Controllers or to use them in failover order (if specifying more than one server)
        If this parameter is omitted, the default value "$false" is used, which means that failover is used instead of load balancing
        .PARAMETER XMLPort
        [Optional] This parameter contains the XML service port used for communicating with the XenApp\XenDesktop servers. Default values are 80 (HTTP) and 443 (HTTPS), but you can also use other ports (depending on how you configured your XenApp/XenDesktop servers). 
        If this parameter is omitted, the default value 80 is used
        .PARAMETER HTTPPort
        [Optional] This parameter contains the port used for HTTP communication on the IIS site. The default value is 80, but you can also use other ports.
        If this parameter is omitted, the default value 80 is used.
        .PARAMETER HTTPSPort
        [Optional] This parameter contains the port used for HTTPS communication on the IIS site. If this value is not set, no HTTPS binding is created
        .PARAMETER TransportType
        [Optional] This parameter contains the type of transport to use for the XML service communication. Possible values are: HTTP | HTTPS | SSL
        If this parameter is omitted, the default value "HTTP" is used
        .PARAMETER EnablePNAgent
        [Mandatory] This parameter determines whether the PNAgent site is created and enabled. Possible values are: $True | $False
        If this parameter is omitted, the default value "$true" is used
        .PARAMETER PNAgentAllowUserPwdChange
        [Optional] This parameter determines whether the user is allowed to change their password on a PNAgent. Possible values are: $True | $False.
        Note: this parameter can only be used if the logon method for PNAgent is set to 'prompt'
        !! Only add this parameter when the parameter EnablePNAgent is set to $True
        If this parameter is omitted, the default value "$true" is used
        .PARAMETER PNAgentDefaultService
        [Optional] This parameter determines whether this PNAgent site is the default PNAgent site in the store. Possible values are: $True | $False.
        !! Only add this parameter when the parameter EnablePNAgent is set to $True
        If this parameter is omitted, the default value "$true" is used
        .PARAMETER LogonMethod
        [Optional] This parameter determines the logon method for the PNAgent site. Possible values are: Anonymous | Prompt | SSON | Smartcard_SSON | Smartcard_Prompt. Only one value can be used at a time. 
        !! Only add this parameter when the parameter EnablePNAgent is set to $True
        If this parameter is omitted, the default value "SSON" (Single Sign-On) is used
        .EXAMPLE
        DS_CreateStoreFrontStore -FriendlyName "MyStore"  -HostBaseUrl "https://myurl.com" -FarmName "MyFarm" -FarmServers "Server1","Server2" -EnablePNAgent $True
        Creates a basic StoreFront deployment, a XenDesktop store, farm, Receiver for Web site and a PNAgent site. The communication with the Delivery Controllers uses the default XML port 80 and transport type HTTP
        The above example uses only the 4 mandatory parameters and does not include any of the optional parameters
        In case the HostBaseUrl is different than an already configured one on the local StoreFront server, a new IIS site is automatically created
        .EXAMPLE
        DS_CreateStoreFrontStore -HostBaseUrl "https://myurl.com" -FarmName "MyFarm" -FarmServers "Server1","Server2" -StoreVirtualPath "/Citrix/MyStore" -ReceiverVirtualPath "/Citrix/MyStoreWeb" -XMLPort 443 -TransportType "HTTPS" -EnablePNAgent $True -PNAgentAllowUserPwdChange $False -PNAgentDefaultService $True -LogonMethod "Prompt"
        Creates a StoreFront deployment, a XenDesktop store, farm, Receiver for Web site and a PNAgent site. The communication with the Delivery Controllers uses port 443 and transport type HTTPS (please make sure that your Delivery Controller is listening on port 443!) 
        PNAgent users are not allowed to change their passwords and the logon method is "prompt" instead of the default SSON (= Single Sign-On).
        In case the HostBaseUrl is different than an already configured one on the local StoreFront server, a new IIS site is automatically created
        .EXAMPLE
        DS_CreateStoreFrontStore -HostBaseUrl "https://anotherurl.com" -FarmName "MyFarm" -FarmServers "Server1","Server2" -EnablePNAgent $False
        Creates a StoreFront deployment, a XenDesktop store, farm and Receiver for Web site, but DOES NOT create and enabled a PNAgent site. The communication with the Delivery Controllers uses the default XML port 80 and transport type HTTP.
        In case the HostBaseUrl is different than an already configured one on the local StoreFront server, a new IIS site is automatically created
    #>
    [CmdletBinding()]  
	param (
        [Parameter(Mandatory=$false)]
        [string]$FriendlyName,
        [Parameter(Mandatory=$true)]
        [string]$HostBaseUrl,
        [Parameter(Mandatory=$false)]
        [string]$CertSubjectName,
        [Parameter(Mandatory=$false)]
        [string]$AddHostHeaderToIISSiteBinding = $false,
        [Parameter(Mandatory=$false)]
        [string]$IISSiteDir,
        [Parameter(Mandatory=$false)]
        [ValidateSet("XenDesktop","XenApp","AppController","VDIinaBox")]
        [string]$FarmType = "XenDesktop",
        [Parameter(Mandatory=$true)]
        [string]$FarmName,
        [Parameter(Mandatory=$true)]
        [string[]]$FarmServers,
        [Parameter(Mandatory=$false)]
        [string]$StoreVirtualPath = "/Citrix/Store",
        [Parameter(Mandatory=$false)]
        [string]$ReceiverVirtualPath = "/Citrix/StoreWeb",
        [Parameter(Mandatory=$false)]
        [int]$SSLRelayPort,
        [Parameter(Mandatory=$false)]
        [bool]$LoadBalanceServers = $false,
        [Parameter(Mandatory=$false)]
        [int]$XMLPort = 80,
        [Parameter(Mandatory=$false)]
        [int]$HTTPPort = 80,
        [Parameter(Mandatory=$false)]
        [int]$HTTPSPort,
        [Parameter(Mandatory=$false)]
        [ValidateSet("HTTP","HTTPS","SSL")]
        [string]$TransportType = "HTTP",
        [Parameter(Mandatory=$true)]
        [bool]$EnablePNAgent = $true,
        [Parameter(Mandatory=$false)]
        [bool]$PNAgentAllowUserPwdChange = $true,
        [Parameter(Mandatory=$false)]
        [bool]$PNAgentDefaultService = $true,
        [Parameter(Mandatory=$false)]
        [ValidateSet("Anonymous","Prompt","SSON","Smartcard_SSON","Smartcard_Prompt")]
        [string]$LogonMethod = "SSON"
	)

    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        DS_WriteLog "I" "START FUNCTION - $FunctionName" $LogFile
    }
 
    process {
        # Import StoreFront modules. Required for versions of PowerShell earlier than 3.0 that do not support autoloading.
        DS_WriteLog "I" "Import StoreFront PowerShell modules:" $LogFile
        [string[]] $Modules = "WebAdministration","Citrix.StoreFront","Citrix.StoreFront.Stores","Citrix.StoreFront.Authentication","Citrix.StoreFront.WebReceiver"   # Four StoreFront modules are required in this function. They are listed here in an array and in the following 'foreach' statement each of these four is loaded
        Foreach ( $Module in $Modules) {
            try {
                DS_WriteLog "I" "   -Import the StoreFront PowerShell module $Module" $LogFile
                Import-Module $Module
                DS_WriteLog "S" "    The StoreFront PowerShell module $Module was imported successfully" $LogFile
            } catch {
                DS_WriteLog "E" "    An error occurred trying to import the StoreFront PowerShell module $Module (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        }

        DS_WriteLog "-" "" $LogFile

        # Modify variables and/or create new ones for logging
        [int]$SiteId            = 1
        [string]$HostName       = ([System.URI]$HostBaseUrl).host                                                # Get the hostname (required for the IIS site) without prefixes such as "http://" or "https:// and no suffixes such as trailing slashes (/). The contents of the variable '$HostBaseURL' will look like this: portal.mydomain.com
        [string]$HostBaseUrl    = "$(([System.URI]$HostBaseUrl).scheme)://$(([System.URI]$HostBaseUrl).host)"    # Retrieve the 'clean' URL (e.g. in case the host base URL contains trailing slashes or more). The contents of the variable '$HostBaseURL' will look like this: https://portal.mydomain.com.
        If ( !($CertSubjectName) ) { $CertSubjectNameTemp = "<use the host base URL>" } else { $CertSubjectNameTemp = $CertSubjectName }
        If ( $CertSubjectName.StartsWith("*") ) { $CertSubjectName.Replace("*", "\*") | Out-Null }               # In case the certificate subject name starts with a *, place a backslash in front of it (this is required for the regular e
        If ( $AddHostHeaderToIISSiteBinding -eq $true ) { $AddHostHeaderToIISSiteBindingTemp = "yes" }
        If ( $AddHostHeaderToIISSiteBinding -eq $false ) { $AddHostHeaderToIISSiteBindingTemp = "no" }
        [string]$IISSiteDirTemp = $IISSiteDir
        If ( [string]::IsNullOrEmpty($FriendlyName) ) { $FriendlyName = "Store - $($FarmName)" }
        If ( [string]::IsNullOrEmpty($IISSiteDir) ) { $IISSiteDirTemp = "Default: $env:SystemDrive\inetpub\wwwroot" }
        If ( $LoadBalanceServers -eq $true ) { $LoadBalanceServersTemp = "yes" }
        If ( $LoadBalanceServers -eq $false ) { $LoadBalanceServersTemp = "no (fail-over)" }
        If ( !($HTTPSPort) ) { $HTTPSPortTemp = "<no IIS HTTPS/SSL>" } else { $HTTPSPortTemp = $HTTPSPort}
        If ( $EnablePNAgent -eq $true ) { $EnablePNAgentTemp = "yes" }
        If ( $EnablePNAgent -eq $false ) { $EnablePNAgentTemp = "no" }
        If ( $PNAgentAllowUserPwdChange -eq $true ) { $PNAgentAllowUserPwdChangeTemp = "yes" }
        If ( $PNAgentAllowUserPwdChange -eq $false ) { $PNAgentAllowUserPwdChangeTemp = "no" }
        If ( $PNAgentDefaultService -eq $true ) { $PNAgentDefaultServiceTemp = "yes" }
        If ( $PNAgentDefaultService -eq $false ) { $PNAgentDefaultServiceTemp = "no" } 
        
        # Start logging     
        DS_WriteLog "I" "Create the StoreFront store with the following parameters:" $LogFile
        DS_WriteLog "I" "   -Friendly name                      : $FriendlyName" $LogFile
        DS_WriteLog "I" "   -Host base URL                      : $HostBaseUrl" $LogFile
        DS_WriteLog "I" "   -Certificate subject name           : $CertSubjectNameTemp" $LogFile
        DS_WriteLog "I" "   -Add host name to IIS site binding  : $AddHostHeaderToIISSiteBindingTemp" $LogFile
        DS_WriteLog "I" "   -IIS site directory                 : $IISSiteDirTemp" $LogFile
        DS_WriteLog "I" "   -Farm type                          : $FarmType" $LogFile
        DS_WriteLog "I" "   -Farm name                          : $FarmName" $LogFile
        DS_WriteLog "I" "   -Farm servers                       : $FarmServers" $LogFile
        DS_WriteLog "I" "   -Store virtual path                 : $StoreVirtualPath" $LogFile
        DS_WriteLog "I" "   -Receiver virtual path              : $receiverVirtualPath" $LogFile
        If ( $FarmType -eq "XenApp" ) {
            DS_WriteLog "I" "   -SSL relay port (XenApp 6.5 only)   : $SSLRelayPort" $LogFile
        }
        DS_WriteLog "I" "   -Load Balancing                     : $LoadBalanceServersTemp" $LogFile
        DS_WriteLog "I" "   -XML Port                           : $XMLPort" $LogFile
        DS_WriteLog "I" "   -HTTP Port                          : $HTTPPort" $LogFile
        DS_WriteLog "I" "   -HTTPS Port                         : $HTTPSPortTemp" $LogFile
        DS_WriteLog "I" "   -Transport type                     : $TransportType" $LogFile
        DS_WriteLog "I" "   -Enable PNAgent                     : $EnablePNAgentTemp" $LogFile
        DS_WriteLog "I" "   -PNAgent allow user change password : $PNAgentAllowUserPwdChangeTemp" $LogFile
        DS_WriteLog "I" "   -PNAgent set to default             : $PNAgentDefaultServiceTemp" $LogFile
        DS_WriteLog "I" "   -PNAgent logon method               : $LogonMethod" $LogFile

        DS_WriteLog "-" "" $LogFile

        # Check if the parameters match
        If ( ( $TransportType -eq "HTTPS" ) -And ( $XMLPort -eq 80 ) ) {
            DS_WriteLog "W" "The transport type is set to HTTPS, but the XML port was set to 80. Changing the port to 443" $LogFile
            Exit 0
        }
        If ( ( $TransportType -eq "HTTP" ) -And ( $XMLPort -eq 443 ) ) {
            DS_WriteLog "W" "The transport type is set to HTTP, but the XML port was set to 443. Changing the port to 80" $LogFile
            Exit 0
        }

        #############################################################################
        # Create a new deployment with the host base URL set in the variable $HostBaseUrl
        #############################################################################
        DS_WriteLog "I" "Create a new StoreFront deployment (URL: $($HostBaseUrl)) unless one already exists" $LogFile

        # Port bindings
        If ( !($HTTPSPort) ) {
            if ( $AddHostHeaderToIISSiteBinding -eq $false ) {
                $Bindings = @(
                    @{protocol="http";bindingInformation="*:$($HTTPPort):"}
                )
            } else {
                $Bindings = @(
                    @{protocol="http";bindingInformation="*:$($HTTPPort):$($HostName)"}
                )
            }
        } else {
            if ( $AddHostHeaderToIISSiteBinding -eq $false ) {
                $Bindings = @(
                    @{protocol="http";bindingInformation="*:$($HTTPPort):"},
                    @{protocol="https";bindingInformation="*:$($HTTPSPort):"}
                )
            } else {
                $Bindings = @(
                    @{protocol="http";bindingInformation="*:$($HTTPPort):$($HostName)"},
                    @{protocol="https";bindingInformation="*:$($HTTPSPort):$($HostName)"}
                )
            }
        }

        # Determine if the deployment already exists
        $ExistingDeployments = Get-STFDeployment
        if( !($ExistingDeployments) ) {
            DS_WriteLog "I" "No StoreFront deployment exists. Prepare IIS for the first deployment" $LogFile
        
            # Delete the bindings on the Default Web Site
            DS_WriteLog "I" "Delete the bindings on the Default Web Site" $LogFile
            try {
                Clear-ItemProperty "IIS:\Sites\Default Web Site" -Name bindings
                DS_WriteLog "S" "The bindings on the Default Web Site have been successfully deleted" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to delete the bindings on the Default Web Site (error: $($Error[0]))!" $LogFile
                Exit 1
            }

            # Create the bindings on the Default Web Site
            DS_WriteLog "I" "Create the bindings on the Default Web Site" $LogFile
            try {
                Set-ItemProperty "IIS:\Sites\Default Web Site" -Name bindings -Value $Bindings
                DS_WriteLog "S" "The bindings on the Default Web Site have been successfully created" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the bindings the Default Web Site (error: $($Error[0]))!" $LogFile
                Exit 1
            }

            DS_WriteLog "-" "" $LogFile

            # Bind the certificate to the IIS Site (only when an HTTPS port has been defined in the variable $HTTPSPort)
            If ( $HTTPSPort ) {
                if ( !($CertSubjectName) ) {
                    DS_BindCertificateToIISPort -URL $HostBaseUrl -Port $HTTPSPort
                } else {
                    DS_BindCertificateToIISPort -URL $CertSubjectName -Port $HTTPSPort
                }
                DS_WriteLog "-" "" $LogFile
            }
        
            # Create the first StoreFront deployment
            DS_WriteLog "I" "Create the first StoreFront deployment (this may take a couple of minutes)" $LogFile
            try {
                Add-STFDeployment -HostBaseUrl $HostbaseUrl -SiteId 1 -Confirm:$false                                                              # Create the first deployment on this server using the IIS default website (= site ID 1)
                DS_WriteLog "S" "The StoreFront deployment '$HostbaseUrl' on IIS site ID $SiteId has been successfully created" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the StoreFront deployment '$HostBaseUrl' (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {                                                                                                                                    # One or more deployments exists
            $ExistingDeploymentFound = $False
            Foreach ( $Deployment in $ExistingDeployments ) {                                                                                       # Loop through each deployment and check if the URL matches the one defined in the variable $HostbaseUrl
                if ($Deployment.HostbaseUrl -eq $HostBaseUrl) {                                                                                     # The deployment URL is the same as the one we want to add, so nothing to do
                    $SiteId = $Deployment.SiteId                                                                                                    # Set the value of the variable $SiteId to the correct IIS site ID
                    $ExistingDeploymentFound = $True
                    # The deployment exists and it is configured to the desired hostbase URL
                    DS_WriteLog "I" "A deployment has already been created with the hostbase URL '$HostBaseUrl' on this server and will be used (IIS site ID is $SiteId)" $LogFile
                }
            }

            # Create a new IIS site and StoreFront deployment in case existing deployments were found, but none matching the hostbase URL defined in the variable $HostbaseUrl
            If ( $ExistingDeploymentFound -eq $False ) {
                DS_WriteLog "I" "One or more deployments exist on this server, but all with a different host base URL" $LogFile
                DS_WriteLog "I" "A new IIS site will now be created which will host the host base URL '$HostBaseUrl' defined in variable `$HostbaseUrl" $LogFile

                # Generate a random, new directory for the new IIS site in case the directory was not specified in the variable $IISSiteDir 
                If ( [string]::IsNullOrEmpty($IISSiteDir) ) {                                                                                        # In case no directory for the new IIS site was specified in the variable $IISSiteDir, a new, random one must be created
                    DS_WriteLog "I" "No directory for the new IIS site was defined in variable `$HostbaseUrl. A new one will now be generated" $LogFile
                    DS_WriteLog "I" "Retrieve the list of existing IIS sites, identify the highest site ID, add 1 and use this number to generate a new IIS directory" $LogFile
                    $NewIISSiteNumber = ((((Get-ChildItem -Path IIS:\Sites).ID) | measure -Maximum).Maximum)+1                                       # Retrieve all existing IIS sites ('Get-ChildItem -Path IIS:\Sites'); list only one property, namely the site ID (ID); than use the Measure-Object (measure -Maximum) to get the highest site ID and add 1 to determine the new site ID
                    DS_WriteLog "S" "The new site ID is: $NewIISSiteNumber" $LogFile
                    $IISSiteDir = "$env:SystemDrive\inetpub\wwwroot$($NewIISSiteNumber)"                                                             # Set the directory for the new IIS site to "C:\inetpub\wwwroot#\" (# = the number of the new site ID retrieved in the previous line), for example "C:\inetpub\wwwroot2"   
                }

                DS_WriteLog "I" "The directory for the new IIS site is: $IISSiteDir" $LogFile

                # Create the directory for the new IIS site
                DS_WriteLog "I" "Create the directory for the new IIS site" $LogFile
                DS_CreateDirectory -Directory $IISSiteDir

                # Create the new IIS site
                DS_WriteLog "I" "Create the new IIS site" $LogFile
                try {
                    New-Item "iis:\Sites\$($FarmName)" -bindings $Bindings -physicalPath $IISSiteDir
                    DS_WriteLog "S" "The new IIS site for the URL '$HostbaseUrl' with site ID $SiteId has been successfully created" $LogFile
                } catch {
                    DS_WriteLog "E" "An error occurred trying to create the IIS site for the URL '$HostbaseUrl' with site ID $SiteId (error: $($Error[0]))!" $LogFile
                    Exit 1
                }

                # Retrieve the site ID of the new site
                DS_WriteLog "I" "Retrieve the site ID of the new site" $LogFile
                $SiteId = (Get-ChildItem -Path IIS:\Sites | Where-Object { $_.Name -like "*$FarmName*" }).ID
                DS_WriteLog "S" "The new site ID is: $SiteId" $LogFile

                DS_WriteLog "-" "" $LogFile

                # Bind the certificate to the IIS Site (only when an HTTPS port has been defined in the variable $HTTPSPort)
                If ( $HTTPSPort ) {
                    if ( !($CertSubjectName) ) {
                        DS_BindCertificateToIISPort -URL $HostBaseUrl -Port $HTTPSPort
                        } else {
                            DS_BindCertificateToIISPort -URL $CertSubjectName -Port $HTTPSPort
                        }
                    DS_WriteLog "-" "" $LogFile
                }

                # Create the StoreFront deployment
                try {
                    Add-STFDeployment -HostBaseUrl $HostBaseUrl -SiteId $SiteId -Confirm:$false                                                       # Create a new deployment on this server using the new IIS default website (= site ID #)
                    DS_WriteLog "S" "The StoreFront deployment '$HostBaseUrl' on IIS site ID $SiteId has been successfully created" $LogFile
                } catch {
                    DS_WriteLog "E" "An error occurred trying to create the StoreFront deployment '$HostBaseUrl' (error: $($Error[0]))!" $LogFile
                    Exit 1
                }
            }
        }

        DS_WriteLog "-" "" $LogFile

        #############################################################################
        # Determine the Authentication and Receiver virtual path to use based on the virtual path of the store defined in the variable '$StoreVirtualPath'
        # The variable '$StoreVirtualPath' is not mandatory. In case it is not defined, the default value '/Citrix/Store' is used.
        #############################################################################
        DS_WriteLog "I" "Set the virtual path for Authentication and Receiver:" $LogFile
        $authenticationVirtualPath = "$($StoreVirtualPath.TrimEnd('/'))Auth"
        DS_WriteLog "I" "   -Authentication virtual path is: $authenticationVirtualPath" $LogFile
        If ( [string]::IsNullOrEmpty($ReceiverVirtualPath) ) {                                                                                        # In case no directory for the Receiver for Web site was specified in the variable $ReceiverVirtualPath, a directory name will be automatically generated
            $receiverVirtualPath = "$($StoreVirtualPath.TrimEnd('/'))Web"
        }
        DS_WriteLog "I" "   -Receiver virtual path is: $receiverVirtualPath" $LogFile

        DS_WriteLog "-" "" $LogFile

        #############################################################################
        # Determine if the authentication service at the specified virtual path in the specific IIS site exists
        #############################################################################
        DS_WriteLog "I" "Determine if the authentication service at the path $authenticationVirtualPath in the IIS site $SiteId exists" $LogFile
        $authentication = Get-STFAuthenticationService -siteID $SiteId -VirtualPath $authenticationVirtualPath
        if ( !($authentication) ) {
            DS_WriteLog "I" "No authentication service exists at the path $authenticationVirtualPath in the IIS site $SiteId" $LogFile
            # Add an authentication service using the IIS path of the store appended with Auth
            DS_WriteLog "I" "Add the authentication service at the path $authenticationVirtualPath in the IIS site $SiteId" $LogFile
            try {
                $authentication = Add-STFAuthenticationService -siteID $SiteId -VirtualPath $authenticationVirtualPath
                DS_WriteLog "S" "The authentication service at the path $authenticationVirtualPath in the IIS site $SiteId was created successfully" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the authentication service at the path $authenticationVirtualPath in the IIS site $SiteId (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
            DS_WriteLog "I" "An authentication service already exists at the path $authenticationVirtualPath in the IIS site $SiteID and will be used" $LogFile
        }

        DS_WriteLog "-" "" $LogFile

        #############################################################################
        # Create store and farm
        #############################################################################
        DS_WriteLog "I" "Determine if the store service at the path $StoreVirtualPath in the IIS site $SiteId exists" $LogFile
        $store = Get-STFStoreService -siteID $SiteId -VirtualPath $StoreVirtualPath
        if ( !($store) ) {
            DS_WriteLog "I" "No store service exists at the path $StoreVirtualPath in the IIS site $SiteId" $LogFile
            DS_WriteLog "I" "Add a store that uses the new authentication service configured to publish resources from the supplied servers" $LogFile
            # Add a store that uses the new authentication service configured to publish resources from the supplied servers
            try {
                #If ( $FarmType -eq "XenApp" ) {
                    $store = Add-STFStoreService -FriendlyName $FriendlyName -siteID $SiteId -VirtualPath $StoreVirtualPath -AuthenticationService $authentication -FarmName $FarmName -FarmType $FarmType -Servers $FarmServers -SSLRelayPort $SSLRelayPort -LoadBalance $LoadbalanceServers -Port $XMLPort -TransportType $TransportType
                #} else {
                 #   $store = Add-STFStoreService -FriendlyName $FriendlyName -siteID $SiteId -VirtualPath $StoreVirtualPath -AuthenticationService $authentication -FarmName $FarmName -FarmType $FarmType -Servers $FarmServers -LoadBalance $LoadbalanceServers -Port $XMLPort -TransportType $TransportType
                #}
                DS_WriteLog "S" "The store service with the following configuration was created successfully:" $LogFile
                DS_WriteLog "I" "   -FriendlyName : $FriendlyName" $LogFile
                DS_WriteLog "I" "   -siteId       : $SiteId" $LogFile
                DS_WriteLog "I" "   -VirtualPath  : $StoreVirtualPath" $LogFile
                DS_WriteLog "I" "   -AuthService  : $authenticationVirtualPath" $LogFile
                DS_WriteLog "I" "   -FarmName     : $FarmName" $LogFile
                DS_WriteLog "I" "   -FarmType     : $FarmType" $LogFile
                DS_WriteLog "I" "   -Servers      : $FarmServers" $LogFile
                If ( $FarmType -eq "XenApp" ) {
                    DS_WriteLog "I" "   -SSL relay port (XenApp 6.5 only)   : $SSLRelayPort" $LogFile
                }
                DS_WriteLog "I" "   -LoadBalance  : $LoadBalanceServersTemp" $LogFile
                DS_WriteLog "I" "   -XML Port     : $XMLPort" $LogFile
                DS_WriteLog "I" "   -TransportType: $TransportType" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the store service with the following configuration (error: $($Error[0])):" $LogFile
                DS_WriteLog "I" "   -FriendlyName : $FriendlyName" $LogFile
                DS_WriteLog "I" "   -siteId       : $SiteId" $LogFile
                DS_WriteLog "I" "   -VirtualPath  : $StoreVirtualPath" $LogFile
                DS_WriteLog "I" "   -AuthService  : $authenticationVirtualPath" $LogFile
                DS_WriteLog "I" "   -FarmName     : $FarmName" $LogFile
                DS_WriteLog "I" "   -FarmType     : $FarmType" $LogFile
                DS_WriteLog "I" "   -Servers      : $FarmServers" $LogFile
                If ( $FarmType -eq "XenApp" ) {
                    DS_WriteLog "I" "   -SSL relay port (XenApp 6.5 only)   : $SSLRelayPort" $LogFile
                }
                DS_WriteLog "I" "   -LoadBalance  : $LoadBalanceServersTemp" $LogFile
                DS_WriteLog "I" "   -XML Port     : $XMLPort" $LogFile
                DS_WriteLog "I" "   -TransportType: $TransportType" $LogFile
                Exit 1
            }
        } else {
            # During the creation of the store at least one farm is defined, so there must at the very least be one farm present in the store
            DS_WriteLog "I" "A store service called $($Store.Name) already exists at the path $StoreVirtualPath in the IIS site $SiteId" $LogFile
            DS_WriteLog "I" "Retrieve the available farms in the store $($Store.Name)." $LogFile
            $ExistingFarms = (Get-STFStoreFarmConfiguration $Store).Farms.FarmName
            $TotalFarmsFound = $ExistingFarms.Count
            DS_WriteLog "I" "Total farms found: $TotalFarmsFound" $LogFile
            Foreach ( $Farm in $ExistingFarms ) {
                DS_WriteLog "I" "   -Farm name: $Farm" $LogFile    
            }

            # Loop through each farm, check if the farm name is the same as the one defined in the variable $FarmName. If not, create/add a new farm to the store
            $ExistingFarmFound = $False
            DS_WriteLog "I" "Check if the farm $FarmName already exists" $LogFile
            Foreach ( $Farm in $ExistingFarms ) {
                if ( $Farm -eq $FarmName ) {
                    $ExistingFarmFound = $True
                    # The farm exists. Nothing to do. This script will now end.
                    DS_WriteLog "I" "The farm $FarmName exists" $LogFile
                }
            }

            # Create a new farm in case existing farms were found, but none matching the farm name defined in the variable $HostbaseUrl
            If ( $ExistingFarmFound -eq $False ) {
                DS_WriteLog "I" "The farm $FarmName does not exist" $LogFile
                DS_WriteLog "I" "Create the new farm $FarmName" $LogFile
                # Create the new farm
                try {
                    Add-STFStoreFarm -StoreService $store -FarmName $FarmName -FarmType $FarmType -Servers $FarmServers -SSLRelayPort $SSLRelayPort -LoadBalance $LoadBalanceServers -Port $XMLPort -TransportType $TransportType
                    DS_WriteLog "S" "The farm $FarmName with the following configuration was created successfully:" $LogFile
                    DS_WriteLog "I" "   -siteId       : $SiteId" $LogFile
                    DS_WriteLog "I" "   -FarmName     : $FarmName" $LogFile
                    DS_WriteLog "I" "   -FarmType     : $FarmType" $LogFile
                    DS_WriteLog "I" "   -Servers      : $FarmServers" $LogFile
                    If ( $FarmType -eq "XenApp" ) {
                        DS_WriteLog "I" "   -SSL relay port (XenApp 6.5 only)   : $SSLRelayPort" $LogFile
                    }
                    DS_WriteLog "I" "   -LoadBalance  : $LoadBalanceServersTemp" $LogFile
                    DS_WriteLog "I" "   -XML Port     : $XMLPort" $LogFile
                    DS_WriteLog "I" "   -TransportType: $TransportType" $LogFile
                } catch {
                    DS_WriteLog "E" "An error occurred trying to create the farm $FarmName with the following configuration (error: $($Error[0])):" $LogFile
                    DS_WriteLog "I" "   -siteId       : $SiteId" $LogFile
                    DS_WriteLog "I" "   -FarmName     : $FarmName" $LogFile
                    DS_WriteLog "I" "   -FarmType     : $FarmType" $LogFile
                    DS_WriteLog "I" "   -Servers      : $FarmServers" $LogFile
                    If ( $FarmType -eq "XenApp" ) {
                        DS_WriteLog "I" "   -SSL relay port (XenApp 6.5 only)   : $SSLRelayPort" $LogFile
                    }
                    DS_WriteLog "I" "   -LoadBalance  : $LoadBalanceServersTemp" $LogFile
                    DS_WriteLog "I" "   -XML Port     : $XMLPort" $LogFile
                    DS_WriteLog "I" "   -TransportType: $TransportType" $LogFile
                Exit 1
                }
            }
        }

        DS_WriteLog "-" "" $LogFile

        ##############################################################################################
        # Determine if the Receiver for Web service at the specified virtual path and IIS site exists
        ##############################################################################################
        DS_WriteLog "I" "Determine if the Receiver for Web service at the path $receiverVirtualPath in the IIS site $SiteId exists" $LogFile
        try {
            $receiver = Get-STFWebReceiverService -siteID $SiteID -VirtualPath $receiverVirtualPath
        } catch {
            DS_WriteLog "E" "An error occurred trying to determine if the Receiver for Web service at the path $receiverVirtualPath in the IIS site $SiteId exists (error: $($Error[0]))!" $LogFile
            Exit 1
        }

        # Create the receiver server if it does not exist
        if ( !($receiver) ) {
            DS_WriteLog "I" "No Receiver for Web service exists at the path $receiverVirtualPath in the IIS site $SiteId" $LogFile
            DS_WriteLog "I" "Add the Receiver for Web service at the path $receiverVirtualPath in the IIS site $SiteId" $LogFile
            # Add a Receiver for Web site so users can access the applications and desktops in the published in the Store
            try {
                $receiver = Add-STFWebReceiverService -siteID $SiteId -VirtualPath $receiverVirtualPath -StoreService $Store
                DS_WriteLog "S" "The Receiver for Web service at the path $receiverVirtualPath in the IIS site $SiteId was created successfully" $LogFile
            } catch {
                DS_WriteLog "E" "An error occurred trying to create the Receiver for Web service at the path $receiverVirtualPath in the IIS site $SiteId (error: $($Error[0]))!" $LogFile
                Exit 1
            }
        } else {
            DS_WriteLog "I" "A Receiver for Web service already exists at the path $receiverVirtualPath in the IIS site $SiteId" $LogFile
        }

        DS_WriteLog "-" "" $LogFile

        ##############################################################################################
        # Determine if the PNAgent service at the specified virtual path and IIS site exists
        ##############################################################################################
        $StoreName = $Store.Name
        DS_WriteLog "I" "Determine if the PNAgent on the store '$StoreName' in the IIS site $SiteId is enabled" $LogFile
        try {
            $storePnaSettings = Get-STFStorePna -StoreService $Store
        } catch {
            DS_WriteLog "E" "An error occurred trying to determine if the PNAgent on the store '$StoreName' is enabled" $LogFile
            Exit 1
        }

        # Enable the PNAgent if required
        if ( $EnablePNAgent -eq $True ) {
            if ( !($storePnaSettings.PnaEnabled) ) {
                DS_WriteLog "I" "The PNAgent is not enabled on the store '$StoreName'" $LogFile
                DS_WriteLog "I" "Enable the PNAgent on the store '$StoreName'" $LogFile

                # Check for the following potential error: AllowUserPasswordChange is only compatible with logon method 'Prompt' authentication
                if ( ($PNAgentAllowUserPwdChange -eq $True) -and ( !($LogonMethod -eq "Prompt")) ) {
                    DS_WriteLog "I" "Important: AllowUserPasswordChange is only compatible with LogonMethod Prompt authentication" $LogFile
                    DS_WriteLog "I" "           The logon method is set to $LogonMethod, therefore AllowUserPasswordChange has been set to '`$false'" $LogFile
                    $PNAgentAllowUserPwdChange = $False
                }

                # Enable the PNAgent
                if ( ($PNAgentAllowUserPwdChange -eq $True) -and ($PNAgentDefaultService -eq $True) ) {
                    try {
                        Enable-STFStorePna -StoreService $store -AllowUserPasswordChange -DefaultPnaService -LogonMethod $LogonMethod
                        DS_WriteLog "S" "The PNAgent was enabled successfully on the store '$StoreName'" $LogFile
                        DS_WriteLog "S" "   -Allow user change password: yes" $LogFile
                        DS_WriteLog "S" "   -Default PNAgent service: yes" $LogFile
                    } catch {
                        DS_WriteLog "E" "An error occurred trying to enable the PNAgent on the store '$StoreName' (error: $($Error[0]))!" $LogFile
                        Exit 1
                    }
                }
                if ( ($PNAgentAllowUserPwdChange -eq $False) -and ($PNAgentDefaultService -eq $True) ) {
                    try {
                        Enable-STFStorePna -StoreService $store -DefaultPnaService -LogonMethod $LogonMethod
                        DS_WriteLog "S" "The PNAgent was enabled successfully on the store '$StoreName'" $LogFile
                        DS_WriteLog "S" "   -Allow user change password: no" $LogFile
                        DS_WriteLog "S" "   -Default PNAgent service: yes" $LogFile
                    } catch {
                        DS_WriteLog "E" "An error occurred trying to enable the PNAgent on the store '$StoreName' (error: $($Error[0]))!" $LogFile
                        Exit 1
                    }
                }
                if ( ($PNAgentAllowUserPwdChange -eq $True) -and ($PNAgentDefaultService -eq $False) ) {
                    try {
                        Enable-STFStorePna -StoreService $store -AllowUserPasswordChange -LogonMethod $LogonMethod
                        DS_WriteLog "S" "The PNAgent was enabled successfully on the store '$StoreName'" $LogFile
                        DS_WriteLog "S" "   -Allow user change password: yes" $LogFile
                        DS_WriteLog "S" "   -Default PNAgent service: no" $LogFile
                    } catch {
                        DS_WriteLog "E" "An error occurred trying to enable the PNAgent on the store '$StoreName' (error: $($Error[0]))!" $LogFile
                        Exit 1
                    }
                }      
            } else {
                DS_WriteLog "I" "The PNAgent is already enabled on the store '$StoreName' in the IIS site $SiteId" $LogFile
            }
        } else {
            DS_WriteLog "I" "The PNAgent should not be enabled on the store '$StoreName' in the IIS site $SiteId" $LogFile
        }

        DS_WriteLog "-" "" $LogFile
    }
 
    end {
        DS_WriteLog "I" "END FUNCTION - $FunctionName" $LogFile
    }
}
#==========================================================================

<#
 This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
 THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
 We grant you a nonexclusive, royalty-free right to use and modify the sample code and to reproduce and distribute the object 
 code form of the Sample Code, provided that you agree: 
    (i)   to not use our name, logo, or trademarks to market your software product in which the sample code is embedded; 
    (ii)  to include a valid copyright notice on your software product in which the sample code is embedded; and 
    (iii) to indemnify, hold harmless, and defend us and our suppliers from and against any claims or lawsuits, including 
          attorneys' fees, that arise or result from the use or distribution of the sample code.
 Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within 
              the Premier Customer Services Description.


  SUMMARY: 
    
   This script downloads and installs the required assemblies for SharePoint Workflow Manager after installing August 2025 CU:
	Microsoft.Data.SqlClient, Version 5.0.0.0
	Microsoft.Identity.Client, Version 4.56.0.0
	System.Memory, Version 4.0.1.1
	System.Memory, Version 4.0.1.1
	System.Buffers, Version 4.0.3.0
	System.Runtime.CompilerServices.Unsafe, Version 4.0.4.1

   Reference: https://blog.stefan-gossner.com/2025/08/21/trending-issue-s…workflow-manager/

   Version History:
    1.0 - initial version
    2.0 - add Microsoft.Data.SqlClient and Microsoft.Idenity.Client assemblies
    2.1 - add separate pull for System.Runtime.CompilerServices.Unsafe

#>

#Requires -RunAsAdministrator

## reusable function defnition

function Check-Assembly {
	param ( 
        [string] $assemblyPath 
    )

	return Test-Path -path $assemblyPath
}

function Check-SystemMemory-Assemblies {
	$check1 = Check-Assembly -assemblyPath C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Memory\v4.0_4.0.1.1__cc7b13ffcd2ddd51\System.Memory.dll
	$check2 = Check-Assembly -assemblyPath C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Buffers\v4.0_4.0.3.0__cc7b13ffcd2ddd51\System.Buffers.dll
	$check3 = Check-Assembly -assemblyPath C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Runtime.CompilerServices.Unsafe\v4.0_4.0.4.1__b03f5f7f11d50a3a\System.Runtime.CompilerServices.Unsafe.dll

	return $check1 -and $check2 -and $check3
}

function Check-MicrosoftDataSqlClient-Assembly {
	return Check-Assembly -assemblyPath C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.Data.SqlClient\v4.0_5.0.0.0__23ec7fc2d6eaa4a5\Microsoft.Data.SqlClient.dll
}

function Check-MicrosoftIdentityClient-Assembly {
	return Check-Assembly -assemblyPath C:\Windows\Microsoft.NET\assembly\GAC_MSIL\Microsoft.Identity.Client\v4.0_4.56.0.0__0a613f4dd989e8ae\Microsoft.Identity.Client.dll
}

function Ckeck-All-Assemblies {
	return (Check-SystemMemory-Assemblies) -and (Check-MicrosoftDataSqlClient-Assembly) -and (Check-MicrosoftIdentityClient-Assembly)
}

## check if assemblies are already installed
if (Ckeck-All-Assemblies) {
	write-host -foregroundColor Green "Assemblies already installed - nothing to do"
	exit
}


## create temp directory
New-Item -Path "C:\temp\NuGet" -ItemType Directory -Force > $null

## download nuget.exe
#Invoke-WebRequest -Uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -Outfile c:\temp\nuget\nuget.exe > $null


## download required nuget packages and add assemblies to GAC

## download required nuget packages
& c:\temp\nuget\nuget.exe install Microsoft.Data.SqlClient -version 5.1.5 -outputdirectory c:\temp\nuget -framework net462
& c:\temp\nuget\nuget.exe install System.Runtime.CompilerServices.Unsafe -version 4.5.3 -outputdirectory c:\temp\nuget -framework net461

[System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a") > $null           
$publish = New-Object System.EnterpriseServices.Internal.Publish

if ((Check-SystemMemory-Assemblies) -eq $false) {
	$publish.GacInstall("C:\temp\nuget\System.Memory.4.5.4\lib\net461\System.Memory.dll")
	$publish.GacInstall("C:\temp\nuget\System.Buffers.4.5.1\lib\net461\System.Buffers.dll")
	$publish.GacInstall("C:\temp\nuget\System.Runtime.CompilerServices.Unsafe.4.5.3\lib\net461\System.Runtime.CompilerServices.Unsafe.dll")
}

if ((Check-MicrosoftDataSqlClient-Assembly) -eq $false) {
	$publish.GacInstall("C:\temp\nuget\Microsoft.Data.SqlClient.5.1.5\lib\net462\Microsoft.Data.SqlClient.dll")
}
if ((Check-MicrosoftIdentityClient-Assembly) -eq $false) {
	$publish.GacInstall("C:\temp\NuGet\Microsoft.Identity.Client.4.56.0\lib\net461\Microsoft.Identity.Client.dll")
}


## check if assemblies were added to GAC

if (Ckeck-All-Assemblies) {
	write-host -ForegroundColor Green "Success: required assemblies successfully installed"
} else {
	write-host -ForegroundColor Red "Error: failed to install required assemblies!"
}



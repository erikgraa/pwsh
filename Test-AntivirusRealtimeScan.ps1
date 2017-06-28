Function Test-AntivirusRealtimeScan {
  <#
    .DESCRIPTION
    Creates a file containing the EICAR test script and polls to determine if it gets removed by real-time scans of antivirus software.

    .PARAMETER DestinationPath
    Specifies the destination folder.

    .PARAMETER Sleep
    Specifies how long to poll for whether the EICAR test script gets removed or not.

    .EXAMPLE
    Test-AntivirusRealtimeScan -DestinationPath C:\Windows\System32 -Sleep 30

    .OUTPUTS
    Returns [Boolean]$True if the file gets removed in time.
    Returns [Boolean]$False if the file is not removed in time.

    .NOTES
    The EICAR test script is provided by the European Institute for Computer Antivirus Research (EICAR). 
    It is an inert file consisting of an innocuous string meant to confirm that antivirus software real-time scans work as intended

    .LINK
    www.eicar.org/86-0-Intended-use.html
#>

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$False)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [String]$DestinationPath="${env:windir}\System32",
  
    [Parameter(Mandatory=$False)]
    [ValidateRange(1,300)]
    [Int]$Sleep=30
  )

  If(-Not($DestinationPath.EndsWith("\"))) {
    $DestinationPath += "\"
  }

  $SleepNum = 0
  $FilePath = $DestinationPath + "EICAR.com"
  $EICAR = @('X5O!P%@AP[4\PZX54(P^)7CC)7}$','EICAR-STANDARD-ANTIVIRUS-TEST-FILE','!$H+H*')

  Try {
    Set-Content -Path $FilePath -Value ($EICAR -Join "") -ErrorAction Stop
    Write-Verbose "Created the EICAR test script file '$FilePath'"
    Write-Verbose "Polling for removal of the EICAR test script file '$FilePath' for a maximum of '$Sleep' seconds"
  }
  Catch {
    Throw $_
  }

  Do {
    If(-Not(Test-Path -Path $FilePath -PathType Leaf -ErrorAction SilentlyContinue)) {
      Write-Verbose "The EICAR test script file '$FilePath' was removed from the filesystem after '$SleepNum' seconds"
      Return $True
    }
    Start-Sleep -Seconds 1
  } While($SleepNum++ -le $Sleep)

  Return $False
}
<#
  .DESCRIPTION
  Retrieves the relative portion, either parent or leaf, of a distinguished name.

  .PARAMETER InputObject
  Specifies the distinguished name. Optionally takes an ADUser, ADGroup or ADObject object.

  .PARAMETER Parent
  Specifies that it's the parent portion one wants.

  .PARAMETER Leaf
  Specifies that it's the leaf portion one wants.

  .PARAMETER Domain
  Specifies the domain.

  .EXAMPLE
  Split-ADPath -InputObject (Get-ADUser -Identity 'Erik') -Parent

  .EXAMPLE
  Split-ADPath -InputObject (Get-ADGroup -Identity 'HorizonAdmins') -Parent

  .EXAMPLE
  Split-ADPath -InputObject 'CN=testuser,OU=testOU,OU=testTestOU,DC=dev,DC=graa' -Leaf

  .OUTPUTS
  System.String.
#>

function Split-ADPath {
  [CmdletBinding(DefaultParameterSetName = 'Parent')]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [object]$InputObject,

    [Parameter(Mandatory = $false, ParameterSetName = 'Leaf')]
    [switch]$Leaf,

    [Parameter(Mandatory = $false, ParameterSetName = 'Parent')]
    [switch]$Parent,

    [Parameter(Mandatory = $false)]
    [string]$Domain
  )

  begin {
    $commonName = $null
    $splat = @{}

    if ($PSBoundParameters.ContainsKey('Domain')) {
        $splat.Add('Domain', $Domain)
    }

    if ($InputObject -is [Microsoft.ActiveDirectory.Management.ADUser] -or
        $InputObject -is [Microsoft.ActiveDirectory.Management.ADGroup] -or 
        $InputObject -is [Microsoft.ActiveDirectory.Management.ADObject]) {
            $distinguishedName = $InputObject.DistinguishedName

            $parentDn = Get-ADObject -Identity $InputObject -Property 'msDS-parentdistname' @splat |
                        Select-Object -ExpandProperty 'msDS-parentdistname' 

            if ($null -ne $InputObject.Name) {
                $commonName = ('CN={0}' -f $InputObject.Name)
            }
    }
    else {
        $distinguishedName = $InputObject
        $commonName = Select-String -InputObject $InputObject -Pattern '^(CN=.+?),.*'

        if ($null -ne $commonName) {
            $commonName = $commonName.Matches.Groups[-1].Value
            $parentDn = $distinguishedName.Replace(('{0},' -f $commonName), '')
        }
        else {
            $commonName = $InputObject
            $parentDn = $distinguishedName
        }

    }
  }

  process {
    if ($PSCmdlet.ParameterSetName -eq 'Parent') {
        $parentDn
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Leaf') {
        if ($null -ne $commonName) {
            $commonName
        }
        else {
            $distinguishedName
        }
    }
  }

  end { }
}
  <#
    .DESCRIPTION
    Synchronizes a SecretManagement Secret Vault's secrets to one or more destination SecretManagement Secret Vault(s).

    .PARAMETER Vault
    Specifies the SecretManagement Secret Vault from which to synchronize.

    .PARAMETER DestinationVault
    Specifies one or more destination SecretManagement Secret Vault(s).

    .EXAMPLE
    Sync-SecretVault -Vault LAPS -DestinationVault HCP-LAPS

    .EXAMPLE
    Sync-SecretVault -Vault (Get-SecretVault -Name LAPS) -DestinationVault (Get-SecretVault -Name HCP-LAPS)

    .OUTPUTS
    None.
#>

function Sync-SecretVault {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]$Vault,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]    
        [Object[]]$DestinationVault
    )

    begin {
        try {
	        if ($Vault -is [string]) {
		        $vaultInfo = Get-SecretVault -Name $Vault -ErrorAction Stop
	        }
	        elseif ($Vault -is [Microsoft.PowerShell.SecretManagement.SecretVaultInfo]) {
		        $vaultInfo = $Vault
		        $Vault = $Vault.Name
	        }
	        else {
		        throw 'Invalid vault input passed.'
            }
        }
        catch {
            throw ('Failed enumerating source vault: {0}' -f $_)
        }
    }

    process {
        foreach ($_destinationVault in $DestinationVault) {
		    try {
			    if ($_destinationVault -is [string]) {
				    $_destinationVaultInfo = Get-SecretVault -Name $_destinationVault -ErrorAction Stop
				}
				elseif ($_destinationVault -is [Microsoft.PowerShell.SecretManagement.SecretVaultInfo]) {
					$_destinationVaultInfo = $_destinationVault
					$_destinationVault = $_destinationVaultInfo.Name
				}
				else {
					throw 'Invalid vault input passed.'
				}

				if ($_destinationVault -eq $Vault) {
					throw 'Source and destination vaults cannot be the same'
				}
			
                $_destinationVaultInfo = Get-SecretVault -Name $_destinationVault -ErrorAction Stop

			    $secretInfo = Get-SecretInfo -Vault $Vault
			    $secretCount = $secretInfo | Measure-Object | Select-Object -ExpandProperty Count

			    Write-Verbose ("Writing {0} secrets from vault {1} to destination vault {2}" -f $secretCount, $Vault, $_destinationVault)

			    foreach ($_secretInfo in $secretInfo) {			  
			        $_secret = Get-Secret -Vault $Vault -Name $_secretInfo.Name

    			    switch ($vaultInfo.ModuleName) {
                        'SecretManagement.HashiCorp.BitLocker' {
				            $secretName = ('{0}_{1}' -f $_secretInfo.Name, $_secretInfo.Metadata.Id)
				        }        
				        'SecretManagement.Windows.LAPS' {
				            $secretName = ('{0}_{1}' -f $_secretInfo.Name, $_secretInfo.Metadata.Account)
				        }
				        default {
				            $secretName = $_secret.Name 
				        }
			        }
			  
			        Set-Secret -Vault $_destinationVault -Name $secretName -Secret $_secret.Password
			    }
		    }
            catch {
			    throw ('Error encountered: {0}' -f $_)
		    }
		}
    }

    end { }
}
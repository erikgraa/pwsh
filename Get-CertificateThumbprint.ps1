  <#
    .DESCRIPTION
    Retrieves SHA1 and SHA256 thumbprint for an X509.2 certificate.

    .PARAMETER InputObject
    Specifies the X509 certificate(s).

    .EXAMPLE
    Get-ChildItem -Path Cert:\LocalMachine\My | % { Get-CertificateThumbprint }

    .OUTPUTS
    PSCustomObject.
#>

function Get-CertificateThumbprint {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]]$InputObject
    )

    begin { }

    process {
        foreach ($_certificate in $InputObject) {
            $hash = [Ordered]@{
                'Subject' = $_certificate.Subject
                'SHA1' = $_certificate.Thumbprint
                'SHA256' = ('{0}' -f [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($_certificate.GetRawCertData())).Replace('-',''))
            }

            New-Object -TypeName PSCustomObject -Property $hash
        }
    }           

    end { }
}
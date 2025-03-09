function Get-CertificateThumbprint {
    [CmdletBinding()]    
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
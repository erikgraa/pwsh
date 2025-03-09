  <#
    .DESCRIPTION
    Retrieves TLS certificate from a remote endpoint.

    .PARAMETER InputObject
    Specifies the computer name(s).

    .PARAMETER Port
    Specifies the port.

    .EXAMPLE
    Get-RemoteCertificate -ComputerName 'webserver' -Port 443

    .EXAMPLE
    Get-RemoteCertificate -ComputerName 'dc.fqdn' -Port 636

    .OUTPUTS
    System.Security.Cryptography.X509Certificates.X509Certificate2

    .NOTES
    Based on Get-RemoteSSLCertificate.ps1 from https://github.com/jstangroome.

    .LINK
    https://gist.github.com/jstangroome/5945820
    https://github.com/jstangroome
#>

function Get-RemoteCertificate {
    [CmdletBinding()]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [Parameter(Mandatory=$false)]
        [ValidateRange(1,65535)]
        [Uint16]$Port = 443
    )

    begin { }

    process {
        foreach ($_computerName in $ComputerName) {
            $certificate = $null
            $tcpClient = New-Object -TypeName System.Net.Sockets.TcpClient

            try {
                $tcpClient.Connect($ComputerName, $Port)
                $tcpStream = $tcpClient.GetStream()

                $callback = { 
                    param($sender, $cert, $chain, $errors) return $true 
                }

                $sslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($tcpStream, $true, $callback)

                try {
                    $sslStream.AuthenticateAsClient('')
                    $certificate = $sslStream.RemoteCertificate

                } finally {
                    $sslStream.Dispose()
                }

            } finally {
                $tcpClient.Dispose()
            }

            if ($Certificate) {
                if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
                    $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
                }

                Write-Output $certificate
            }
        }
    }

    end { }
}
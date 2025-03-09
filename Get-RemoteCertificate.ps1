# Based on Get-RemoteSSLCertificate.ps1 from https://gist.github.com/jstangroome/5945820 by https://github.com/jstangroome

function Get-RemoteCertificate {
    [CmdletBinding()]
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
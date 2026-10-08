$ErrorActionPreference = 'Stop'
Write-Output 'Archit Kulkarni | 24BCS10194 | Networking checks'
Write-Output (Get-Date -Format o)
Write-Output 'IPv4 address and default route'
Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -eq 'Wi-Fi' | Format-Table InterfaceAlias,IPAddress,PrefixLength -AutoSize | Out-String | Write-Output
Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Format-Table InterfaceAlias,NextHop,RouteMetric -AutoSize | Out-String | Write-Output
Write-Output 'DNS lookup through the configured resolver'
nslookup.exe github.com
Write-Output 'Bounded route trace (eight hops, no reverse lookup)'
tracert.exe -d -h 8 -w 500 1.1.1.1
Write-Output 'HTTPS response through Ubuntu WSL'
wsl.exe -d Ubuntu -u root -- curl -sS -o /dev/null --max-time 20 --write-out 'HTTPS status: %{http_code}\n' https://github.com
if ($LASTEXITCODE -ne 0) { throw 'HTTPS check failed' }
Write-Output 'Listening TCP sockets (first ten)'
Get-NetTCPConnection -State Listen | Select-Object -First 10 | Format-Table LocalAddress,LocalPort,State -AutoSize | Out-String | Write-Output
Write-Output 'A timeout in the route trace means that hop did not answer; it is not proof that HTTPS is broken.'

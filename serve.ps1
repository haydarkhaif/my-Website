$folder = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $folder 'serve.log'
function Log($message) {
    $entry = "$(Get-Date -Format o) - $message"
    Add-Content -Path $logPath -Value $entry
}
Log 'Starting serve.ps1'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:9000/')
try {
    $listener.Start()
    Write-Host "Serving $folder at http://localhost:9000"
    Log 'Server started on port 9000'
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $resp = $context.Response
        $urlPath = $req.Url.AbsolutePath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($urlPath)) { $urlPath = 'index.html' }
        $localPath = Join-Path $folder $urlPath
        if (-not (Test-Path $localPath)) {
            $resp.StatusCode = 404
            $content = '404 Not Found'
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $resp.ContentType = 'text/plain'
        } else {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($localPath)
                $extension = [System.IO.Path]::GetExtension($localPath).ToLowerInvariant()
                $resp.ContentType = switch ($extension) {
                    '.css' {'text/css'}
                    '.js' {'application/javascript'}
                    '.png' {'image/png'}
                    '.jpg' {'image/jpeg'}
                    '.jpeg' {'image/jpeg'}
                    '.svg' {'image/svg+xml'}
                    '.json' {'application/json'}
                    '.txt' {'text/plain'}
                    default {'text/html'}
                }
            } catch {
                $resp.StatusCode = 500
                $bytes = [System.Text.Encoding]::UTF8.GetBytes('500 Internal Server Error')
                $resp.ContentType = 'text/plain'
            }
        }
        $resp.OutputStream.Write($bytes, 0, $bytes.Length)
        $resp.OutputStream.Close()
    }
} catch {
    $errorMessage = $_.Exception.Message
    Write-Host "Server failed: $errorMessage"
    Log "Server failed: $errorMessage"
} finally {
    if ($listener.IsListening) { $listener.Stop() }
    Log 'Server stopped'
}

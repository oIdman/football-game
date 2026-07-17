param(
    [string]$NewVersion = "v0.2.0",
    [int]$CountdownSeconds = 5
)

$msg = "即将在 {0} 秒后重启更新至 {1}。" -f $CountdownSeconds, $NewVersion
Write-Output $msg
for ($i = $CountdownSeconds; $i -ge 0; $i--) {
    Write-Output ("{0} 秒..." -f $i)
    if ($i -gt 0) { Start-Sleep -Seconds 1 }
}
Write-Output ("=== 版本 {0} 已就绪 ===" -f $NewVersion)

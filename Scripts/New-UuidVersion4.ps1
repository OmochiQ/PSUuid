$Script:Nuv4_Random = New-Object -TypeName System.Random

function Get-RandomBytes-Nuv4 {
    $result = New-Object -TypeName byte[] -ArgumentList 16
    $Script:Nuv4_Random.NextBytes($result)
    return $result
}

function New-UuidVersion4 {
    [CmdletBinding()]
    param (
    )
    $ErrorActionPreference = 'stop'

    $bytes = Get-RandomBytes-Nuv4

    # Section1からSection3までの値
    [uint64]$Value1 = [System.BitConverter]::ToUInt64($bytes, 0)
    # Section4とSection5の値
    [uint64]$Value2 = [System.BitConverter]::ToUInt64($bytes, 8)

    # 各セクションごとの値を取得する
    $Section1 = ($Value1 -shr 32) -band 0xffffffff
    $Section2 = ($Value1 -shr 16) -band 0xffff
    # 最初の4bitは0100(バージョンを表す4)固定なので除外
    $Section3 = $Value1 -band 0x0fff
    # 最初に2bitは10固定
    $Section4 = (($Value2 -shr 48) -band 0x3fffl) -bor 0x8000
    $Section5 = $Value2 -band 0x0000ffffffffffff
    '{0:x8}-{1:x4}-4{2:x3}-{3:x4}-{4:x12}' -f ($Section1, $Section2, $Section3, $Section4, $Section5)
}

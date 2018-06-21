function New-UuidVersion3 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateCount(16, 16)]
        [byte[]]$NamespaceByte,
        [Parameter(Mandatory=$true)]
        [String]$Name
    )
    $ErrorActionPreference = 'stop'

    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    try {
        # 文字列のバイト配列を取得し、namespaceのバイト配列と結合する
        $bytes = $NamespaceByte + [System.Text.Encoding]::UTF8.GetBytes($Name)
        # ハッシュを取得
        $hash = $md5.ComputeHash($bytes)

        # 配列のオフセット
        $Offset = 0
        [uint64]$Section1 = 0
        for ($i = 0; $i -lt 4; ++$i) {
            $Section1 = $Section1 -shl 8
            $Section1 = $Section1 -bor $hash[$i + $Offset]
        }
        $Offset += 4

        [uint64]$Section2 = 0
        for ($i = 0; $i -lt 2; ++$i) {
            $Section2 = $Section2 -shl 8
            $Section2 = $Section2 -bor $hash[$i + $Offset]
        }
        $Offset += 2

        [uint64]$Section3 = 0
        for ($i = 0; $i -lt 2; ++$i) {
            $Section3 = $Section3 -shl 8
            $Section3 = $Section3 -bor $hash[$i + $Offset]
        }
        # 上位4bitは0011(バージョンを表す3)固定なので除外
        $Section3 = $Section3 -band 0x0fff
        $Offset += 2

        [uint64]$Section4 = 0
        for ($i = 0; $i -lt 2; ++$i) {
            $Section4 = $Section4 -shl 8
            $Section4 = $Section4 -bor $hash[$i + $Offset]
        }
        # 上位2bitは10固定
        $Section4 = ($Section4 -band 0x3fff) -bor 0x8000
        $Offset += 2

        [uint64]$Section5 = 0
        for ($i = 0; $i -lt 6; ++$i) {
            $Section5 = $Section5 -shl 8
            $Section5 = $Section5 -bor $hash[$i + $Offset]
        }

        '{0:x8}-{1:x4}-3{2:x3}-{3:x4}-{4:x12}' -f ($Section1, $Section2, $Section3, $Section4, $Section5)
    }
    finally {
        # 解放
        $md5.Dispose()
    }
}

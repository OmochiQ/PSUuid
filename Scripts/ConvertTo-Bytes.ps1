# Uuidの文字列をバイト配列に変換する
function ConvertTo-Bytes {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Uuid
    )
    $ErrorActionPreference = 'stop'
    
    # 入力された値を整形する
    $SimpleUuid = ($Uuid.Trim()).PadLeft(32, '0') -replace '[{}()-]',''
    # 文字列を2文字ずつに分割する
    $bytes = for ($i = 0; $i -lt 16; ++$i) {
        # バイトに変換する
        [byte]('0x' + $SimpleUuid.Substring($i * 2, 2))
    }

    return $bytes
}

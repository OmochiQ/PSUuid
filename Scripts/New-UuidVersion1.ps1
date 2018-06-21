# 計算に使用する時間の基準日(1582/10/10 00:00:00 UTC)
$Script:Nuv1_OriginTimeTicks = (New-Object -TypeName System.DateTime -ArgumentList (1582, 10, 15, 0, 0, 0, [System.DateTimeKind]::Utc)).Ticks
# 最後の取得した日付
$Script:Nuv1_LastTime = ([DateTime]::MinValue).ToUniversalTime()
# Uuidが生成された時間が同じか、遡った際にインクリメントする値
$Script:Nuv1_ClockSequence = 0
# 計算に使用する物理アドレス
$Script:Nuv1_MacAddress = [String]::Empty

function Get-UtcDate-Nuv1 {
    [DateTime]::UtcNow
}

function Get-PhysicalAddress-Nuv1 {
    ([System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.NetworkInterfaceType -eq [System.Net.NetworkInformation.NetworkInterfaceType]::Ethernet } |
        Select-Object -First 1
    ).GetPhysicalAddress().ToString().ToLower()
}

function New-ClockSequence-Nuv1 {
    (((Get-Random -Maximum 0x3fff) -bor 0x8000) -band 0xbfff)
}

function New-UuidVersion1 {
    [CmdletBinding()]
    param (
    )
    $ErrorActionPreference = 'stop'
    # 現在の時間(協定世界時)を取得する
    $CurrentTime = Get-UtcDate-Nuv1
    # クロックシーケンスが0の場合は初期化する
    if (($Script:Nuv1_ClockSequence -eq 0)) {
        $Script:Nuv1_ClockSequence = New-ClockSequence-Nuv1
    }

    # 物理アドレスが未取得の場合のみ取得する(複数回実行した際のボトルネックになるので、結果をキャッシュする)
    if ([String]::IsNullOrEmpty($Script:Nuv1_MacAddress)) {
        # 物理アドレスを取得する
        $Script:Nuv1_MacAddress = Get-PhysicalAddress-Nuv1
    }

    # 時間同じ場合と遡った場合、ClockSequenceをインクリメントする
    if ($CurrentTime -le $Script:Nuv1_LastTime) {
        $Script:Nuv1_ClockSequence += 1
        # 上限(0xbfff)を超えたら0x8000に戻す(上位2bitは01固定)
        if ($Script:Nuv1_ClockSequence -gt 0xbfff) {
            $Script:Nuv1_ClockSequence = 0x8000
        }
    }

    # 最後に取得した日付を保管しておく
    $Script:Nuv1_LastTime = $CurrentTime
    # 1582/10/15 00:00:00UTCからの100ナノ秒単位のタイムスタンプ(Ticksは100ナノ秒を返す)
    [uint64]$Difference = ($CurrentTime.Ticks - $Script:Nuv1_OriginTimeTicks)

    # タイムスタンプの下位32bit
    $Section1 = ($Difference -band 0x00000000ffffffffl)
    # タイムスタンプの真ん中の16bit
    $Section2 = (($Difference -band 0x0000ffff00000000l) -shr 32)
    # タイムスタンプの最初から4bitあけた12bit(上位4bitは1で置き換えられるので無視する)
    $Section3 = (($Difference -band 0x0fff000000000000l) -shr 48)

    # 各セクションを1つにまとめる
    '{0:x8}-{1:x4}-1{2:x3}-{3:x4}-{4}' -f ($Section1, $Section2, $Section3, $Script:Nuv1_ClockSequence, $Script:Nuv1_MacAddress)
}

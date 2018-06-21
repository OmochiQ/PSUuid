$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'New-UuidVersion1' {
    # 常に2018/06/20 00:00:00 UTCを返す
    Mock -CommandName 'Get-UtcDate-Nuv1' -MockWith { New-Object -TypeName DateTime -ArgumentList (2018, 6, 20, 0, 0, 0, [System.DateTimeKind]::Utc) }
    # 物理アドレスは常に123456789abcを返す
    Mock -CommandName 'Get-PhysicalAddress-Nuv1' -MockWith { '123456789abc' }
    # クロックシーケンスは常に0x8000を返す
    Mock -CommandName 'New-ClockSequence-Nuv1' -MockWith { 0x8000 }

    Context -Name '2018/6/20 00:00:00に物理アドレス123456789abcで生成した場合' -Fixture {
        It '1回目はdff3c000-741c-11e8-8000-123456789abcになる' {
            New-UuidVersion1 | Should -Be 'dff3c000-741c-11e8-8000-123456789abc'
        }

        It '2回目はdff3c000-741c-11e8-8001-123456789abcになる' {
            New-UuidVersion1 | Should -Be 'dff3c000-741c-11e8-8001-123456789abc'
        }
    }
}

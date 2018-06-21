$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'ConvertTo-Bytes' {
    Context -Name '11111111-1111-1111-1111-111111111111の場合' -Fixture {
        $expect = [byte[]](0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11)

        It '0x11を16個返却する' {
            ConvertTo-Bytes -Uuid '11111111-1111-1111-1111-111111111111' | Should -Be $expect
            ConvertTo-Bytes -Uuid '11111111111111111111111111111111' | Should -Be $expect
            ConvertTo-Bytes -Uuid '{11111111-1111-1111-1111-111111111111}' | Should -Be $expect
        }
    }

    It 'リトルエンディアンで処理を行う' {
        $expect = [byte[]](0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0x12)
        ConvertTo-Bytes -Uuid '11223344-5566-7788-99aa-bbccddeeff12' | Should -Be $expect
    }
}

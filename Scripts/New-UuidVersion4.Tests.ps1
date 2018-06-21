$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'New-UuidVersion1' {
    It '乱数がすべて0x00の場合は 00000000-0000-4000-8000-000000000000 を返す' {
        # すべて0を返す
        Mock -CommandName 'Get-RandomBytes-Nuv4' -MockWith {
            for ($i = 0; $i -lt 16; ++$i) {
                [byte]0x00
            }
        }
        New-UuidVersion4 | Should -Be '00000000-0000-4000-8000-000000000000'
    }

    It '乱数がすべて0xffの場合は ffffffff-ffff-4fff-bfff-ffffffffffff を返す' {
        # すべて0を返す
        Mock -CommandName 'Get-RandomBytes-Nuv4' -MockWith {
            for ($i = 0; $i -lt 16; ++$i) {
                [byte]0xff
            }
        }
        New-UuidVersion4 | Should -Be 'ffffffff-ffff-4fff-bfff-ffffffffffff'
    }
}

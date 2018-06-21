$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'New-EmptyUuid' {
    It '常に00000000-0000-0000-0000-000000000000を返す' {
        New-EmptyUuid | Should -Be '00000000-0000-0000-0000-000000000000'
    }
}

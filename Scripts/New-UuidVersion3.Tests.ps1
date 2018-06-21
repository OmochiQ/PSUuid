$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'New-UuidVersion3' {
    $UrlBytes = [byte[]](0x6b, 0xa7, 0xb8, 0x11, 0x9d, 0xad, 0x11, 0xd1, 0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8)

    Context -Name 'NamespaceにURL(6ba7b811-9dad-11d1-80b4-00c04fd430c8)を指定' -Fixture {
        It 'http://example.com/foo を指定したとき 8f932a5b-ab21-3f60-b1e7-4ec6da1ff1ec を返す' {
            New-UuidVersion3 -Namespace $UrlBytes -Name 'http://example.com/foo' | Should -Be '8f932a5b-ab21-3f60-b1e7-4ec6da1ff1ec'
        }

        It 'http://example.com/bar を指定したとき a51e9810-1653-3040-a007-47daaa5af9c4 を返す' {
            New-UuidVersion3 -Namespace $UrlBytes -Name 'http://example.com/bar' | Should -Be 'a51e9810-1653-3040-a007-47daaa5af9c4'
        }
    }
}

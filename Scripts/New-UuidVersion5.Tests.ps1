$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'New-UuidVersion5' {
    $UrlBytes = [byte[]](0x6b, 0xa7, 0xb8, 0x11, 0x9d, 0xad, 0x11, 0xd1, 0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8)

    Context -Name 'NamespaceにURL(6ba7b811-9dad-11d1-80b4-00c04fd430c8)を指定' -Fixture {
        It 'http://example.com/foo を指定したとき 62242d0a-8f4b-5be6-8cbd-6102f9fe7b9e を返す' {
            New-UuidVersion5 -Namespace $UrlBytes -Name 'http://example.com/foo' | Should -Be '62242d0a-8f4b-5be6-8cbd-6102f9fe7b9e'
        }

        It 'http://example.com/bar を指定したとき 4610e9b1-4b7e-5d16-b378-ff300386649b を返す' {
            New-UuidVersion5 -Namespace $UrlBytes -Name 'http://example.com/bar' | Should -Be '4610e9b1-4b7e-5d16-b378-ff300386649b'
        }
    }
}

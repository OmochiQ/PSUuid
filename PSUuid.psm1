# フォルダー内のスクリプトファイルを実行(テスト用ファイルは除外)
foreach ($script in @(Get-ChildItem -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'Scripts')) | Where-Object { -not ($_.Name -imatch '^*.\.(tests|spec)\.ps1$') }) {
    .($script.FullName)
}

# V3/V5用のnamespace UUID
$Script:NamespaceBytes = @{
    Dns = ConvertTo-Bytes -Uuid '6ba7b810-9dad-11d1-80b4-00c04fd430c8'
    Url = ConvertTo-Bytes -Uuid '6ba7b811-9dad-11d1-80b4-00c04fd430c8'
    Oid = ConvertTo-Bytes -Uuid '6ba7b812-9dad-11d1-80b4-00c04fd430c8'
    X500 = ConvertTo-Bytes -Uuid '6ba7b814-9dad-11d1-80b4-00c04fd430c8'
}

<#
.SYNOPSIS
Universally Unique Identifier(UUID)を生成します

.DESCRIPTION
New-UuidはUniversally Unique Identifier(UUID)のバージョン1、バージョン3、バージョン4、バージョン5を生成します。

.EXAMPLE
PS C:\> New-Uuid -Version1

.EXAMPLE
PS C:\> New-Uuid -Version3 -Namespace Url -Name 'http://example.com/foo'

.PARAMETER Empty
Nil UUIDを生成します

.PARAMETER Version1
時刻と物理アドレスを使用してUUIDを生成します

.PARAMETER Version3
何らかのUUIDのMD5のハッシュ値を使用してUUIDを生成します

.PARAMETER Version4
乱数を使用してUUIDを生成します

.PARAMETER Version5
何らかのUUIDのSHA1のハッシュ値を使用してUUIDを生成します

.PARAMETER Namespace
v3とv5の定義されているnamespace
Dns / Url / Oid / x500

.PARAMETER Uuid
v3とv5のハッシュ値として使用するUUID

.PARAMETER Name
v3とv5のUUIDを生成する文字列
#>
function New-Uuid {
    [CmdletBinding(DefaultParameterSetName='Version4')]
    param (
        [Parameter(ParameterSetName='Version1')]
        [Switch]$Version1,
        # [Parameter(ParameterSetName='Version2')]
        # [Switch]$Version2,
        [Parameter(ParameterSetName='Version3')]
        [Parameter(ParameterSetName='Version3-Uuid')]
        [Switch]$Version3,
        [Parameter(ParameterSetName='Version4')]
        [Switch]$Version4,
        [Parameter(ParameterSetName='Version5')]
        [Parameter(ParameterSetName='Version5-Uuid')]
        [Switch]$Version5,
        [Parameter(ParameterSetName='Version3', Mandatory=$true)]
        [Parameter(ParameterSetName='Version5', Mandatory=$true)]
        [ValidateSet('Dns', 'Url', 'Oid', 'x500')]
        [String]$Namespace,
        [Parameter(ParameterSetName='Version3-Uuid', Mandatory=$true)]
        [Parameter(ParameterSetName='Version5-Uuid', Mandatory=$true)]
        [String]$Uuid,
        [Parameter(ParameterSetName='Version3', Mandatory=$true)]
        [Parameter(ParameterSetName='Version5', Mandatory=$true)]
        [Parameter(ParameterSetName='Version3-Uuid', Mandatory=$true)]
        [Parameter(ParameterSetName='Version5-Uuid', Mandatory=$true)]
        [String]$Name,
        [Switch]$Empty
    )
    $ErrorActionPreference = 'stop'
    if ($Empty) {
        New-EmptyUuid
        return
    }

    # バージョンに対応したコマンドレットを実行する
    switch ($PSCmdlet.ParameterSetName) {
        'Version1' { New-UuidVersion1 }

        # 'Version2' { New-UuidVersion2; break }

        'Version4' { New-UuidVersion4 }

        'Version3' {
            New-UuidVersion3 -NamespaceByte ($Script:NamespaceBytes[$Namespace]) -Name $Name
        }

        'Version3-Uuid' {
            New-UuidVersion3 -NamespaceByte (ConvertTo-Bytes -Uuid $Uuid) -Name $Name
        }

        'Version5' {
            New-UuidVersion5 -NamespaceByte ($Script:NamespaceBytes[$Namespace]) -Name $Name
        }

        'Version5-Uuid' {
            New-UuidVersion5 -NamespaceByte (ConvertTo-Bytes -Uuid $Uuid) -Name $Name
        }

        default {
            # 当てはまらない場合はversion4で実行する
            New-UuidVersion4
        }
    }
}

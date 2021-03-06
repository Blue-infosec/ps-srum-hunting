﻿<#
.NOTES
  Version:        1.01
  Author:         Thomas V Fischer
  Creation Date:  20190315
  Purpose/Change: Initial script development
.SYNOPSIS
   Script: Get-SRUMTableDataRows
   Fucntion to output all the rows of a SRUM database into a PSCustomObject
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>


.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>
Function Get-SRUMTableDataRows{
  Param(
      [Parameter(Position=0,Mandatory = $true)]
      [ValidateNotNull()]
      $Session,
      ## Need to figure out if I should include the variable type [Microsoft.Isam.Esent.Interop.JET_SESID].
      ## Don't think so but using it might be safer to ensure proper variable is passed
      [Parameter(Position=1,Mandatory = $true)]
      [ValidateNotNull()]
      $JetTable,
      [Parameter(Position=2,Mandatory = $false)]
      [ValidateNotNull()]
      $BlobStrType=[System.Text.Encoding]::UTF16
  )

  Begin{
    #test
  }

  Process{
    $DBRows = @()
    Try{

        [Microsoft.Isam.Esent.Interop.ColumnInfo[]]$Columns = [Microsoft.Isam.Esent.Interop.Api]::GetTableColumns($Session, $JetTable.JetTableid)

        if ([Microsoft.Isam.Esent.Interop.Api]::TryMoveFirst($Session, $JetTable.JetTableid))
        {
            do
            {
                $Row = New-Object PSObject

                foreach ($Column in $Columns)
                {
                    switch ($Column.Coltyp)
                    {
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Bit) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsBoolean($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::DateTime) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsDateTime($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::IEEEDouble) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsDouble($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::IEEESingle) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsFloat($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Long) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt32($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Binary) {
                            # Default string function retrieves UTF16, so we check the string type we are retrieving
                            if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                            } else {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                            }
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::LongBinary) {
                            # Default string function retrieves UTF16, so we check the string type we are retrieving
                            if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                            } else {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                            }
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::LongText) {
                            # Default string function retrieves UTF16, so we check the string type we are retrieving
                            if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                            } else {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                            }

                            #Replace null characters which are 0x0000 unicode
                            if (![System.String]::IsNullOrEmpty($Buffer)) {
                                $Buffer = $Buffer.Replace("`0", "")
                            }
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Text) {
                            # Default string function retrieves UTF16, so we check the string type we are retrieving
                            if ( $BlobStrType -eq [System.Text.Encoding]::UTF16 ) {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid)
                            } else {
                                $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, $BlobStrType)
                            }

                            #Replace null characters which are 0x0000 unicode
                            if (![System.String]::IsNullOrEmpty($Buffer)) {
                                $Buffer = $Buffer.Replace("`0", "")
                            }
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Currency) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsString($Session, $JetTable.JetTableid, $Column.Columnid, [System.Text.Encoding]::UTF8)

                            #Replace null characters which are 0x0000 unicode
                            if (![System.String]::IsNullOrEmpty($Buffer)) {
                                $Buffer = $Buffer.Replace("`0", "")
                            }
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::Short) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt16($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        ([Microsoft.Isam.Esent.Interop.JET_coltyp]::UnsignedByte) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsByte($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        (14) {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt32($Session, $JetTable.JetTableid, $Column.Columnid)
                            break
                        }
                        (15) {
                            try {
                            $Buffer = [Microsoft.Isam.Esent.Interop.Api]::RetrieveColumnAsInt64($Session, $JetTable.JetTableid, $Column.Columnid)
                        } catch { $Buffer = "Error"}
                            if ( $Buffer -Ne "Error" ) {
                            try {
                                $DateTime = [System.DateTime]::FromBinary($Buffer)
                                $DateTime = $DateTime.AddYears(1600)

                                if ($DateTime -gt (Get-Date -Year 1970 -Month 1 -Day 1) -and $DateTime -lt ([System.DateTime]::UtcNow.Add($FutureTimeLimit))) {
                                    $Buffer = $DateTime
                                }
                            }
                            catch {}
                        }
                            break
                        }
                        default {
                            Write-Warning -Message "Did not match column type to $_"
                            $Buffer = [System.String]::Empty
                            break
                        }
                    }
                     $Row | Add-Member -type NoteProperty -name $Column.Name -Value $Buffer

                }

                $DBRows += $Row

            } while ([Microsoft.Isam.Esent.Interop.Api]::TryMoveNext($Session, $JetTable.JetTableid))
        }
    }

    Catch{
      Write-Output "Could not read table"
      Break
    }
    return $DBRows
  }

  End{

  }
}

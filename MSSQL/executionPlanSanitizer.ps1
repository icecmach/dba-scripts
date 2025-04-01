# cls;
#=============================================================================
#   File: ExecutionPlanSanitizer.ps1
#
#   Summary: This script sanitizes statement and object information
#	from execution plans.
#
#   Date: March 14, 2011
#
#   Modified: January 19, 2012 - fixes incorrect replacements, and replaces
#       all references as simple strings to leave statement text intact
#       with replacements made as well as replace all object references
#
#   Modified: February 27, 2013 - fixes mismatched column name replacements,
#       adds proper handling for parameter names, and replaces based on parent
#       nodes in the loops
#
#   PowerShell Versions:
#         1.0
#         2.0
#-----------------------------------------------------------------------------
#   Copyright () 2011 Jonathan M. Kehayias, SQLskills.com
#   All rights reserved.
#
#   For more scripts and sample code, check out
#      http://sqlskills.com/blogs/jonathan
#
#   You may alter this code for your own *non-commercial* purposes. You may
#   republish altered code as long as you give due credit.
#
#
#   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
#   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
#   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#   PARTICULAR PURPOSE.
#
#=============================================================================

param(	[Parameter(Mandatory=$TRUE)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FileName)

$xml = New-Object 'System.Xml.XmlDocument'

#Load the showplan from file as both text and XML
$filedata = [string]::Join([Environment]::NewLine,(Get-Content $FileName))
$xml.LoadXml($filedata);

#Setup the XmlNamespaceManager and add the ShowPlan Namespace to it.
$nsMgr = new-object 'System.Xml.XmlNamespaceManager' $xml.NameTable;
$nsMgr.AddNamespace("sm", "http://schemas.microsoft.com/sqlserver/2004/07/showplan");

#Find all Database Name References
$i=1;
$xml.SelectNodes("//sm:ColumnReference", $nsMgr) |`
	where {$_.Database -ne $null -and `
		   $_.Database -ne [string]::Empty} | % `
		{
			$filedata = $filedata.Replace($_.Database.Replace('[', '').Replace(']', ''), "Database_$i");
			$i++;
		}

#Find all non-dbo Schema Name References
$i=1;
$xml.SelectNodes("//sm:ColumnReference", $nsMgr) |`
	where {$_.Schema -ne $null -and `
		   $_.Schema -ne [string]::Empty -and `
		   $_.Schema -ne "[dbo]"} | % `
		{
			$filedata = $filedata.Replace($_.Schema.Replace('[', '').Replace(']', ''), "Schema_$i");
			$i++;
		}

#Find all Table Name References
$i=1;
$xml.SelectNodes("//sm:ColumnReference", $nsMgr) |`
	where {$_.Table -ne $null -and `
		   $_.Table -ne [string]::Empty} | % `
		{
			$filedata = $filedata.Replace($_.Table.Replace('[', '').Replace(']', ''), "Table_$i");
			$i++;
		}

#Find and replace all column name references
$i=1;
$j=1;
$xml.SelectNodes("//sm:ColumnReference", $nsMgr) |`
	where {$_.Column -notlike "Union*" `
			-and $_.Column -notlike "ConstExpr*" `
			-and $_.Column -notlike "Expr*" `
			-and $_.Column -notlike "Uniq*" `
			-and $_.Column -notlike "KeyCo*" `
			-and $_.Column -ne $null `
			-and $_.Column -ne [string]::Empty} | % `
		{
			$ParentNode = $_.ParentNode.Name;
			if($_.ParentNode.Name -ne "ParameterList")
			{
				$filedata = $filedata.Replace($_.Column.Replace('[', '').Replace(']', ''), "Column_$i");
				$i++;
			}
			else
			{
				$filedata = $filedata.Replace($_.Column.Replace('[', '').Replace(']', ''), "@Param_$j");
				$j++;
			}
		}

#Find and replace all alias name references
$i=1;
$xml.SelectNodes("//sm:ColumnReference", $nsMgr) |`
	where {$_.Alias -ne $null -and `
		   $_.Alias -ne [string]::Empty} | % `
		{
			$filedata = $filedata.Replace($_.Alias.Replace('[', '').Replace(']', ''), "Alias_$i");
			$i++;
		}

#Find and replace all index name references
$i=1;
$xml.SelectNodes("//sm:Object", $nsMgr) |`
	where {$_.Index -ne $null `
			-and $_.Index -ne [string]::Empty} | % `
		{
			$filedata = $filedata.Replace($_.Index.Replace('[', '').Replace(']', ''), "Index_$i");
			$i++;
		}

#Find and replace custom expressions
$filedata = $filedata.Replace("text_to_mask", "XXX");

#Write the output to a _Cleaned.sqlplan filename
$outfile = $FileName.Replace(".sqlplan", "_Cleaned.sqlplan")
$filedata | Out-File -FilePath $outfile

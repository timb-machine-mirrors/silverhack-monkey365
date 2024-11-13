﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function Get-MonkeyEXOComplianceTag {
<#
        .SYNOPSIS
		Collector to get information about compliance tags from Exchange Online

        .DESCRIPTION
		Collector to get information about compliance tags from Exchange Online

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyEXOComplianceTag
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false,HelpMessage = "Background Collector ID")]
		[string]$collectorId
	)
	begin {
		$compliance_tags = $null;
		#Collector metadata
		$monkey_metadata = @{
			Id = "purv005";
			Provider = "Microsoft365";
			Resource = "Purview";
			ResourceType = $null;
			resourceName = $null;
			collectorName = "Get-MonkeyEXOComplianceTag";
			ApiType = $null;
			description = "Collector to get information about compliance tags from Exchange Online";
			Group = @(
				"Purview"
			);
			Tags = @(

			);
			references = @(
				"https://silverhack.github.io/monkey365/"
			);
			ruleSuffixes = @(
				"o365_secomp_compliance_tag"
			);
			dependsOn = @(
				"ExchangeOnline"
			);
			enabled = $true;
			supportClientCredential = $true
		}
	}
	process {
		if ($O365Object.onlineServices.Purview -eq $true) {
			$msg = @{
				MessageData = ($message.MonkeyGenericTaskMessage -f $collectorId,"Security and Compliance tags",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'info';
				InformationAction = $InformationAction;
				Tags = @('SecCompTagsInfo');
			}
			Write-Information @msg
			#Get Security and Compliance Auth token
			$ExoAuth = $O365Object.auth_tokens.ComplianceCenter
			#Get Backend Uri
			$Uri = $O365Object.SecCompBackendUri
			#InitParams
			$p = @{
				Authentication = $ExoAuth;
				EndPoint = $Uri;
				ResponseFormat = 'clixml';
				Command = 'Get-ComplianceTag';
				Method = "POST";
				InformationAction = $O365Object.InformationAction;
				Verbose = $O365Object.Verbose;
				Debug = $O365Object.Debug;
			}
			#Get Compliance tags
			$compliance_tags = Get-PSExoAdminApiObject @p
		}
	}
	end {
		if ($compliance_tags) {
			$compliance_tags.PSObject.TypeNames.Insert(0,'Monkey365.SecurityCompliance.Tag')
			[pscustomobject]$obj = @{
				Data = $compliance_tags;
				Metadata = $monkey_metadata;
			}
			$returnData.o365_secomp_compliance_tag = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Security and Compliance tags",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = "verbose";
				InformationAction = $O365Object.InformationAction;
				Tags = @('SecCompTagsEmptyResponse');
				Verbose = $O365Object.Verbose;
			}
			Write-Verbose @msg
		}
	}
}








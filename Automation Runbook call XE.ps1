<#
.PARAMETER instance
    Azure SQL Managed Instance name.

.PARAMETER database
    Database name (case sensitive).

#>

param(

[parameter(Mandatory=$true)]
[string] $instance,

[parameter(Mandatory=$true)]
[string] $database
)

# Getting AccessToken for System assigned Managed Identity
$Resource = "https://database.windows.net/"
$QueryParameter = "?resource=$Resource"
$Url = $env:IDENTITY_ENDPOINT + $QueryParameter
$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
$Headers.Add("X-IDENTITY-HEADER", $env:IDENTITY_HEADER) 
$Headers.Add("Metadata", "True") 
$Content =[System.Text.Encoding]::Default.GetString((Invoke-WebRequest `
    -UseBasicParsing `
    -Uri $Url `
    -Method 'GET' `
    -Headers $Headers).RawContentStream.ToArray()) | ConvertFrom-Json 
$AccessToken = $Content.access_token 
    
## Run Command 
$SqlConnection = New-Object System.Data.SqlClient.SQLConnection  
$SqlConnection.ConnectionString = "Server=$instance;Initial Catalog=$database;Connect Timeout=30" 
$SqlConnection.AccessToken = $AccessToken 

##$SqlCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT @@VERSION", $SqlConnection)
$SqlCommand = New-Object System.Data.SqlClient.SqlCommand("ALTER EVENT SESSION [HighCPU] ON SERVER STATE = START;", $SqlConnection)
$SqlConnection.Open()

$Version = $SqlCommand.ExecuteScalar()

$SqlConnection.Close()
Write-Output $Version

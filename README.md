# Using Azure Metrics, Alerts, and Automation Accounts to start an XE session 

In SQL Server, you can start a SQL Server Agent Job when a Windows PerfMon counter is at/over/under a certain value (“Performance Condition Alert”). Azure SQL Managed Instance (SQL MI) and Azure SQL Database (SQL DB) don’t have that capability.

You can use Azure Monitor Alerts, an Azure Automation Runbook, and PowerShell to accomplish the same thing. 

Note: You could create and start the Extended Events session and leave it running on your SQL MI or SQL DB at all times. This requires far less work and permissions, and is the recommended approach. Use the following method when you do not have the ability to have a session running for an undetermined amount of time. 

## Prerequisites 

1.	You must have a [SQL Managed Instance](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/instance-create-quickstart?view=azuresql&tabs=azure-portal) with an [Extended Event](https://learn.microsoft.com/en-us/azure/azure-sql/database/xevent-db-diff-from-svr?view=azuresql&tabs=sqldb) session created. It should not be running. 
1.	You must have an [Azure Automation account](https://learn.microsoft.com/en-us/azure/automation/quickstarts/create-azure-automation-account-portal) set up. 
1.	Have the account's [Managed Identity](https://learn.microsoft.com/en-us/azure/automation/enable-managed-identity-for-automation) available. (It should be the same as the automation account name.) 

## SQL Managed Instance setup 

Create login and user in SQL MI master database for the Automation managed identity using the script [SQL perms for Auto Runbook with XE.sql.](./SQL%20perms%20for%20Auto%20Runbook%20with%20XE.sql)

## Automation Runbook setup 

Create Runbook using the script [Automation Runbook call XE.ps1.](./Automation%20Runbook%20call%20XE.ps1) The first section passes the automation account’s managed identity token to authenticate to the MI. The second section creates a connection and runs a T-SQL command. 

## Alert setup
Set up the Alert using the Azure portal. Go to SQL MI > Monitoring > Alerts. 
- + Create Alert Rule. 
    - Scope – can be subscription, resource group, or MI. Select your MI. 

(/images/Create-an-alert-rule-scope.png)

- Condition 
    - Signal Name – Average CPU percent 
    - Threshold type – Static 
    - Aggregation type – Maximum 
    - Value is – Greater than 
    - Threshold – set %; this example shows 80% 
    - Check every – 1 minute 
    - Lookback period – 5 minutes 
 
(/images/Create-an-alert-rule-condition.png)

- Actions 
    - Select Actions – Use action groups 
    - + Create action group 
        - Create action group 
            - Basics 
                - Subscription – your subscription 
                - Resource group – your resource group 
                - Region – Global 
                - Action group name – enter name 
                - Display name – enter display name 
(/images/Create-action-group-Basics.png)

            - Notifications (Optional) 
                - Notification type – Email/SMS…
                - Name – enter name 
                - Check Email 
                - Enter email address(es) – group to send notification of this alert being triggered to 
(/images/Create-action-group-Notifications.png)

            - Actions 
                - Action type – Automation runbook 
                - Name – enter name 
                - Run runbook – Enabled 
                - Runbook source – User 
                - Subscription – your subscription 
                - Automation account – the automation account you have runbook in 
                - Runbook – the runbook you created 
                - Parameters – configure Instance and Database
(/images/Create-action-group-Actions.png)

- Review and Create 

- Back to Actions > Go to Details. 
	- Project details 
	- Subscription – your sub 
	- Resource group – your rg 
	- Alert rule details – this is for your information only 
	- Severity – choose 0 to 4 
	- Alert rule name – name 
	- Alert rule description – description 

(/images/Create-an-alert-rule-Details.png)

- Review and Create 

You now have a system where, if an Azure Metric is above/at/below a threshold, an Alert is triggered, a runbook is started, and an XE session is started. 


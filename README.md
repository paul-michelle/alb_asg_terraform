## Terraform Cloud Set-Up

Set 'Terraform Working Directory' at 'https://app.terraform.io/app/{user_name}/workspaces/{workspace_name}/settings/general' for
each environment ('dev', 'stg', 'qa', etc).

Set 'AWS_ACCESS_KEY_ID' and 'AWS_SECRET_ACCESS_KEY' (sensitive, write-only) at 'https://app.terraform.io/app/{user_name}/workspaces/{workspace_name}/variables' for each 
environment ('dev', 'stg', 'qa', etc) with appropriate permissions.
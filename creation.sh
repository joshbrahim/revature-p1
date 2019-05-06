#!/bin/bash
group=$1
storage=$2
container=$3
db=$4
subscription=$5
jimge=jimge$RANDOM

#create appservice
# Replace the following URL with a public GitHub repo URL
gitrepo=https://github.com/joshbrahim/revature-p1


# Create a resource group.
az group create \
    --location southcentralus \
    --name $group

# Create an App Service plan in STANDARD tier (minimum required by deployment slots).
az appservice plan create \
    --name $jimge \
    --resource-group $group \
    --sku B1 \
    --number-of-workers 3 \
    -l southcentralus

# Create a web app.
az webapp create \
    --name $jimge \
    --resource-group $group \
    --plan $jimge

#Create a deployment slot with the name "staging".
az webapp deployment slot create \
    --name $jimge \
    --resource-group $group \
    --slot staging

# Deploy sample code to "staging" slot from GitHub.
az webapp deployment source config \
    --name $jimge \
    --resource-group $group \
    --slot staging \
    --repo-url $gitrepo \
    --branch master \
    --manual-integration

# Copy the result of the following command into a browser to see the staging slot.
echo http://$jimge-staging.azurewebsites.net

# Swap the verified/warmed up staging slot into production.
az webapp deployment slot swap \
    --name $jimge \
    --resource-group $group \
    --slot staging

# Copy the result of the following command into a browser to see the web app in the production slot.
echo http://$jimge.azurewebsites.net


#create storage
az storage account create \
    --name $storage \
    --resource-group $group \
    -l southcentralus \
    --sku Standard_LRS

#Create Storage Container
az storage container create \
    --name $container \
    --account-name $storage

#create storage blob
az storage blob upload-batch \
    -d $container \
    --account-name $storage \
    --account-key "AZURE_STORAGE_KEY" \
    -s ./public/uploads

#link storage to web app
az webapp config storage-account add \
    --resource-group $group \
    --name $jimge \
    --custom-id customID \
    --storage-type AzureBlob \
    --share-name $container \
    --account-name $storage \
    --access-key "AZURE_STORAGE_KEY" \
    --mount-path /storage

#verification?
#az webapp config storage-account list --resource-group $group --name $jimge

#create azcosmos account
az cosmosdb create \
    --name $db \
    --resource-group $group \
    --kind GlobalDocumentDB \
    --default-consistency-level "Session" \
    --subscription $subscription \
    --enable-multiple-write-locations true

#create az cosmos db
az cosmosdb database create \
    --resource-group $group \
    --name $jimge \
    --db-name $db

#create az cosmos sql api container
az cosmosdb collection create \
    --resource-group $group \
    --collection-name $container \
    --name $jimge \
    --db-name $db \
    --partition-key-path /mypartitionkey \
    --throughput 1000

#verification?
#az cosmosdb show -n $db -g $group --subscription $subscription

exit 0
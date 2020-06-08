#!/bin/bash

set -x
# Function app and storage account names must be unique.
# $RANDOM for using random variable content as you need unique naming

random=$RANDOM
export storageName="sa${random}"
export functionAppName="functionApp${random}"
export region='westeurope'
export resourcegroup="rg-${random}"
export pythonVersion='3.7'

# Create a resource group
az group create --name $resourcegroup --location $region



# Create an Azure storage account in the resource group.
az storage account create \
  --name $storageName \
  --location $region \
  --resource-group $resourcegroup \
  --sku Standard_ZRS

export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name $storageName |jq .connectionString)
if [ -z "$AZURE_STORAGE_CONNECTION_STRING" ] 
then
  echo "Please set AZURE_STORAGE_CONNECTION_STRING env variable!"
else
  echo "Found AZURE_STORAGE_CONNECTION_STRING var"
fi

# Create a storage queue named 
az storage queue create --name "randomstuff" --account-name $storageName --auth-mode login
az storage queue create --name "inputqueue" --account-name $storageName --auth-mode login

# Create a storage table named
az storage table create --name "message" --account-name $storageName --connection-string $AZURE_STORAGE_CONNECTION_STRING

#Create a serverless function app in the resource group.

az functionapp create \
  --resource-group $resourcegroup  \
  --consumption-plan-location $region \
  --os-type Linux \
  --runtime python \
  --runtime-version $pythonVersion \
  --functions-version 2 \
  --storage-account $storageName \
  --name $functionAppName 

echo "Waiting a few seconds"
sleep 20

#publish
func azure functionapp publish $functionAppName --publish-local-settings

#start logstream #only windows apps
#func azure functionapp logstream $functionAppName

#start browser based app insights 
func azure functionapp logstream $functionAppName --browser

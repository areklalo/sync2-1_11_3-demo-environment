#!/bin/bash
: ${demoenv_sync2_module_manage:=true}
: ${demoenv_sync2_module_name_sync2:=sync2}
: ${demoenv_sync2_module_version_sync2:=latest}
: ${demoenv_sync2_module_name_atomfeed:=atomfeed}
: ${demoenv_sync2_module_version_atomfeed:=latest}
: ${demoenv_sync2_module_name_fhir:=fhir}
: ${demoenv_sync2_module_version_fhir:=latest}

export demoenv_sync2_module_manage
export demoenv_sync2_module_name_sync2
export demoenv_sync2_module_version_sync2
export demoenv_sync2_module_name_atomfeed$destinationDir
export demoenv_sync2_module_version_atomfeed
export demoenv_sync2_module_name_fhir
export demoenv_sync2_module_version_fhir

TEMP_MODULE_DIR=./TEMP_MODULES
DEFAULT_DESTIONATION_DIR=./modules
MODULE_NAME_PREFIX=demoenv_sync2_module_name_
MODULE_VERSION_PREFIX=demoenv_sync2_module_version_
mkdir -p $TEMP_MODULE_DIR

function trimString() {
  value=$1
  value=$(echo $value | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  echo $value
}

function getTheLastVersion()
{
  moduleName=$1
  if [ ! -z $moduleName ]; then
    latestVersion=$(curl -I https://bintray.com/openmrs/omod/$moduleName/_latestVersion | grep "Location:" | sed -E 's/.*\/([.0-9]*)/\1/' )
    latestVersion=$(trimString $latestVersion)
    echo $latestVersion
  fi
}

function downloadModule() {
  moduleName=$1
  moduleVersion=$2
  if [ ! -z $moduleName ]; then
    if [ -z $moduleVersion ]; then
      moduleVersion=$(getTheLastVersion $moduleName)
      echo "The latest version will be use for the $moduleName module"
    fi
    url="https://dl.bintray.com/openmrs/omod/"$moduleName"-"$moduleVersion".omod"
    echo "Downloading "$moduleName $moduleVersion" module from "$url"..."
    curl -L $url -o "$TEMP_MODULE_DIR/$moduleName-$moduleVersion.omod"
  else
    echo "The module name is required."
  fi
}

function extractModuleName() {
  key=$1
  key=$(echo $key | sed -E "s/.*=(.*)/\1/")
  echo $key
}

function extractModuleVersion() {
  key=$1
  keySufix=$(echo $moduleEnv | sed -E "s/$MODULE_NAME_PREFIX(.*)=.*/\1/")
  version=$(printenv $MODULE_VERSION_PREFIX$keySufix)
  version=$(trimString $version)
  if [ -z $version ]; then
    version=latest
  fi
  echo $version
}

function copyTempModulesToDestinationDir() {
  processedModuleName=$1
  dir=$2
  if [ ! -z $processedModuleName ]; then
    echo "Remove old module "$processedModuleName" version from "$dir
    rm -v $dir/"$processedModuleName"*
    echo "Copying module from "$TEMP_MODULE_DIR" to "$dir
    cp -v $TEMP_MODULE_DIR/"$processedModuleName"* $dir/
  fi
}

function processAllModules() {
  destinationDir=$1
  listOfModules=$(printenv | grep "^$MODULE_NAME_PREFIX")

  for moduleEnv in $listOfModules; do
    extractedModuleName=$(extractModuleName $moduleEnv)
    extractedModuleVersion=$(extractModuleVersion $moduleEnv)
    echo "Procesing "$extractedModuleName" ("$extractedModuleVersion")..."
    if [ "$extractedModuleVersion" = "latest" ]; then
      downloadModule $extractedModuleName
    else
      downloadModule $extractedModuleName $extractedModuleVersion
    fi
    copyTempModulesToDestinationDir $extractedModuleName $destinationDir
  done
}

function cleanTempModules() {
  echo "Removing temporary modules from "$TEMP_MODULE_DIR
  rm -v $TEMP_MODULE_DIR/*
}

function main() {
  shouldManage=$(printenv demoenv_sync2_module_manage)
  if [ "$shouldManage" = "true" ]; then
    destinationDir=$1
    if [ -z $destinationDir ]; then
      destinationDir="$DEFAULT_DESTIONATION_DIR"
      mkdir -p $destinationDir
      echo "The default value of destination dir will be used:"$destinationDir
    fi
    processAllModules $destinationDir
    cleanTempModules
  else
    echo "The modules management is disabled."
  fi
}

main $1

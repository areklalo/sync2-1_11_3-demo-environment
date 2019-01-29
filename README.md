# sync2-1_11_3-demo-environment

## Description
Run OpenMRS platform instances (1.11.3) and mysql as docker containers.

## Requirements
  - Docker engine
  - Docker compose

## How to use manageModules script

### Description
  The manageModules.sh script can be used to download OMOD files from the https://bintray.com/openmrs/omod/.
  The script is controlled by environment variables (more info below), downloading all modules which have to a defined environment variable with a specific prefix.

### Controll
* The script by default copying all pulled files to "./modules" directory.
  In order to change the default destination directory you can execute the script with path:
  ```
  $ ./manageModules.sh {path_to_destination_directory}
  ```
  Example:
  ```
  $ ./manageModules.sh ./destinationDir
  ```
* The script by default downloading the latest version of following modules:
  * Sync2
  * Atomfeed
  * FHIR

  In order to change the version of the above modules or add other modules
  you need to change the environment variables. The script uses two types of environment variables:
  * demoenv_sync2_module_name_{moduleId}={moduleName} - used to define the name of the module
  * demoenv_sync2_module_version_{moduleId}={moduleVersion} - used to define the version of the module

  Where:
  * {moduleId} - is the module identifier e.g. `sync2` (NOTE the environment variable identifier can't contain ".", "-" etc.)
  * {moduleName} - is the name of the module e.g. `sync2` (name of the module which can be found here: https://dl.bintray.com/openmrs/omod/)
  * {moduleVersion} - is the version of the module e.g. `1.4.0` (version of the module which can be found here: https://dl.bintray.com/openmrs/omod/). If you want always the latest version of the module you should set the `latest` value.

  In order to change the version of the Sync 2.0 module you should override the environment variable. Example:
  ```
  $ export demoenv_sync2_module_version_sync2=1.3.0
  ```

  In order to add another module you should add environment variables. Example:
  ```
  $ export demoenv_sync2_module_name_webServiceRest=webservices.rest
  $ export demoenv_sync2_module_version_webServiceRest=latest
  ```
* The module managing could be disabled. In order to do that you need to change the value
  of `demoenv_sync2_module_manage` environment variable. Example:
  ```
  $ export demoenv_sync2_module_manage=false
  ```

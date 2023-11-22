# openmrs-module-ohri-mamba-core

## **Background**

MambaETL (or simply known as Mamba) is an OpenMRS (Open Electronic Medical Records System) implementation of data Extraction, Loading and Transforming (ETL) of data into a more denormalised format for faster data retrieval and analysis.

OpenMRS stores patient observational data in a long format. Essentially, for each encounter type for a given patient, multiple rows are saved into the OpenMRS Obs table. Sometimes as many as 50 or more rows saved for a single encounter in just the Obs table.

This means that the Obs table quickly grows to millions of records in fairly sized facilities making reporting and any analysis on such data incredibly slow and difficult.

## **Purpose of this module**

The `openmrs-module-ohri-mamba-core` or simply called the MambaETL Core module is an OpenMRS module that is a collection of familiar artefacts/tooling that collectively offer out-of-the box database flattening/transposing and abstraction of repetitive reporting tasks 
so that implementers, analysts, data scientists or teams building reports focus on building without worrying about performance bottlenecks or bothering too much about how the data is extracted from the primary data source into the reporting destination.

Artefacts in this module include:
* SQL scripts (functions, views & stored procedures), 
* An automation engine/bash/shell scripts, 
* Maven configurations, 
* and Java functionality

## **How to use the module**
This module is intended to be added or included in your main reporting module.   
We have developed a reference or template module called [openmrs-module-ohri-mamba-ref](https://github.com/UCSF-IGHS/openmrs-module-ohri-mamba). We strongly recommend that your refer to this module to quickly get started with your project or clone it and use it as a starting place building your own module that uses MambaETL.  

After you have added the MambaETL core module dependencies and configurations to your own reporting module, you can go ahead and deploy your module normally, all the MambaETL functionality will be available to your module. 

## **Setting up MambaETL: A technical deep dive**

Please refer to the reference or template module called [openmrs-module-ohri-mamba-ref](https://github.com/UCSF-IGHS/openmrs-module-ohri-mamba) when setting up MambaETL.  

Pre-requisites:
-
1. Make sure to install the latest version of `jq`. [Click here](https://jqlang.github.io/jq/download/) to download and install.  
   `jq` is a command-line JSON processing tool, for dealing with machine-readable data formats and is especially useful in shell scripts.  
   We use `jq` to manipulate `json` in our shell scripts.


2. To develop and build your MambaETL supported project, please note: **you need a Linux based platform** such as a Ubuntu, CentOS or MacOS developer machine.  
   This is so because the MambaETL engine is currently built in bash and has not been ported to other environments i.e. Windows.  
   However, note that **you do not need Linux to run MambaETL** only for developing or building the omod.  

<span style='color: red;'>Step 1:</span>  

Copy the example `_etl` folder from the [MambaETL reference/template](https://github.com/UCSF-IGHS/openmrs-module-ohri-mamba) module under `omod/src/main/resources` to your own `resources` folder under the `omod` submodule.  

![Screenshot 2023-11-22 at 08.58.58.png](..%2F..%2F..%2F..%2FDesktop%2FScreenshot%202023-11-22%20at%2008.58.58.png)
Under the `_etl` folder are other sub-folders and files, you will need to edit them according to your needs.  

<span style='color: red;'>Step 2:</span>  

Go to the `config.xml` file still under the `resources` folder and add the MambaETL database configuration default properties.  
These properties can also be added via the legacy admin UI as global properties.  

MambaETL depends on this database configuration to connect to the **ETL** database for processing.  
Note: the **ETL** database name is configured in the parent `pom.xml` file of your project. More on this file configurations later.

![Screenshot 2023-11-22 at 09.10.21.png](..%2F..%2F..%2F..%2FDesktop%2FScreenshot%202023-11-22%20at%2009.10.21.png)

The configured database user above must have super access to the **ETL** database to drop and create stored-procedures/views, functions, tables etc.  
They also need select grant access to the transactional (openmrs) database.

In the above configuration, `analysis_db` is the **ETL** database name

<span style='color: red;'>Step 3:</span>

Go to the `omod/pom.xml` and add the MambaETL core module dependency and any other required dependencies such as `the rest module` dependencies.

![Screenshot 2023-11-22 at 09.17.11.png](..%2F..%2F..%2F..%2FDesktop%2FScreenshot%202023-11-22%20at%2009.17.11.png)






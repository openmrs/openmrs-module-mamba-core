# openmrs-module-ohri-mamba-core

## **Background**

MambaETL (or simply known as Mamba) is an OpenMRS (Open Electronic Medical Records System) implementation of data Extraction, Loading and Transforming (ETL) of data into a more denormalised format for faster data retrieval and analysis.

OpenMRS stores patient observational data in a long format. Essentially, for each encounter type for a given patient, multiple rows are saved into the OpenMRS Obs table. Sometimes as many as 50 or more rows saved for a single encounter in just the Obs table.

This means that the Obs table quickly grows to millions of records in fairly sized facilities making reporting and any analysis on such data incredibly slow and difficult.

## **Purpose of this module**

The `openmrs-module-ohri-mamba-core` or simply called the MambaETL Core module is an OpenMRS module that is a collection of familiar artefacts/tooling that collectively offer out-of-the box database flattening/transposing and abstraction of repetitive reporting tasks 
so that implementers, analysts, data scientists or teams building reports focus on building without worrying about system performance bottlenecks or bothering too much about how the data is extracted from the primary data source into the reporting destination.

Artefacts in this module include:
* SQL scripts (functions, views & stored procedures), 
* An automation engine/bash/shell scripts, 
* Maven configurations, 
* and Java functionality

## **How to use the module**
This module is intended to be added or included in your main reporting module.   
We have developed a reference or template module called [openmrs-module-ohri-mamba-ref](https://github.com/UCSF-IGHS/openmrs-module-ohri-mamba). We strongly recommend that your refer to this module to quickly get started with your project or clone it and use it as a starting point to building your own module that uses MambaETL.  

After you have added the MambaETL core module dependencies and configurations to your own reporting module, you can go ahead and deploy your module normally. All the MambaETL functionalities will be available to your module. 

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

Create or go to your custom Reporting module, or clone [MambaETL reference/template](https://github.com/UCSF-IGHS/openmrs-module-ohri-mamba) as a starter project.  

Below is an example folder structure of your project when you have added all the relevant folders and files required to support MambaETL in your project.  

![Screenshot 2023-11-23 at 08.09.43.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-23%20at%2008.09.43.png)


<span style='color: red;'>Step 2:</span>

Create the MambaETL build folder named: `mamaba` under the resources folder.  
Leave the folder empty. Everytime you build your project, 2 MambaETL build files are created under this folder replacing the old files if existing.  

The MambaETL build files created under `mamba` folder are:  

`create_stored_procedures.sql`
`liquibase_create_stored_procedures.sql`

The `create_stored_procedures.sql` is an SQL compliant file. It contains all the ETL scripts that have been compiled into one 'big' script ready for deployment.  
This file can be run against your ETL target database as-is, mostly for development and test purposes when you need to quickly and manually run your ETL scripts and test them out.  

The `liquibase_create_stored_procedures.sql` is referenced in the `liquibase.xml` changeset. It has similar contents as the first file but is compliant to liquibase.  
The file is automatically run by Liquibase when deploying your module. It also contains all the ETL scripts that have been compiled into one 'big' SQL script file.

<span style='color: red;'>Step 3:</span>  

Ensure your `api` submodule has the structure as shown in the image below. We will go through the relevant files/folders one by one.  

![Screenshot 2023-11-23 at 08.05.21.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-23%20at%2008.05.21.png)

<span style='color: red;'>Step 4:</span>

`../api/pom.xml`  

Under your MambaETL supported project created/cloned in `Step 1` above, go to the `api` submodule and in the pom xml add the dependency entry for the [MambaETL core module](https://github.com/UCSF-IGHS/openmrs-module-ohri-core) api dependency.

![Screenshot 2023-11-23 at 07.50.10.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-23%20at%2007.50.10.png)

<span style='color: red;'>Step 5:</span>

`../api/../resources/liquibase.xml`

Add a MambaETL liquibase changeset to your liquibase file

![Screenshot 2023-11-23 at 07.59.53.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-23%20at%2007.59.53.png)

This Liquibase Changeset ensures the MambaETL `Stored Procedures` and `Functions` are deployed on your target ETL database.  
The changeset deletes and re-creates all given Stored procedures and functions everytime it is run ensuring any new changes/modifications to the ETL are deployed.


<span style='color: red;'>Step 6:</span>  

Copy the example `_etl` folder from the [MambaETL reference/template](https://github.com/UCSF-IGHS/openmrs-module-ohri-mamba) module under `omod/src/main/resources` to your own `resources` folder under the `omod` submodule of your project.  


![Screenshot 2023-11-22 at 08.58.58.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-22%20at%2008.58.58.png)
Under the `_etl` folder are other sub-folders and files, you will need to edit them according to your needs.  

<span style='color: red;'>Step 7:</span>  

`/omod/../resources/config.xml`  

Add the MambaETL database configuration default properties to the config xml file.  
These properties can also be added via the legacy admin UI as global properties.  

MambaETL depends on this database configuration to connect to the **ETL** database for processing.  
Note: the **ETL** database name is configured in the parent `pom.xml` file of your project. More on this file configurations later.

![Screenshot 2023-11-22 at 09.10.21.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-22%20at%2009.10.21.png)

The configured database user above must have super access to the **ETL** database to drop and create stored-procedures/views, functions, tables etc.  
They also need select grant access to the transactional (openmrs) database.

In the above configuration, `analysis_db` is the **ETL** database name

<span style='color: red;'>Step 8:</span>

`/omod/../resources/webModuleApplicationContext.xml`  

add the entry below to the bean context file:

![Screenshot 2023-11-23 at 07.41.51.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-23%20at%2007.41.51.png)

<span style='color: red;'>Step 9:</span>

`../omod/../pom.xml`  

In the omod pom.xml add the MambaETL core module dependency and any other required dependencies such as `the rest module` dependencies.

![Screenshot 2023-11-22 at 09.17.11.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-22%20at%2009.17.11.png)


<span style='color: red;'>Step 10:</span>

Still within the `omod/pom.xml` ensure you have added all the necessary plugins. MambaETL depends on a number of plugins to copy dependencies, execute shell scripts, etc.  

![Screenshot 2023-11-22 at 09.37.46.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-22%20at%2009.37.46.png)


<span style='color: red;'>Step 11:</span>

`../pom.xml`

A number of configurations have to be made in the root/parent pom file of your project.  
Make sure you have configured the necessary plugins, ETL source and target database names, etc.  
We advise that you look at or copy the MambaETL ref/template module root/parent [pom.xml](https://github.com/UCSF-IGHS/openmrs-module-ohri-core/blob/master/pom.xml) file for details as there are a number of configurations in this file.  

Notably, don't forget to specify the names of your OpenMRS source database and the ETL target database in this pom file.  

![Screenshot 2023-11-23 at 09.18.53.png](..%2F..%2F..%2F..%2F_markdown%2FScreenshot%202023-11-23%20at%2009.18.53.png)

<span style='color: red;'>Step 11:</span>

`Building your project`

MambaETL as earlier described, consists of a bash 'engine' and SQL compliant scripts for your reporting needs.  
Execution of all these files is supported by the various maven plugins added to your maven project.  

This makes it possible to follow the maven lifecycle methods to build your final MambaETL deloyment scripts that are stored in the `mamba` folder discussed in `step 2`  

Run:  
`mvn clean install`  
This command will build all your MambaETL scripts and create 2 files under the build folder in `step 2` i.e. `mamba`  

That's all you need to do to prepare your deployment scripts.  
Go ahead and deploy your module normally and enjoy `MambaETL` at work!

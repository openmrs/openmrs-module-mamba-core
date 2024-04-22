![MambaETL.png](_markdown%2FMambaETL.png)

# openmrs-module-mamba-core

## **Background**

MambaETL (or simply known as Mamba) is an OpenMRS (Open Electronic Medical Records System) implementation of data Extraction, Loading and Transforming (ETL) of data into a more denormalised format for faster data retrieval and analysis.

OpenMRS stores patient observational data in a long format. Essentially, for each encounter type for a given patient, multiple rows are saved into the OpenMRS Obs table. Sometimes as many as 50 or more rows saved for a single encounter in just the Obs table.

This means that the Obs table quickly grows to millions of records in fairly sized facilities making reporting and any analysis on such data incredibly slow and difficult.

## **Purpose of this project**

The `openmrs-module-mamba-core` or simply called the MambaETL Core module is an OpenMRS module that is a library collection of familiar artefacts/tooling that collectively offer out-of-the box database flattening/transposing and abstraction of repetitive reporting tasks 
so that implementers, analysts, data scientists or teams building reports focus on building without worrying about system performance bottlenecks or bothering too much about how the data is extracted from the primary data source into the reporting destination.

`openmrs-module-mamba-core` is supposed to be a dependency used in any OpenMRS module that seeks to leverage the functionality of MambaETL.
One such example module that shows how to use `openmrs-module-mamba-core` is the quick start or example module found [here](https://github.com/UCSF-IGHS/openmrs-module-mamba-etl):

Artefacts in this module include:
* SQL scripts (functions, views & stored procedures), 
* An automation engine/bash/shell scripts, 
* Maven configurations (Maven 3.1.0 & above), 
* Java functionality (JAVA 7 & above)

## **How to use the module**
This module is intended to be added or included in your main reporting  or ETL module as a dependency library (more on this later).   
We have developed a reference/quick-start or template module called [openmrs-module-mamba-etl](https://github.com/UCSF-IGHS/openmrs-module-mamba-etl). We strongly recommend that your refer to this module to quickly get started with your project or clone it and use it as a starting point to building your own module that uses MambaETL.  

After you have added the MambaETL core module dependencies and configurations to your custom reporting/ETL module or the quick start module, you can go ahead and deploy your module normally. All the MambaETL functionalities will be available to your module. 

Please refer to the reference/quick-start or template module called [openmrs-module-mamba-etl](https://github.com/UCSF-IGHS/openmrs-module-mamba-etl) when setting up MambaETL. 


## **To contribute and build this module**


Pre-requisites:
-
1. Make sure to install the latest version of `jq` before building this module (running mvn install). [Click here](https://jqlang.github.io/jq/download/) to download and install.  
   `jq` is a command-line JSON processing tool, for dealing with machine-readable data formats and is especially useful in shell scripts.  
   We use `jq` to manipulate `json` in our shell scripts.


2. To develop and build your MambaETL supported project, please note: **you need a Linux based platform** such as a Ubuntu, CentOS or MacOS developer machine.  
   This is so because the MambaETL engine is currently built in bash and has not been ported to other environments i.e. Windows.  
   However, note that **you do not need Linux to run MambaETL** only for developing or building the omod.  


3. Currently, MambaETL only supports MySQL database engine; and has been successfuly tested on versions 5.6 and above.


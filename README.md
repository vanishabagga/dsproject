# README
CSI 4142 – Fundamentals of Data Science

Group #34
Harman Sekhon, 300166902
Darby Martin, 300198642
Vanisha Bagga, 300191679

Project Overview

This repository contains csv data, SQL, and Jupyter notebooks used for preprocessing and analyzing datasets. 

Repository Structure
csv: This directory holds all the CSV files that are used for bridges, dimensions, and fact tables. These CSVs are ready for import into the database.

csv_queries: Contains the CSV outputs from the PostgreSQL queries. 

postgres: Includes SQL code for both initializing the database setup (dimensionfacttables.sql) and for the queries (olap_queries.sql). It is the starting point for setting up the database schemas and for performing data manipulations.

prep_csv: Consists of intermediary CSV files that are used to create some of the final CSVs in the csv folder. 

random_forest.ipynb: Used to do the Random Forest machine learning algorithm to predict target variables.

Other Jupyter notebooks (.ipynb): Used for data cleaning and preprocessing. Each notebook is named according to the specific cleaning or preprocessing task it performs.

** dimensionfacttables.sql can be run in PostgreSQL in the query tool to create and load the tables for the database. queries.sql can be run after database has been created and CSVs have been imported into corresponding tables.
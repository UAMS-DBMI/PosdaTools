# Posda
  * A suite of tools used for the archival, curation, and de-identification of medical imaging datasets


Posda is a suite of medical image curation tools developed by the The Cancer Imaging Archive(TCIA) team. Originally the
"Perl Open Source DICOM Archive" tool, the project has expanded to include tools written in not only Perl, but also Python, Javascript, and more. In addition, while much of the functionality is focused on DICOM image files, many functions are now being designed to support other datatypes. The suite is hosted in a docker container, which contains the main Posda application, the database, and other applications and software tools used in the Posda
curation process.

For  image collections to be useful, the imaging data must be organized, and contain as much data as possible while avoiding revealing any personal health information(PHI). The TCIA team developed a process of curating the collections that is used to organize the collections, remove all personal health information, and leave as much useful data as possible. As part of that process, the Posda curation tools were developed.

Imaging collection curation is a process that many other projects and organizations could find useful. Perhaps you are part of a different project that manages image collections and wishes to make use of the Posda tool suite. Posda was envisioned to be agnostic to the
organization using it, so that other research projects can use these tools as part of their own curation process.


This is Posda, packaged as a set of docker containers (microservices).

## Installation Guide

https://code.imphub.org/projects/PT/repos/oneposda/browse/docs/src/installation.md

## User Guide

https://posda.com/wp-content/uploads/PosdaABC_11_23.pdf

The user guide for Posda  includes detailed explanations for curation and de-identification steps including:

 * Collection Preparation
 * Importing Data
 * Using Queries
 * Associate Imported Data with an Activity Timepoint
 * Create Timepoint From All Files in Import Event List
 * Patient Mapping
 * Run Count Checks
 * Check for Duplicate SOPs
 * Run Consistency Check
 * Verify DICOM IOD (Dciodvfy)
 * Visual Review
 * Removing Bad Data
 * PHI Review
 * Check Struct linkage
 * Link RT Data
 * Send to Server / Repository
 * Compare Posda Data to Server Data for verification

## Images
<details>
  <summary>Network Diagram:</summary>
  <img src="https://posda.com/wp-content/uploads/Posda-Client-Network-Diagram-r1.3.png" name="Posda_Network_Diagram" alt="Posda Network Diagram">
</details>
<details>
  <summary>Landing Page Example Screenshots</summary>
  <img src="./Posda_example_images/Example_posda_launcher_page1.png" name="Example_posda_launcher_page1.png" alt="Posda toolset landing page">
  <img src="./Posda_example_images/Example_Posda_main_application_launcher.png" name="Example_Posda_main_application_launcher.png" alt="Posda Main Application Launcher.png">
</details>
<details>
  <summary>Posda Main Application - Activity Based Curation Module-  Example Images and Screenshots</summary>
  <img src="./Posda_example_images/Example_ABC_UI.png" name="Example_ABC_UI.png" alt="Activity Based Curation module interface">
  <img src="./Posda_example_images/Example_ABC_UI_Query_Page_with_labels.png" name="Example_ABC_UI_Query_Page_with_labels.png" alt="ABC Query Page with labels">
  <img src="./Posda_example_images/Example_ABC_US_QueryResults.png" name="Example_ABC_UI_QueryResults.png" alt="ABC Query Results">
  <img src="./Posda_example_images/Example_ABC_UI_Running_a_process_from_query_results_with_labels.png" name="Example_ABC_UI_Running_a_process_from_query_results_with_labels.png" alt="ABC Running a process from query_results with labels.png">
  <img src="./Posda_example_images/Example_Uploading_Edits.png" name="Example_Uploading_Edits.png" alt="Example of Spreadsheet for Running an Edit">
  <img src="./Posda_example_images/Example_ABC_UI_process_completion_inbox_item.png" name="Example_ABC_UI_process_completion_inbox_item.png" alt="ABC Process Completion Results">
  <img src="./Posda_example_images/Example_ABC_UI_accept_edits.png" name="Example_ABC_UI_accept_edits.png" alt="Example ABC Process Results with buttons to accept or reject proposed DICOM file edits">
</details>
<details>
  <summary>Posda Helper Applications -  Example Screenshots</summary>
  <img src="./Posda_example_images/Example_DICOM_roots_application.png" name="Example_DICOM_roots_application.png" alt="DICOM Collection ID creation application: DICOM Roots Editor">
  <img src="./Posda_example_images/Example_Kaliedoscope_UI.png" name="Example_Kaliedoscope_UI.png" alt="DICOM Visual Review application: Kaliedoscope">
  <img src="./Posda_example_images/Example_QuinceUI.png.png" name="Example_QuinceUI.png" alt="Lightweight DICOM  Viewer Quince">
</details>

<sub>© 2022 The Board of Trustees of the University of Arkansas</sub>

<sub>This project has been funded in whole or in part with federal funds from the National Cancer Institute, National Institutes of Health under grant U24CA215109 and Contract No. 75N91019D00024, Subcontract 20X023F. The content of this publication does not necessarily reflect the views or policies of the Department of Health and Human Services, nor does mention of trade names, commercial products, or organizations imply endorsement by the U.S. Government.</sub>

<sub>Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License.</sub>

<sub>You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

<sub>Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.</sub>

https://posda.com

# This is the test guide for Posda.

## Things to consider
* Make sure your preferred browser will allow pop-ups from the posda application.
* Make sure you have a user account in Posda
* Ensure your version of Posda to be tested is installed and running
* Ensure you have the Posda Importer GUI installed on the machine you intend to test

## If running locally from scratch
* locate the oneposda directory
* open a terminal
* type `./init` this will update your docker image
* type `./manage up` this will bring up your database and applications

## Download the DicomTestSet test data
* Found here: https://pathology.cancerimagingarchive.net/download/other/DicomTestSet.tgz

## Import the Data for Creation

### Option 1: Using the Posda GUI importer
* Locate your copy of the DicomTestSet
* Open the Posda Importer GUI
  * ![alt text](testing_docs_images/Importer1.png "Posda Importer GUI Start Screen")
* Click "Create New Import"
  * ![alt text](testing_docs_images/Importer2.png "Posda Importer New Import Screen")
* Beginning on the left side of the window, Choose a name for the import
* Click Select Directory
  * ![alt text](testing_docs_images/Importer3.png "Posda Importer Directory Selection")
* Select the DicomTestSet test data directory,
  * Data about the folder should appear in the window (Here is an example with non-DicomTestSet data, DicomTestSet has 628 files)
  * ![alt text](testing_docs_images/Importer4.png "Posda Importer Directory Info")
* Choose your Environment (Local for testing, Production for actual work, your options are handled in the config files)
* Click "Create Import Event and Begin"
* Wait for files to complete importing, since this is test data it should have 0 errors. Real data will often have issues to investigate using the Logs.
* Once the DicomTestSet data is fully imported you may close the application

### Option 2: Using DICOM Send
* Open the DicomTestSet directory in your preferred DICOM editor
* Setup the location for PosdaLocal in your preferences
* Select a subset of files to Send
* Click Send

## Open Posda and Login
* Go to the URL in your browser (if local, go to localhost)
  * You should arrive on the shared landing page for Posda and other related applications
  * ![alt text](testing_docs_images/landing.png "Landing Page")
* Click Posda Login
  * You are now on the Posda Login Page
* ![alt text](testing_docs_images/login.png "Login Page")
* In the upper right, put in your credentials and hit Submit
  * Once logged in the list of Apps your account has direct access to appears
  * ![alt text](testing_docs_images/PosdaApps.png "Posda Apps")

## Open DBIF
* In the row labeled Dbif (Database Interface) click Launch
  * Wait for the popup window to load
  * If nothing happens confirm that your browser is allowing popups from localhost
  * ![alt text](testing_docs_images/DBIF.png "DBIF")

## Create the Activity
* Go to Activity in the left side bar
  * ![alt text](testing_docs_images/Activity.png "Activity")
* Create a New Activity by entering the name in the input text box
* Then Click Save
  * ![alt text](testing_docs_images/createAct.png "Create Activity")

## Create the Activity Timepoint
* Select your new Activity from the DropDown
  * ![alt text](testing_docs_images/selectAct.png "Select Activity")
  * Your screen will refresh to the Activity Timeline
* Change the Mode to Queries
  * ![alt text](testing_docs_images/selectActOpt.png "Select ActivityOperations")
  * Select Search
  * This screen can find data queries that return useful information, You can search by query name or even by returned columns.
  * We will search for Name Matching `SeriesByMatchingImportEventInfo`
  * Click Search
  * Once the query returns Click the Foreground button
  * ![alt text](testing_docs_images/search.png "Search Query")
  * Click query
  * Select CreateTimepointFromSeriesList
    * input the parameters including the ID of your Activity
    * wait for  the query to finish
  * Inbox will become Red
  * Go to Inbox
  * Select the Message
  * Select File this Message
  * Click Yes

* Change the Mode to ActivityTimeline
  * ![alt text](testing_docs_images/selectActOpt.png "Select ActivityOperations")
  * You should now see the first step of your process documented!

* Change the Mode to ActivityOperations
  * ![alt text](testing_docs_images/selectActOpt.png "Select ActivityOperations")
  * Click the `Suggest Patient Mappings For Timepoint` Button
  * ![alt text](testing_docs_images/suggestMap.png "Suggest Mappings")
  

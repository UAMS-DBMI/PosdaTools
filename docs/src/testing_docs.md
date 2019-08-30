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
  > ![alt text](testing_docs_images/Importer2.png =720x "Posda Importer New Import Screen")

* Beginning on the left side of the window, Choose a name for the import
* Click Select Directory
  * ![alt text](testing_docs_images/Importer3.png "Posda Importer Directory Selection")
* Select the DicomTestSet test data directory,
  * Data about the folder should appear in the window (Here is an example with non-DicomTestSet data, DicomTestSet has 628 files)
  * ![alt text](testing_docs_images/Importer4.png "Posda Importer Directory Info")
* Choose your Environment (Local for testing, Production for actual work, your options are handled in the config files)
* Click "Create Import Event and Begin"
* Wait for files to complete importing, since this is test data it should have 0 errors. Real datasets will sometimes have issues to investigate using the Logs.
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
* Your screen will refresh to the  Activity Timeline
* Change the Mode to Queries
* ![alt text](testing_docs_images/seectActOpt.png "Select ActivityOperations")
* Select Search
* ![alt text](testing_docs_images/searchRadio.png "Search Query")
* This screen can find data queries that return useful information, You can search by query name or even by returned columns.
* We will search for Name Matching `SeriesByMatchingImportEventsWithEventInfo`
* Click Search
* ![alt text](testing_docs_images/search.png "Search Query")
* Once the query returns Click the Foreground button
* ![alt text](testing_docs_images/foreground.png "Search Query")
* in the boxes add `%` to represent *any*
* ![alt text](testing_docs_images/percents.png "Query parameters")   
* Click query
* Wait for the query to complete
* ![alt text](testing_docs_images/results.png "Query results")  
* Click CreateActivityTimepointFromSeriesList
  * ![alt text](testing_docs_images/CreateActivityTimepointFromSeriesList.png "CreateActivityTimepointFromSeriesList")   
  * input the parameters including the ID of your Activity
  * ![alt text](testing_docs_images/parameters.png "Input parameters")   
  * Click Expand
  * Click Start Subprocess
  * ![alt text](testing_docs_images/startsub.png "Start Subprocess")   
  * wait for  the query to Begin
  * Once the screen updates to "Going to background" it is safe to close the popup
  * ![alt text](testing_docs_images/closepopup.png "Safe to Close")   
* Inbox will become Red when the process completes
* Go to Inbox
* This is your posda mail inbox, you will receive query result notifications here
* ![alt text](testing_docs_images/redinbox.png "New Message in Inbox")   
* Select the Message to view it
* ![alt text](testing_docs_images/viewmail.png "View Message in Inbox")  
* These are the results of the query you ran. In order to access them later in the Activity screen we will File the message.
* Select `File this Message`
* ![alt text](testing_docs_images/filemessage.png "File Message in Inbox")  
* Click Yes

## View the Activity Timeline
* Click Activity on the left menu
  * ![alt text](testing_docs_images/Activity.png "Activity")
* Change the Mode to ActivityTimeline
  * ![alt text](testing_docs_images/seectActOpt.png "Select Activity Timeline")
* You should now see the first step of your process documented!
  * ![alt text](testing_docs_images/firsttimeline.png "See first timeline entry")
* Notice that you can see the current filecount of 628.
* If you click email, you can see the message we filed earlier. From there you can click the link to download a Timepoint Creation Report.
  * ![alt text](testing_docs_images/email1.png "View Email")

## Patient Mapping
* Change the Mode to ActivityOperations
  * ![alt text](testing_docs_images/seectActOpt.png "Select ActivityOperations")
* Note: The buttons on this page become blue the more they are used. This way you can visually note which actions are taken most often by your team.
* Click the `Suggest Patient Mappings For Timepoint` Button
  * ![alt text](testing_docs_images/suggestMap.png "Suggest Mappings")
* The parameter entry box for this operation appears
* ![alt text](testing_docs_images/sugMapOp1.png "Suggest Mappings Inputs")
* This operations will create a spreadsheet that we will load in to use for the following operations
* `col_name` is the name of a customized Column in the spreadheet. We will call it `NewCollection1`
* `crc` is the *collection root code* a 4 digit, unique code. It cannot have leading 0s. We will use `1001` in this example.
* `site_name` is your site name.
* `src` is the unique code 3 digit code for the site. You should choose the unique code for your site, if you do not have one yet use `999` for this example.
* `date_spec` is how you will shift dates to hide phi. You can either enter a shift amount or a baseline date. For this example we will use a baseline date of `1960-01-01`
* `pat_map_pat` is the patient mapping pattern for how the patients will be renamed. For this example we will use `Pat_<seq>`
* `num_dig` is the number of digits to be used in the sequence we specified above. For this example we will use `3`
* ![alt text](testing_docs_images/sugMapOp2.png "Suggest Mappings Inputs")
* Once all your input fields are correctly populated click Expand.
* Your popup should refresh to show the command parameters you entered
* Click Start Subprocess
* ![alt text](testing_docs_images/startsub2.png "Start Subprocess")
* Once the screen updates to "Going to background" it is safe to close the popup
* ![alt text](testing_docs_images/close2.png "Close Popup")
* When complete the Inbox will turn Red
* Click Inbox, then click the message id to view the message
* ![alt text](testing_docs_images/inbox2.png "Inbox")
* These are the results of the query you ran. In order to access them later in the Activity screen we will File the message.
* Select `File this Message`
* ![alt text](testing_docs_images/file2.png "File Message in Inbox")  
* Click Yes
* Click Activity on the left menu
* ![alt text](testing_docs_images/Activity.png "Activity")
* Change Mode to Activity Timeline
* ![alt text](testing_docs_images/seectActOpt.png "Select ActivityOperations")
* You should now see 2 entries in the Activity Timeline
* ![alt text](testing_docs_images/time2.png "Timeline")
* Some steps will have updating status text
* ![alt text](testing_docs_images/upstat.png "Status")
* When this status is Done, we can move on
* Click email in the SuggestPatientMappings timeline record
* ![alt text](testing_docs_images/mail2.png "email")
* In the popup you will see the message we filed.
* Click on the hyperlink to download the spreadsheet we created with the previous suggest patient mapping subprocess
* ![alt text](testing_docs_images/download.png "Mapping")
* Save the file when prompted
* ![alt text](testing_docs_images/download2.png "Download")
* Navigate to the file on your machine. (default locations are often Documents or Downloads)
* Open the file with your preferred spreadsheet editor (Excel/Number/etc)
* ![alt text](testing_docs_images/mapsheet.png "Mapping Suggestions")
* Now we can edit the file and upload it to use for further operations
* Any rows with an Operation specified will run that operation for that data
* In this case the suggested mappings process has found one patient that should have the UpdateOrCreatePatientMapping operation performed
* Go ahead and edit the comment column with a new comment `Test Curation Comment`
* ![alt text](testing_docs_images/comment.png "Make a comment")
* Save the file and close it, make sure you leave the file extension as .csv
* In the Posda DBIF window select Upload
* ![alt text](testing_docs_images/upload.png "Upload")
* Drag your saved file into the box, or click on the box to bring up a file selection window and choose your file.
* ![alt text](testing_docs_images/upload2.png "Upload")
* The screen will display the upload progress of the file. When it is complete it should look like in the image below.
* ![alt text](testing_docs_images/upload3.png "Upload")
* Click Tables on the left menu.
* ![alt text](testing_docs_images/tables1.png "Tables")
* Here you can see the file you have uploaded.
* Click `Perform Operations`
* ![alt text](testing_docs_images/perfop.png "Perform Operations")
* The application has read in the spreadsheet you uploaded and determined that the operations displayed here have been requested, with the specified input
* ![alt text](testing_docs_images/perform.png "Perform Operations")
* If everything looks right, Click `Execute Planned Operations` to begin the operation
* ![alt text](testing_docs_images/perform2.png "Perform Operations")
* Wait for the operation to complete
* When it completes the Inbox will highlight red with a new Message
* View and file your message as you have done before (Inbox, Message Id, File This Message, Yes)
* Then return to the Activity Timeline (Activity on the left, Mode:ShowActivityTimeline)
* You should see that the timeline now shows the UpdateOrCreatePatientMapping step that you just completed and filed.
* You've now completed the Patient Mappings step!
* The next steps of curation will proceed in a similar fashion.
  * You will run a process
  * File the result message
  * Download the spreadsheet from the filed message
  * Edit the spreadsheet and save it
  * Upload the edited sheet
  * Run the operations from the spreadsheet
  * File the completion Message
    * You may then need to View or Edit the resulting reports or spreadsheet
    * Or perform other steps needed in the message (some steps involve Accepting or Reject results)

## Initial Anonymization
* On the Activity Operations page, Click `Produce Initial Anonymizer for Timepoint`
* ![alt text](testing_docs_images/anon.png "Produce Initial Anonymizer for Timepoint")
* Enter the collection and site
* Click Expand
* ![alt text](testing_docs_images/anon2.png "Produce Initial Anonymizer for Timepoint Inputs")
* Click `Start Subprocess`
* Once the process is in the background, close the window
* View the results in the Inbox
* File the Message
* Return to the Activity Timeline
* Click email
* ![alt text](testing_docs_images/time4.png "Timeline")
* Click the link to download the `EditsForInitialAnonymization` spreadsheet
* ![alt text](testing_docs_images/download4.png "Download")
* Save and Open the file
* ![alt text](testing_docs_images/file3.png "File")
* For this example we will not make any edits. Close the file.
* Click upload
* Drag the file into the upload box. (Or click the box to open the file selection window)
* Click Tables
* ![alt text](testing_docs_images/perform3.png "Perform Operations")
* If everything looks right, Click `Execute Planned Operations` to begin the operation
* Wait for the operation to Begin
* Return to the Activity Timeline while you wait (Activity on the left, Mode:ShowActivityTimeline)
* Notice the in-progress step is updating its status
* ![alt text](testing_docs_images/bgedits.png "Status Updating")
* When it completes the Inbox will highlight red with a new Message
* View and file your message as you have done before (Inbox, Message Id, File This Message, Yes)
* Then return to the Activity Timeline (Activity on the left, Mode:ShowActivityTimeline)
* You should see that the timeline now shows the InitalAnonimizerCommandsTp and BackgroundEditTp steps that you have completed
* Click email next in the BackgroundEditTp
* View the `EditDifferences` report.
* You can view the Edits that are staged in this report.
* ![alt text](testing_docs_images/Edits.png "Edits")
* If these Edits look correct click `Accept Edits, Import and Delete Temporary Files`.
* (If things are ever missing or incorrect you can instead Reject the changes and rerun the proceeding steps)
* ![alt text](testing_docs_images/accept.png "Accept")
* The input is already filled in, Click Expand
* Click Start Subprocess
* You can close the popup once it says `Entering Background`
* When it completes the Inbox will highlight red with a new Message
* View and file your message as you have done before (Inbox, Message Id, File This Message, Yes)
* Now we have mostly completed the initial anonimizer step, but the changes made in this process could have changed the series and timepoint associations
* So we must recreate the Activity Timepoint by rerunning CreateActivityTimepointFromSeriesList
* Return to the Activity screen, Change the Mode to Query
* This will likely open to the query you last used (If not look at the CreateActivityTimepointFromSeriesList above)
* Click Back, and then Query to rerun the same query we ran previously
* The results should be updated with your changes
* Click CreateActivityTimepointFromSeriesList
  * ![alt text](testing_docs_images/CreateActivityTimepointFromSeriesList.png "CreateActivityTimepointFromSeriesList")   
  * input the ID of your Activity (Make sure to use the Activity ID we have used up to this point)
  * input a comment `After Initial Anonymization`
  * Click Expand
  * Click Start Subprocess
  * Wait for the query to Begin
  * Once the screen updates to "Going to background" it is safe to close the popup
* Inbox will become Red when the process completes
* View the results in the Inbox
* File the Message
* Return to the Activity Timeline
* Notice since this record is a timepoint edit, we get a new count of the files!
* ![alt text](testing_docs_images/time5.png "Timeline")   


## Visual Review
* Go to the Activity Operations Page (Activity on the left, Mode:ActivityOperations)
* Click Schedule Visual Review
* ![alt text](testing_docs_images/schedVR.png "Schedule VR")   
* Click Expand
* Click Start SubProcess
* Go to the Inbox
* File the message
* Return to the Activity screen
* The status of the Visual Review Processing should be updating
* ![alt text](testing_docs_images/VRstat1.png "VR Processing")  
* Wait for all of the files to be ReadyToReview
* ![alt text](testing_docs_images/ready.png "VR Processing")  
* Go to the Activity Queries Page (Activity on the left, Mode:Queries)
* If viewing a query hit Back
* Click the Search radiobutton if it is not already highlighted
* ![alt text](testing_docs_images/search.png "Search Query")
* Search by name for `VisualReviewScanInstances`
* Run the query in the foreground (Foreground, then query)
* The results should include a Details button, click it
* ![alt text](testing_docs_images/DETAILS.png "Details")
* This will let you run the `VisualReviewStatusById` query, using the previous results as input.
* Click query
* Here are the results
* ![alt text](testing_docs_images/vrstatbyid.png "Details")
* We have in our data set 2 different Dicom File Types. There are 3 series of CTs and 3 series of Secondary Captures.
* These have been divided into 4 and 3 Image Equivalency Classes respectively. IECs are a subset of a series intended to separate out scouts and other set of images in different planes.
* Click Review on the CT row to launch the Visual Review tool, Kaleidoscope
* ![alt text](testing_docs_images/rev.png "Review")
* ![alt text](testing_docs_images/kaliedoscope.png "Kaleidoscope")
* This is Kaleidoscope
* In the screenshot above, you can see that IEC 1 has 44 images, of Patient 007, examining the kidney
* The 3 images are compilations of frames different levels, which allow you to search for PHI across many frames at once
* To see the whole IEC, one frame at a time, Click `Open in Quince` at the IEC level
* This opens the lightweight Quince Dicom Viewer
* ![alt text](testing_docs_images/quince.png "Quince")
* You can play the frames as a video, scroll manually, adjust the window and level manually or with presets, and more
* Anytime Kaleidoscope does not provide enough info to check for PHI launch Quince to review further
* Close Quince
* As you can see there is another Launch Quince Button, this one is for the whole Series rather than just the current IECs
* If your image has no visible PHI, click Good
* ![alt text](testing_docs_images/quince.png "Quince")
* It will automatically move you to the next IEC
* Review these IECs, then close Kaleidoscope
* Next Review the Secondary Captures as you did CTs, Some of the Secondary Capture Images will be labeled Bad
* Since this is a test set all of this PHI is phony, but in real settings this will be real PHI
* When finished reviewing, hit Back and rerun the `VisualReviewStatusById` query
* Notice the review statuses have updated!
* ![alt text](testing_docs_images/vrreviewed.png "Reviewed")
* On the row that is marked Bad, click Details
* This will run `VisualReviewStatusDetails` with the parameters filled for the rows
* Click query
* Now you can see the details of the "Bad" IECs
* ![alt text](testing_docs_images/bads.png "Bad Details")
* There are 3 series with over 400 total files
* Next we will Hide these files
* Click `HideEquivalenceClasses`
* ![alt text](testing_docs_images/hide.png "Hide")
* Click Expand
* Click Start Subprocess
* Go to the Inbox
* File the message
* Go to the Activity Operations screen
* In order to properly record our changes, we must Update the Timepoint
* Click `UpdateActivityTimepoint`
* ![alt text](testing_docs_images/update.png "Update Timepoint")
* Add the comment `After Hide` to record the reason for the update
* Click Expand
* Click Start Subprocess
* Once the popup says "Going to background to create timepoint," you may close the popup
* Once it is completed, this may take some time on real datasets, view the Inbox
* File the message

## PHI Review
* This step is similar to the Initial Anonymizer
* Click `Schedule PHI Scan` in the Activity Operations screen
* Follow the steps as normal
* Take the resulting spreadsheet and check for PHI hidden in the DICOM tags
* If you find any PHI fill in the Operation column and put the replacement data in the correct columns
* Then Upload the spreadsheet
* Go to Tables and execute the Operations
* Check your results when it completes
* If the number of changes are different than you expected, Reject the changes and try again

## Apply Dispositions
* Run this like you have the previous Operations

## Continue Curation
* Run other steps as necessary such as checking for duplicate SOPs
* Some steps like `Public Phi Scan Based on Current TP by Activity` cannot be preformed in test databases because they require an NBIA connection to compare data against

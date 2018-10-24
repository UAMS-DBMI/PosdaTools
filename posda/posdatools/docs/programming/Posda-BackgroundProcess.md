# Posda::BackgroundProcess
This is the programmer documentation for Posda::BackgroundProcess. It is 
mostly an overview of methods with an example of expected usage.


## General usage

This object is constructed in such a way to minimize the amount of code
that is necessary in any Background Process script which utilizes it.

Note that the object makes a number of assumptions about your enviornment; 
specifically that it will be instantiated in a script which is executed
directly, and which will take a number of command line arguments.

BackgroundProcess reads @ARGV in order to add all passed command line arguments
to the database. You must still manually extract the invocation\_id, and the
notify email address and pass them into the constructor (as BackgroundProcess
makes no assumptions about the order of arguments, it cannot do this
automatically).

Example script:

``` perl
use Posda::BackgroundProcess;

my ($invoc_id, $notify_email, $some_other_arg) = @ARGV;

my $background = Posda::BackgroundProcess->new($invocation_id, $notify_email);

# read input lines, and log them as you go
$background->LogInputLine($line);

# Fork and exit
$background->Daemonize();

# It is an error to call WriteToEmail() before Daemonize()!
$background->WriteToEmail("We loaded some things!");

# It is an error to call CreateReport() before Daemonize()!
my $main_report = $background->CreateReport();

$main_report->print("Report something here");

# do whatever the script is going to do

say STDERR "STDERR is still open, so you can report errors directly";

# After calling finish, reports can no longer be written to
$background->Finish();

```

## Dependencies

* Modern::Perl;
* Method::Signatures::Simple;
* FileHandle;
* File::Temp
* DateTime;
* Posda::DB
* Posda::DownloadableFile;

## Methods
Here is a list of public methods, with brief descriptions.

### LogInputLine($line)
Log a line of input to the database. This should be called for each
input line that is read from STDIN. Note that Posda::BackgroundProcess
automatically keeps track of the number of lines that are recorded.

### Daemonize()
This method has an alias of `ForkAndExit()`. It takes no parameters, and
returns nothing. It causes the script to fork and exit, leaving a detached 
child running.

When called, a number of things happen:

* All open file handles are closed.
* All database handles are closed.
* The grandchild pid is recorded into `$self->{grandchild_pid}`.
* The Email report is opened. 
* The name of the process and the start time are automatically
writen to the Email report. 
* The count of input lines is recorded in the database.

These queries are opened for later use:

* AddErrorToBackgroundProcess
* AddBackgroundTimeAndRowsToBackgroundProcess
* AddCompletionTimeToBackgroundProcess

### CreateReport($report\_name)
Creates a new report with the given name (or 'Default Report' if no name
is given) and returns a file handle for that report.

You may call this method as many times as you like, as long as you give
each report a different name. Calling it with no parameter counts as calling
it with 'Default Report', and can only be done once.

The file handle is a normal file handle; you may write to it any way you
want, but you should not close it. It will be automatically closed when
`Finalize()` is called.

### WriteToEmail($line)
Write the given line to the email report. 


### Finish()
This methid should be called at the end of the subprocess script. It
does the following:

* Writes completion time to email, and logs to database.
* Closes all reports.
* Inserts reports into Posda.
* Creates entries in background\_subprocess\_report table.
* Generates downloadable file links.
* Writes links into Email.
* Closes Email report, and sends it.

### LogError($error)
Log an error state to the database. Only one error "message" can be
recorded for a script invocation, so this should be a message explaining
why the script failed.

### GetBackgroundID()
A convenience method that returns the background\_id of this object.

## Deprecated Methods
There are a number of methods that have been kept to allow for backward 
compatibility. They are listed here, along with the recommended replacement.

### WriteToReport($line)
This method still functions as before, but you should use `CreateReport()`
and write to the returned file handle instead.

### LogCompletionTime()
Use `Finish()` instead.

### LogInputCount($count)
No longer needs to be called, and is a no-op.

### GetReportFileID()
No longer needs to be called. Always returns 0, which will be an unexpected
value, but should not cause major issues.

### GetReportDownloadableURL()
No longer needs to be called. Returns the value "DEPRECATED".


from .fork import daemonize as real_daemonize
from .email import send_email
from ..main import insert_file
from ..main.downloadablefile import make_csv
from ..queries import Query
from ..util import printe

import sys
import os
from io import StringIO
import tempfile
from datetime import datetime

class MissingActivityIdError(KeyError): pass

class BackgroundProcess:
    """Represents a background process

    Contains methods for beginning and ending a background process,
    as well as preparing reports and email.
    """

    def __init__(self, invoc_id, notify_address, activity_id=None):
        self.invoc_id = invoc_id
        self.notify_address = notify_address
        self.activity_id = activity_id
        self.reports = {}

        self.parent_pid = None
        self.child_pid = None
        self.input_line_query = None
        self.input_line_count = 0

        for row in Query("CreateBackgroundSubprocess").run(
                subprocess_invocation_id=invoc_id,
                command_executed=sys.argv[0],
                foreground_pid=os.getpid(),
                user_to_notify=notify_address):
            self.background_id = row.background_subprocess_id

        if activity_id is not None:
            Query('InsertActivityTaskStatus').execute(activity_id, invoc_id)


        self._log_args()

        self.email = StringIO()
        self.start_time = datetime.now()
        self.print_to_email("Background process",
                            os.path.basename(sys.argv[0]),
                            "begun at", self.start_time)

    def _log_args(self):
        """Log all arguments passed to this program in the database"""
        #TODO: this v
        q = Query("CreateBackgroundSubprocessParam")
        for i, arg in enumerate(sys.argv[1:]):
            q.execute(self.background_id, i, arg)

    def daemonize(self):
        """For when good things just need to turn bad"""
        (self.parent_pid, self.child_pid) = real_daemonize()


        # turn email into a real report
        email_report = self.create_report('Email')
        print(self.email.getvalue(), file=email_report)
        self.email = email_report


        # redirect stdout to email
        self.real_stdout = sys.stdout
        sys.stdout = self.email
        self.log_input_count(self.input_line_count)

        return (self.parent_pid, self.child_pid)

    def log_input_count(self, count):
        """Update the database with the total input count and pid"""
        Query("AddBackgroundTimeAndRowsToBackgroundProcess").execute(
            input_rows=count,
            background_pid=os.getpid(),
            background_subprocess_id=self.background_id
        )

    def log_input(self, line):
        """Write a line of input to the database"""
        if self.input_line_query is None:
            self.input_line_query = Query("CreateBackgroundInputLine")
            self.input_line_count = 0

        self.input_line_query.execute(
            background_subprocess_id=self.background_id,
            param_index=self.input_line_count,
            param_value=line
        )
        self.input_line_count += 1

    def print_to_email(self, *args, **kwargs):
        """Print a message to the email file handle

        After daemonize() has been called, sys.stdout is replaced with the
        email file handle so this method is then a duplicate of print()
        """
        print(file=self.email, *args, **kwargs)

    def create_report(self, name="Default Report"):
        """Start a new (named) report, and return a file-like object for it"""
        if name in self.reports:
            raise ValueError("Report with this name already exists!")
        if self.child_pid is None or self.parent_pid is None:
            raise RuntimeError("Cannot create report until after daemonize!")

        self.reports[name] = tempfile.NamedTemporaryFile(mode="w", delete=False)
        return self.reports[name]


    def _finish_activity_task_status(self, final_status_message: str=None) -> None:
        if self.activity_id is None:
            return

        query = "FinishActivityTaskStatus"
        if final_status_message == "Schedule Complete - Manual Process Follows":
            query = "UpdateActivityTaskStatusForManualUpdate"

        if final_status_message is None:
            final_status_message = "Complete - no status specified"

        Query(query).execute(
            final_status_message,
            self.activity_id,
            self.invoc_id
        )


    def finish(self, final_status_message: str=None) -> None:
        """Indicate that the BackgroundProcess has finished.

        Log the completion time to the database, close all
        reports, load them into Posda and print the API URL to the email,
        then send the email. Update Activity Task Status if we were
        created with an activity_id.
        """
        Query("AddCompletionTimeToBackgroundProcess").execute(
            background_subprocess_id=self.background_id
        )
        self.finish_time = datetime.now()
        print("Background process ended at:", self.finish_time)
        print("Total time elapsed:", self.finish_time - self.start_time)

        self._finish_activity_task_status(final_status_message)

        for report_name, report in self.reports.items():
            # skip the email for now, because if we close it we can't write
            # any further lines
            if report_name == 'Email':
                continue
            report.close()
            file_id = insert_file(report.name)
            os.unlink(report.name)
            url = make_csv(file_id)
            Query('CreateBackgroundReport').execute(
                background_subprocess_id=self.background_id,
                file_id=file_id,
                name=report_name
            )
            print(f"Report '{report_name}': {url}")

        # close email last
        self.email.close()
        email_file_id = insert_file(self.email.name)
        os.unlink(self.email.name)

        for report_id, in Query('CreateBackgroundReport').run(
            background_subprocess_id=self.background_id,
            file_id=email_file_id,
            name='Email'
        ):
            send_email('nobody', self.notify_address, report_id, 'posda.background.process')
        # TODO: make this 'send email' via posda
        # send_email(self.notify_address,
        #            "Posda job complete",
        #            self.email.getvalue())


    def set_activity_status(self, status: str, time_remaining: str=None) -> None:
        if self.activity_id is None:
            raise MissingActivityIdError("This BackgroundProcess was created "
                                         "without an activity_id, so Activity "
                                         "Status cannot be set.")

        if time_remaining is not None:
            Query("UpdateActivityTaskStatusAndCompletionTime").execute(
                status_text=status,
                expected_completion_time=time_remaining,
                activity_id=self.activity_id,
                subprocess_invocation_id=self.invoc_id
            )
        else:
            Query("UpdateActivityTaskStatus").execute(
                status_text=status,
                activity_id=self.activity_id,
                subprocess_invocation_id=self.invoc_id
            )

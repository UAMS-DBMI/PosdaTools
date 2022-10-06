from email.mime.text import MIMEText
from subprocess import Popen, PIPE
from ..database import Database

def send_email_old(address, subject, content):
    p = Popen(["/usr/sbin/sendmail", "-i", "--", address], stdin=PIPE)
    msg = MIMEText(content)
    msg['Subject'] = subject
    msg['To'] = address
    p.communicate(msg.as_bytes())

def send_email(from_username, to_username, background_subprocess_report_id, how, activity_id=None):
    with Database("posda_files").cursor() as cur:
        cur.execute("""\
            insert into user_inbox_content (
              user_inbox_id,
              background_subprocess_report_id,
              current_status,
              statuts_note,
              date_entered,
              date_dismissed
            ) values (
              (select user_inbox_id 
               from user_inbox
               where user_name = %s), %s, %s, %s, now(), null
            )
            returning user_inbox_content_id
        """, [to_username, background_subprocess_report_id, 'entered', f"created by {how}"])

        for row in cur:
            user_inbox_content_id, = row

        cur.execute("""\
            insert into user_inbox_content_operation (
              user_inbox_content_id,
              operation_type,
              when_occurred,
              how_invoked,
              invoking_user
            ) values (
              %s, %s, now(), %s, %s
            )
        """, [user_inbox_content_id, 'entered', how, from_username])

        # autofile
        if activity_id is not None:
            cur.execute("""\
                insert into activity_inbox_content(
                    activity_id, user_inbox_content_id
                ) values (
                    %s, %s
                )
            """, [activity_id, user_inbox_content_id])

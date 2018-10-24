#!/usr/bin/env python3.6

from posda.database import Database
from pprint import pprint

INVOKING_USER = 'quasarj' # TODO: should be script param!

class LookupError(Exception): pass
class InvalidEmail(LookupError): pass
class InvalidUsername(LookupError): pass

class UserFromEmail(str):
    def resolve(self, users, emails):
        val = str(self)
        if val in emails:
            return emails[val]
        else:
            raise InvalidEmail()

class UserFromUsername(str):
    def resolve(self, users, emails):
        val = str(self)
        if val in users:
            return users[val]
        else:
            raise InvalidUsername()

users = {}
emails = {}

with Database("posda_queries") as conn:
    cur = conn.cursor()
    insert_cur = conn.cursor()

    cur.execute("select * from user_inbox")
    for row in cur:
        users[row.user_name] = row.user_inbox_id
        emails[row.user_email_addr] = row.user_inbox_id

    cur.execute("""
        select user_to_notify, invoking_user, background_subprocess_report_id
        from background_subprocess_report
        natural join background_subprocess 
        natural join subprocess_invocation
        where name = 'Email'
        and background_subprocess_report_id not in (
            select background_subprocess_report_id from user_inbox_content
        )
    """)

    for row in cur:
        if row.user_to_notify is not None:
            user = UserFromEmail(row.user_to_notify)
        else:
            if row.invoking_user is not None:
                user = UserFromUsername(row.invoking_user)
            else:
                continue

        try:
            user_id = user.resolve(users, emails)
        except LookupError:
            print(f"Skipping invalid user: {user}")
            continue


        insert_cur.execute("""
            insert into user_inbox_content (
                user_inbox_id,
                background_subprocess_report_id,
                current_status,
                statuts_note,
                date_entered,
                date_dismissed
            )
            values (%s, %s, %s, %s, now(), null)
            returning user_inbox_content_id
        """, [user_id, row.background_subprocess_report_id, "entered",
              "entered from unqueued Emails in background_subprocess_report"])

        uic_id = insert_cur.fetchone().user_inbox_content_id
        conn.commit()
        print(uic_id)

        insert_cur.execute("""
            insert into user_inbox_content_operation (
                user_inbox_content_id,
                operation_type,
                when_occurred,
                how_invoked,
                invoking_user
            ) values (%s, %s, now(), %s, %s)
        """, [uic_id,
              "collected from unqueued Emails in background_subprocess_report", 
              "from script populate_user_inbox_content.py",
              INVOKING_USER])


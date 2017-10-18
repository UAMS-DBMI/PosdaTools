#!/usr/bin/env python3.6

from posda.database import Database

usernames = []
with Database("posda_auth") as conn:
    cur = conn.cursor()
    cur.execute("select * from users")
    for row in cur:
        usernames.append(row.user_name)


print("Because they are not currently recorded, I will need you to enter the "
      "email addresses for the following users:")

for user in usernames:
    print(user)

print()

emails = {}
for user in usernames:
    email = input(f"Enter the email address for '{user}', or Enter for none: ")
    if email != '':
        emails[user] = email

print(emails)
input("If the above looks good, press Enter. Press Control+C to abort. "
      "You can adjust these values later, in the user_inbox table.")

with Database("posda_queries") as conn:
    cur = conn.cursor()
    for user, email in emails.items():
        cur.execute("insert into user_inbox (user_name, user_email_addr) "
                    "values (%s, %s)", [user, email])

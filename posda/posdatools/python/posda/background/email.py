from email.mime.text import MIMEText
from subprocess import Popen, PIPE

def send_email(address, subject, content):
    p = Popen(["/usr/sbin/sendmail", "-i", "--", address], stdin=PIPE)
    msg = MIMEText(content)
    msg['Subject'] = subject
    msg['To'] = address
    p.communicate(msg.as_bytes())

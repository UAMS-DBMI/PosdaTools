select user_to_notify, invoking_user, background_subprocess_report_id
from background_subprocess_report
natural join background_subprocess 
natural join subprocess_invocation
where name = 'Email'


#from datetime import datetime
import datetime
import ujson



# d = {'study_date': datetime.date(2008, 1, 19), 'study_time': datetime.time(10, 27, 8)}
d = {'study_time': datetime.time(10, 27, 8)}

j = ujson.dumps(d)
print(j)

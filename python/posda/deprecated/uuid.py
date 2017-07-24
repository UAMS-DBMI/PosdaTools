import uuid

def get_guid():
  var = uuid.uuid4()
  return var.int  # int looks closest to what Posda::UUID::GetGuid returns

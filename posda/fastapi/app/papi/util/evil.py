from typing import NamedTuple
from pprint import pprint
from urllib.parse import quote_plus as q

class LoginFailedError(RuntimeError): pass
class LoginExpiredError(RuntimeError): pass
class SubmitFailedError(RuntimeError): pass

class File(NamedTuple):
    subprocess_invocation_id: int
    file_id: int
    collection: str
    site: str
    site_id: int
    batch: int
    filename: str
    third_party_analysis_url: str = None


    def get_curl_command(self):
        file = self
        def form(k, v):
            if v is None:
                return ""

            v = quote_plus(v)
            return f"{k}={v}"

        bits = [
            ('project', q(file.collection)),
            ('siteName', q(file.site)),
            ('siteID', q(file.site_id)),
            ('batch', q(file.batch)),
            ('uri', file.filename),
        ]

        if file.third_party_analysis_url is not None:
            bits.append(('third_party_analysis_url', file.third_party_analysis_url))

        out = "&".join([
            f"{k}={v}"
            for k, v in bits
        ])

        curl_command = (
            """curl -H "Authorization:Bearer $TOKEN" """
            """-k "https://$HOSTNAME/nbia-api/services/submitDICOM" """
            f"""-d "{out}" """
        )

        return curl_command


def evil_eval(string):
    return eval(string)

if __name__ == "__main__":
    test = """\
    ('Failed to submit the file; error details follow', File(subprocess_invocation_id='6191', file_id='45567767', collection='OPC Radiomics', site='UHN', site_id='86663098', batch='0', filename='/nas/public/storage-from-posda/cb/c7/e2/cbc7e2e57b5e8f0998718d6bdaabddb6.dcm'), [SubmitFailedError((500, b'Server was not able to process your request'),), SubmitFailedError((500, b'Server was not able to process your request'),), SubmitFailedError((500, b'Server was not able to process your request'),), SubmitFailedError((500, b'Server was not able to process your request'),), SubmitFailedError((500, b'Server was not able to process your request'),)])"""

    a = eval(test)
    msg, file, errors = a


    # pprint(file)
    print(file.get_curl_command())




#!/bin/bash

# for testing only
## ARIES
# POSDA_API_SYSTEM_TOKEN=fcda15e2-297e-4893-984c-d2667371d9f5
# TOKEN="Authorization: Bearer $POSDA_API_SYSTEM_TOKEN"
# HOST="aries-posda-a1.ad.uams.edu"

## PROD
POSDA_API_SYSTEM_TOKEN=e9a63bc2-bfa5-4299-afb3-c844fb2ef38b
TOKEN="Authorization: Bearer $POSDA_API_SYSTEM_TOKEN"
HOST="tcia-posda-rh-1.ad.uams.edu"

# ## Local
# POSDA_API_SYSTEM_TOKEN=e9a63bc2-bfa5-4299-afb3-c844fb2ef38b
# TOKEN="Authorization: Bearer $POSDA_API_SYSTEM_TOKEN"
# HOST="localhost"

function flag {
	http POST http://$HOST/papi/v1/masking/$1/mask "$TOKEN"
}
function params {
	http POST http://$HOST/papi/v1/masking/$1/parameters "$TOKEN" \
		lr=212 pa=47 s=24 i=1 d=200
}
function params_blackout {
	http POST http://$HOST/papi/v1/masking/$1/parameters "$TOKEN" \
		lr=266 pa=288 s=712 i=868 d=319 function=blackout
}

function getwork {
	http GET http://$HOST/papi/v1/masking/getwork "$TOKEN"
}
function complete {
	http POST http://$HOST/papi/v1/masking/$1/complete "$TOKEN" \
		import_event_id=1 exit_code=$2
}
function accept {
	http POST http://$HOST/papi/v1/masking/$1/accept "$TOKEN"
}
function reject {
	http POST http://$HOST/papi/v1/masking/$1/reject "$TOKEN"
}
function iecs {
	http GET http://$HOST/papi/v1/masking/visualreview/$1 "$TOKEN"
}
function files {
	http GET http://$HOST/papi/v1/iecs/$1/files "$TOKEN"
}

# echo "flagging for masking"
# flag 1
# flag 2
# flag 3

echo "setting parameters, as if user has finished selecting region in UI"
# params 1
# params 2
params_blackout 1117963

# echo "getting work, as Masking Daemon"
# getwork
# getwork
# getwork
# getwork # this one whould return nothing

# echo "marking complete, as if Masking Daemon has finished"
# complete 1 0
# complete 2 2
# complete 3 5


# echo "marking accepted/rejected"
# accept 1
# reject 2
# reject 3

# echo "get all IECs for a visual review"
# iecs 2

# echo "get all files for an iec"
# files 1

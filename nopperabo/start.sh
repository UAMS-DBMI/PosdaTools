#!/bin/bash

# Start NopperaBo with the correct settings
exec /scripts/nopperabo.py \
	--hostname $POSDA_EXTERNAL_HOSTNAME \
	--token $POSDA_API_SYSTEM_TOKEN

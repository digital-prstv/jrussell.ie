#!/bin/sh -eux

# Provide as the quesry string the name of the key to extract
# Possible keys:
#   UserId
#   Account
#   Arn
eval "$(jq -r '@sh "KEY=\(.key)"')"

# Extract the value of the requested field
VALUE=$(aws sts get-caller-identity --output=json | jq -r ".$KEY")

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg value "$VALUE" '{"value":$value}'
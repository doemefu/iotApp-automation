#!/bin/sh

echo "Waiting for InfluxDB to be ready..."
until curl -s "${INFLUX_HOST}/health" | grep -q '"status":"pass"'; do
  echo "InfluxDB is not ready yet. Retrying in 5 seconds..."
  sleep 5
done

INFLUX_TOKEN=$(cat /run/secrets/influxdb2-admin-token)


echo "InfluxDB is ready. Fetching organization ID... with token: ${INFLUX_TOKEN}"

# Fetch the list of organizations and extract the ID of the desired organization
ORG_RESPONSE=$(curl --request GET "${INFLUX_HOST}/api/v2/orgs" \
  --header "Authorization: Token ${INFLUX_TOKEN}")

echo "Organizations: $ORG_RESPONSE"

# Use grep and awk to find the organization ID
# Extract organization ID based on the organization name
ORG_ID=$(
  echo "$ORG_RESPONSE" \
  | awk -F '"' -v org_name="${DOCKER_INFLUXDB_INIT_ORG}" '
      /"id":/ {
        # The 4th field (index 3) after splitting by quotes is the actual ID string
        id = $4
      }
      /"name":/ {
        # Again, the 4th field is the name string
        name = $4
        if (name == org_name) {
          print id
          exit
        }
      }
    '
)




echo "Organization ID: $ORG_ID"

if [ -z "$ORG_ID" ]; then
  echo "Error: Organization '${DOCKER_INFLUXDB_INIT_ORG}' not found. Exiting."
  exit 1
fi

echo "Organization ID for '${DOCKER_INFLUXDB_INIT_ORG}': $ORG_ID"

# List of buckets to create
BUCKETS="auth-service user-management-service device-management-service data-processing-service"

for BUCKET in $BUCKETS; do
  echo "Checking bucket: $BUCKET"
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${INFLUX_HOST}/api/v2/buckets" \
    -H "Authorization: Token ${INFLUX_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "'$BUCKET'",
      "orgID": "'$ORG_ID'",
      "retentionRules": []
    }')

  if [ "$RESPONSE" -eq 201 ]; then
    echo "Bucket '$BUCKET' created successfully."
  elif [ "$RESPONSE" -eq 409 ]; then
    echo "Bucket '$BUCKET' already exists."
  else
    echo "Error creating bucket '$BUCKET'. HTTP status code: $RESPONSE"
  fi
done

echo "All buckets processed successfully."

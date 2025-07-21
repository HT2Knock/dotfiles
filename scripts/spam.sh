#!/bin/bash

# Number of times to run the curl command
TOTAL_RUNS=1000
# Counter for current run
COUNT=0

echo "Starting curl loop..."

while [ $COUNT -lt $TOTAL_RUNS ]; do
  # Increment counter
  ((COUNT++))

  # Calculate progress percentage
  PROGRESS=$((COUNT * 100 / TOTAL_RUNS))

  echo "Run $COUNT/$TOTAL_RUNS ($PROGRESS%)"

  # Execute the curl command
  curl -i 'https://api-modal.workgot.vn/api/board/imports' \
    -H 'Sec-GPC: 1' \
    -H 'sec-ch-ua-platform: "Linux"' \
    -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiIwMUpOMk05VjhXNFBaSjFSUUhXNURQNzdUMiIsInRlYW1JRHMiOltdLCJ3b3Jrc3BhY2VJRCI6Im5nb2MtNiIsImlhdCI6MTc0MTA4NTAxMCwiZXhwIjoxNzQxMDg4NjEwfQ.tlA7Zw8tfb84W4qfmCVb2TU8bC3zel2bqyp_MTC2_-c' \
    -H 'Referer: https://modal.workgot.vn/' \
    -H 'sec-ch-ua: "Not?A_Brand";v="99", "Chromium";v="130"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'DNT: 1' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw '{"boardID":"01JN2M9X8YWF9T26BRC2BQJC91","baseID":"01JN2M9X6ZDD6RSWGFAPBFB3YC","importID":"01JNGC4441EZ34ASKC4AQ1GAY9","key":"55173adb-3884-4612-ae43-9dfd3469fa70","disableFlow":false}'

  echo -e "\nCompleted run $COUNT/$TOTAL_RUNS\n"

  # Optional: Add a small delay between requests (in seconds)
  sleep 1
done

echo "All $TOTAL_RUNS requests completed!"

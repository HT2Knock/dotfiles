#!/bin/bash

MUSER="root"
MPORT="3306"
MHOST="127.0.0.1"
MYSQL="mysql"

password="$(gum input --password --prompt="Enter MySQL password: ")"

if [[ -z $password ]]; then
  echo "Password cannot be empty."
  exit 1
fi

DBS="$(MYSQL_PWD=$password $MYSQL -u $MUSER -h $MHOST -P $MPORT -Bse 'SHOW DATABASES' 2>/dev/null)"

if [[ $? -ne 0 ]]; then
  echo "Error: Unable to connect to MySQL. Check your credentials."
  exit 1
fi

PICKED=$(gum choose --no-limit --height=14 $DBS)

if [[ -z $PICKED ]]; then
  echo "No database selected."
  exit 1
fi

echo "You selected: $PICKED"
gum confirm "Are you sure you want to delete the selected database(s)?" || exit 1

for db in $PICKED; do
  echo "Deleting database: $db"
  MYSQL_PWD=$password $MYSQL -u $MUSER -h $MHOST -P $MPORT -e "DROP DATABASE \`$db\`;" 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "Successfully deleted $db"
  else
    echo "Failed to delete $db. Check your permissions."
  fi
done

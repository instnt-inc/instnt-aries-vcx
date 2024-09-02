#!/bin/bash

# Define the file path
FILE_PATH="datetime.txt"

# Get the current date and time
CURRENT_DATETIME=$(date +"%Y-%m-%d %H:%M:%S")

# Write the current date and time to the file
echo "$CURRENT_DATETIME" > $FILE_PATH

echo "Created $FILENAME with current date and time."

# Optionally, you could commit the changes to the repository
#git add $FILE_PATH
#git commit -m "Update datetime.txt with current date and time"
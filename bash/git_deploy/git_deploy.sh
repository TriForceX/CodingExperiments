#!/bin/bash

# Set variables for FTP
FTP_CMD='C:\ProgramData\chocolatey\bin\lftp.exe'
HOST='ftp.domain.com'
USER='user@domain.com'
PASS='userpassword'
ENCODED_PASS=true
SSL_VERIFY=false
REMOTE_DIR='/'
IGNORED_FILES=(".git" ".gitignore" ".gitftp" "*.log" "*.code-workspace" "node_modules" ".vs")

# Start program
echo "Starting FTP Upload to: $HOST"
echo -n "How many commits back to upload? (Press Enter for current commit): "
read COMMIT_COUNT
echo ""

# Set default if empty
if [[ -z "$COMMIT_COUNT" ]]; then
	COMMIT_COUNT=1
fi

# Decode password if it's encoded
if [ "$ENCODED_PASS" = true ]; then
	PASS=$(echo "$PASS" | base64 --decode)
fi

# Determine SSL setting
if [ "$SSL_VERIFY" = true ]; then
	SSL_OPTION="set ssl:verify-certificate yes"
else
	SSL_OPTION="set ssl:verify-certificate no"
fi

# Get the list changed, and deleted files based on user input
CHANGED_FILES=$(git diff --name-only --diff-filter=ACMRT HEAD~$COMMIT_COUNT HEAD)
DELETED_FILES=$(git diff --name-only --diff-filter=D HEAD~$COMMIT_COUNT HEAD)

# Initialize counters
UPDATED_COUNT=0
DELETED_COUNT=0

# Function to check if a file is in the ignored list
is_ignored() {
	local file="$1"
	for ignore in "${IGNORED_FILES[@]}"; do
		# Check for exact match or directory match
		if [[ "$file" == "$ignore" || "$file" == "$ignore"/* ]]; then
			return 0
		fi
		# Check for wildcard patterns using 'fnmatch' with bash [[ ]]
		if [[ "$file" == $ignore ]]; then
			return 0
		fi
	done
	return 1
}

# Display the files that will be updated
HAS_UPLOADS=false
HAS_UPLOADS_NUM=1

for FILE in $CHANGED_FILES; do
	if ! is_ignored "$FILE"; then
		if [ "$HAS_UPLOADS" = false ]; then
			echo "Files to be uploaded:"
			HAS_UPLOADS=true
		fi
		echo "$HAS_UPLOADS_NUM) $FILE"
		((HAS_UPLOADS_NUM++))
	fi
done

# Display the files that will be deleted
HAS_DELETES=false
HAS_DELETES_NUM=1

for FILE in $DELETED_FILES; do
	if ! is_ignored "$FILE"; then
		if [ "$HAS_DELETES" = false ]; then
			if [ "$HAS_UPLOADS" = true ]; then
				echo ""
			fi
			echo -e "Files to be deleted:"
			HAS_DELETES=true
		fi
		echo "$HAS_DELETES_NUM) $FILE"
		((HAS_DELETES_NUM++))
	fi
done

# Display note for not uploaded or delete
if [ "$HAS_UPLOADS" = false ] && [ "$HAS_DELETES" = false ]; then
	echo "No files to upload or delete."
fi

# Prompt user for confirmation
echo -e "\nPress Enter to continue or Ctrl + C to cancel..."
read

# Upload changed files to FTP
LFTP_UPLOAD_CMDS="$SSL_OPTION; open $HOST; user $USER $PASS"

for FILE in $CHANGED_FILES; do
	# Skip ignored files
	if is_ignored "$FILE"; then
		echo "Skipping: $FILE"
		continue
	fi

	# Make sure the file exists before uploading
	if [ -f "$FILE" ]; then
		echo "Uploading: $FILE"

		# Get remote directory path
		REMOTE_PATH=$(dirname "$FILE")

		# Update lftp to upload the changed file to the FTP server
		LFTP_UPLOAD_CMDS="$LFTP_UPLOAD_CMDS; $( [ "$REMOTE_PATH" != "." ] && echo "cls -d $REMOTE_DIR$REMOTE_PATH || mkdir -p $REMOTE_DIR$REMOTE_PATH" ); put $FILE -o $REMOTE_DIR$FILE"

		((UPDATED_COUNT++))
	fi
done

LFTP_UPLOAD_CMDS="$LFTP_UPLOAD_CMDS; bye"
$FTP_CMD -e "$LFTP_UPLOAD_CMDS" -u $USER,$PASS

# Delete removed files from FTP
LFTP_DELETE_CMDS="$SSL_OPTION; open $HOST; user $USER $PASS"

for FILE in $DELETED_FILES; do
	if is_ignored "$FILE"; then
		echo "Skipping deletion: $FILE"
		continue
	fi

	echo "Deleting: $FILE"

	# Get remote directory path
	REMOTE_PATH=$(dirname "$FILE")

	# Remove directory paths
	CLEAN_CMDS=""
	if [ "$REMOTE_PATH" != "." ]; then
		CURRENT_PATH="$REMOTE_PATH"
		while [ "$CURRENT_PATH" != "." ]; do
			CLEAN_CMDS="$CLEAN_CMDS rmdir $REMOTE_DIR$CURRENT_PATH;"
			CURRENT_PATH=$(dirname "$CURRENT_PATH")
		done
	fi

	# Update lftp to delete the changed file to the FTP server
	LFTP_DELETE_CMDS="$LFTP_DELETE_CMDS; rm $REMOTE_DIR$FILE; $CLEAN_CMDS"

	((DELETED_COUNT++))
done

LFTP_DELETE_CMDS="$LFTP_DELETE_CMDS; bye"
$FTP_CMD -e "$LFTP_DELETE_CMDS" -u $USER,$PASS

# Display total counts and finish program
echo -e "\nSuccessfully Updated: $UPDATED_COUNT Files, Deleted: $DELETED_COUNT Files."
echo "Press Enter to exit..."
read
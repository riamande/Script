#! /bin/sh

# This script extracts various data from databases and send them into a server.
# This is meant to be run every day at a consistent time. Preferably 1AM.

# What this script does:
# 1. create a folder where everything will be sent
# 2. extract various data from MySQL, Mongo and Log and store it into the folder
# 3. send the folder to a server via rsync
# 4. clean up and delete the folder

# Required env var:
# -----------------
ANGKASA_SSH_USERNAME="zeppelin"
ANGKASA_SSH_HOST="103.29.149.165"
ANGKASA_SSH_PRIV_PATH="/home/rully/.ssh/rully88"

# variables
DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "-1 day" +'%Y/%m/%d') +"%s") # get 1 day ago
PM_DATE_START=`date -d@$DATE_START +"%Y-%m-%d %T"`
PM_DATE_END=`date -d@$DATE_END +"%Y-%m-%d %T"`
OUTPUT_FOLDER="$DATE_END_STR"
DATE_RM_STR=$(env TZ=Asia/Jakarta date -d "-1 day" +'%Y%m%d')
FOLDER_RM="$DATE_RM_STR"
PARENT_FOLDER="/home/rully/bigdata"

echo "Moving data for period [$DATE_START,$DATE_END) into folder $OUTPUT_FOLDER"

# create directory for the extracted data
#mkdir -p $OUTPUT_FOLDER

# send the data
echo "sending data to angkasa"
for i in 1 2 3 4 5 6 7 8 9 10
do
    rsync -azP "$PARENT_FOLDER/$OUTPUT_FOLDER" -e "ssh -i $ANGKASA_SSH_PRIV_PATH" "$ANGKASA_SSH_USERNAME@$ANGKASA_SSH_HOST:/home/zeppelin/files/etl/kaskus/raw"
    if [ "$?" = "0" ] ; then
        echo "rsync completed normally"
        break
    else
        echo "Rsync failure. Backing off and retrying... attempt $i of 10"
        sleep 10
    fi
done

# clean up
echo "Cleaning up: Deleting $OUTPUT_FOLDER"
rm -rf "$PARENT_FOLDER/$FOLDER_RM"

echo "Done."

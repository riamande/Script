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
MYSQL_USERNAME="percona"
MYSQL_PASSWORD="kaskus2014"
MYSQL_HOST="172.20.0.73"
MYSQL_HOST1="172.20.0.77"
MYSQL_HOST2="172.20.0.253"
# MYSQL_PORT=3306
# MONGO_USERNAME=root
# MONGO_PASSWORD=root
# MONGO_HOST=localhost
# MONGO_PORT=27017
ANGKASA_SSH_USERNAME="zeppelin"
ANGKASA_SSH_HOST="103.29.149.165"
ANGKASA_SSH_PRIV_PATH="/home/rully/.ssh/rully88"

# variables
DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "20171116" +'%Y/%m/%d') +"%s") # get 1 day ago
OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
PM_DATE_START=`date -d@$DATE_START +"%Y-%m-%d %T"`
PM_DATE_END=`date -d@$DATE_END +"%Y-%m-%d %T"`
OUTPUT_FOLDER="$DATE_END_STR"
MONGO_HOST_LIST="/home/rully/hostlist.txt"
PARENT_FOLDER="/home/rully/temp_bigdata"

echo "Moving data for period [$DATE_START,$DATE_END) into folder $OUTPUT_FOLDER"

# create directory for the extracted data
mkdir -p $PARENT_FOLDER/$OUTPUT_FOLDER

# extracting data
## MySQL
### userinfo
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/userinfo.csv"
echo "Exporting mysql > user > userinfo into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select userid,usergroupid,gender,country,province,joindate,YEAR(dateofbirth) yearofbirth,profilepicrevision,profilevisits from userinfo ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### userlogin       
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/userlogin.csv"       
echo "Exporting mysql > user > userlogin into $OUTPUT_FILE"       
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select userid,username,lastlogin,lastlogout from userlogin where lastlogin >= $DATE_START and lastlogin < $DATE_END ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE


## Mongo
### thread
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/thread.json"
echo "Exporting mongo > thread into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
for i in `cat $MONGO_HOST_LIST`
do
/opt/mongodb_3.0.10/bin/mongoexport -h $i:27018 -urootdbsharding -pRootDBShardingKK2017 --authenticationDatabase=admin -d kaskus_forum -c thread --out temp_thread.json -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"
cat temp_thread.json >> $OUTPUT_FILE
done

### post
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/post.json"
echo "Exporting mongo > post into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
for i in `cat $MONGO_HOST_LIST`
do
/opt/mongodb_3.0.10/bin/mongoexport -h $i:27018 -urootdbsharding -pRootDBShardingKK2017 --authenticationDatabase=admin -d kaskus_forum -c post --out temp_post.json -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"
cat temp_post.json >> $OUTPUT_FILE
done
#  "{ \"$or\": [{\"dateline\":{\"$gte\":$DATE_START, \"$lt\":$DATE_END }}, {\"last_editor_dateline\":{\"$gte\":$DATE_START, \"$lt\":$DATE_END }}]}"  #can't provide edited post yet

### userloginlog
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/userloginlog.json"
echo "Exporting mongo > userloginlog into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mongoexport -h 172.20.0.90 -d kaskus_user_log -c userloginlog --out $OUTPUT_FILE -q \
  "{datetime:{\$gte:'$PM_DATE_START', \$lt:'$PM_DATE_END' }}"

### subscribethread
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/subscribethread.json"
echo "Exporting mongo > subscribethread into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mongoexport -h 172.20.0.242 -d kaskus_forum1 -c subscribethread --out $OUTPUT_FILE -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"

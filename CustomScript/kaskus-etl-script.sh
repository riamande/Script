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
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "-1 day" +'%Y/%m/%d') +"%s") # get 1 day ago
OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
PM_DATE_START=`date -d@$DATE_START +"%Y-%m-%d %T"`
PM_DATE_END=`date -d@$DATE_END +"%Y-%m-%d %T"`
OUTPUT_FOLDER="$DATE_END_STR"
DATE_ON_FILE=`date -d "$DATE_END_STR - 1 day" +%Y-%m-%d`
MONGO_HOST_LIST="/home/rully/hostlist.txt"
PARENT_FOLDER="/home/rully/bigdata"
FEED_FOLDER="/home/rully/temp_bigdata"

echo "Moving data for period [$DATE_START,$DATE_END) into folder $OUTPUT_FOLDER"

# create directory for the extracted data
mkdir -p $PARENT_FOLDER/$OUTPUT_FOLDER

# remove file on temp_bigdata
rm $FEED_FOLDER/mysql/*
rm $FEED_FOLDER/mongo/*

# extracting data
## MySQL
### userinfo
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/userinfo.csv"
echo "Exporting mysql > user > userinfo into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select userid,usergroupid,gender,country,province,joindate,dateofbirth,profilepicrevision,profilevisits,ip_address,biography from userinfo ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### userinfo filtered
OUTPUT_FILE="$FEED_FOLDER/mysql/"$DATE_ON_FILE"_userinfo.csv"
echo "Exporting mysql > user > userinfo into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select userid,usergroupid,gender,country,province,joindate,YEAR(dateofbirth) yearofbirth,profilepicrevision,profilevisits from userinfo ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE
gzip $OUTPUT_FILE

### vsl_info
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/kaskus_fjb/vsl_info.csv"
echo "Exporting mysql > kaskus_fjb > vsl_info into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST1 kaskus_fjb -e \
  "select userid,username,province,city,kecamatan,zipcode,dateofbirth,is_active,status,notes,submitted_date,expired_date,updated_date,updated_by,is_registered from vsl_info ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### transaction
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/kaskus_fjb/transaction.csv"
echo "Exporting mysql > kaskus_fjb > transaction into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST1 kaskus_fjb -e \
  "select id,transaction_id,offer_id,price,unique_price_code,quantity,shipping_cost,kaskus_fee,total,reference_id,bank_type,bank_fee,thread_id,thread_title,category_id,seller_id,buyer_id,product_image_path,case_type,case_summary,case_image_path,case_status,case_open_date,case_closed_date,action_status,admin_notes,admin_id,admin_name,action_notes_type,action_notes,transaction_status,submited_date,payment_date,updated_date,shipping_status,shipping_date,has_feedback,insurance_status,insurance_price,shipping_agent_id,shipping_agent_name from transaction where ($DATE_START <= updated_date) AND (updated_date < $DATE_END) ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### transaksi
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/kaskus_donatur/transaksi.csv"
echo "Exporting mysql > kaskus_donatur > transaksi into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST2 kaskus_donatur -e \
  "select inttid,trxid,packetid,userid,trxdate,amount,status,dateline,response,payment_method from transaksi where ($DATE_START <= dateline) AND (dateline < $DATE_END) ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### fbuser
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/fbuser.csv"
echo "Exporting mysql > user > fbuser into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select * from fbuser ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### twitteruser  
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/twitteruser.csv"  
echo "Exporting mysql > user > twitteruser into $OUTPUT_FILE"  
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select * from twitteruser ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### gpuser  
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/gpuser.csv"  
echo "Exporting mysql > user > gpuser into $OUTPUT_FILE"  
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select * from gpuser ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE

### userlogin       
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/user/userlogin.csv"       
OUTPUT_COPY="$FEED_FOLDER/mysql/"$DATE_ON_FILE"_userlogin.csv"
echo "Exporting mysql > user > userlogin into $OUTPUT_FILE"       
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST user -e \
  "select userid,username,lastlogin,lastlogout from userlogin where lastlogin >= $DATE_START and lastlogin < $DATE_END ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE
cp $OUTPUT_FILE $OUTPUT_COPY
gzip $OUTPUT_COPY

### forum_list
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/forum/forum_list.csv" 
OUTPUT_COPY="$FEED_FOLDER/mysql/"$DATE_ON_FILE"_forum_list.csv"
echo "Exporting mysql > forum > forum_list into $OUTPUT_FILE" 
mkdir -p "$(dirname $OUTPUT_FILE)"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST forum -e \
  "select forum_id,name,description,display_order,thread_count,deleted_count,post_count,parent_id,parent_list,child_list,date,visible,last_thread_id,last_thread_title,last_thread_starter,last_post_id,last_post,last_poster from forum_list ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE
cp $OUTPUT_FILE $OUTPUT_COPY
gzip $OUTPUT_COPY

### pm_user_xxx
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/pm/pm_user_$i.csv"       
echo "Exporting mysql > pm > pm_user_ into $OUTPUT_FILE"             
mkdir -p "$(dirname $OUTPUT_FILE)"
PM_DATE_START=`date -d@$DATE_START +"%Y-%m-%d %T"`
PM_DATE_END=`date -d@$DATE_END +"%Y-%m-%d %T"`
i=0
while [  $i -lt 500 ]; do
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mysql/pm/pm_user_$i.csv"
mysql -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -h$MYSQL_HOST1 pm -e \
  "select pm_id,userid,sender_userid,sender_username,recipients,flag,date,type,folder_id from pm_user_$i where date >= '$PM_DATE_START' and date < '$PM_DATE_END' ;" \
| sed 's/\t/","/g' |sed 's@^@"@g' |sed 's@$@"@g' > $OUTPUT_FILE
i=`expr $i + 1`
done


## Mongo
### thread
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/thread.json"
OUTPUT_COPY="$FEED_FOLDER/mongo/"$DATE_ON_FILE"_thread.json"
echo "Exporting mongo > thread into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
for i in `cat $MONGO_HOST_LIST`
do
/opt/mongodb_3.0.10/bin/mongoexport -h $i:27018 -urootdbsharding -pRootDBShardingKK2017 --authenticationDatabase=admin -d kaskus_forum -c thread --out temp_thread.json -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"
cat temp_thread.json >> $OUTPUT_FILE
done
cp $OUTPUT_FILE $OUTPUT_COPY
gzip $OUTPUT_COPY

### post
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/post.json"
OUTPUT_COPY="$FEED_FOLDER/mongo/"$DATE_ON_FILE"_post.json"
echo "Exporting mongo > post into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
for i in `cat $MONGO_HOST_LIST`
do
/opt/mongodb_3.0.10/bin/mongoexport -h $i:27018 -urootdbsharding -pRootDBShardingKK2017 --authenticationDatabase=admin -d kaskus_forum -c post --out temp_post.json -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"
cat temp_post.json >> $OUTPUT_FILE
done
#  "{ \"$or\": [{\"dateline\":{\"$gte\":$DATE_START, \"$lt\":$DATE_END }}, {\"last_editor_dateline\":{\"$gte\":$DATE_START, \"$lt\":$DATE_END }}]}"  #can't provide edited post yet
cp $OUTPUT_FILE $OUTPUT_COPY
gzip $OUTPUT_COPY

### userloginlog
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/userloginlog.json"
OUTPUT_COPY="$FEED_FOLDER/mongo/"$DATE_ON_FILE"_userloginlog.json"
echo "Exporting mongo > userloginlog into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
/opt/mongodb_3.0.10/bin/mongoexport -h 172.20.0.90 -ukkreplrw3 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db -d kaskus_user_log -c userloginlog --out $OUTPUT_FILE -q \
  "{datetime:{\$gte:'$PM_DATE_START', \$lt:'$PM_DATE_END' }}"
cp $OUTPUT_FILE $OUTPUT_COPY
gzip $OUTPUT_COPY

### subscribethread
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/subscribethread.json"
OUTPUT_COPY="$FEED_FOLDER/mongo/"$DATE_ON_FILE"_subscribethread.json"
echo "Exporting mongo > subscribethread into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
/opt/mongodb_3.0.10/bin/mongoexport -h 172.20.0.242 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db -d kaskus_forum1 -c subscribethread --out $OUTPUT_FILE -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"
cp $OUTPUT_FILE $OUTPUT_COPY
gzip $OUTPUT_COPY

### transaction_history
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/mongo/transaction_history.json"
echo "Exporting mongo > transaction_history into $OUTPUT_FILE"
mkdir -p "$(dirname $OUTPUT_FILE)"
/opt/mongodb_3.0.10/bin/mongoexport -h 172.20.0.92 -ukkreplrw1 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db -d kaskus_fjb -c transaction_history --out $OUTPUT_FILE -q \
  "{_id:{\$gte:ObjectId('$OID_START'), \$lt:ObjectId('$OID_END') }}"


## Log
OUTPUT_FILE="$PARENT_FOLDER/$OUTPUT_FOLDER/log/log"
echo "Exporting logs into $OUTPUT_FILE"
### TODO dunno where the log is stored

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
#rm -rf "$OUTPUT_FOLDER"

echo "Done."

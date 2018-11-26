MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
date_start=`date -d '1 week ago' +%s`
mysql -h 172.20.0.73 -u$MYSQL_USER -p$MYSQL_PASS user -r -s -N -e "select userid from userlogin where lastlogin >= $date_start limit 1000;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > sample_1k_user.txt
for i in `cat sample_1k_user.txt`
do
partisi=`expr $i % 500`
mongo 172.20.0.157/kaskus_forum1 --eval "rs.slaveOk();db.mypost_$partisi.find({post_userid:$i},{_id:0,post_userid:1,thread_id:1,thread_title:1,forum_title:1}).sort({_id:-1}).limit(10).forEach()" |grep -v 'MongoDB shell version:\|connecting to:'
mongoexport 
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1

password="tryITharder1990"
username="kaskus_fight"
#host="10.10.2.218"
url="/home/rully/";
#host2="10.10.2.17/kaskus_solr"
tanggal=`date "+%s"`
lastweek=`date -d '6 month ago' "+%s"`

date

idfjb=`mysql -u$username -p$password -h 172.20.0.165 -s -N -e "use kaskus_forum;select child_list from forum_list where forum_id=25;"`

mysql -u$username -p$password -h 172.20.0.170 -s -N -e "use kaskus_user; select userlogin.userid,userinfo.usergroupid from userlogin join userinfo on userlogin.userid=userinfo.userid where userlogin.lastlogin <= $lastweek and userinfo.usergroupid not in (36,23);" > $url/useridlogin.csv

mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$nin:[$idfjb]},dateline:{\$lte:$lastweek}},{post_userid:1,_id:0}).forEach(printjson)"|grep -v MongoDB|grep -v connecting > $url/forum.log;

mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$in:[$idfjb]},dateline:{\$lte:$lastweek}},{post_userid:1,_id:0}).forEach(printjson)"|grep -v MongoDB|grep -v connecting > $url/fjb.log;

jumlahUser=`more $url/useridlogin.csv|wc -l`;
jumlahLoop=`expr $jumlahUser / 999`;
atas=0;
bawah=0;
num=1;

while (($num <= $jumlahLoop+1)); 
do
	atas=`expr $num \* 999`;  
	bawah=`expr $atas - 998`;	
	id=`more $url/useridlogin.csv|tr '\t' ' '|cut -d' ' -f1 |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`;
mysql -u$username -p$password -h 172.20.0.165 -s -N -e "use kaskus_forum; select user_id,number_of_post from forum_user_setting where user_id in($id)" >> $url/post_forum.log;	
	((num++));
done

more $url/post_forum.log |tr '\t' '=' > $url/"post_forum.txt"
more $url/forum.log|cut -d'"' -f4|sort |uniq -c | sed 's/^ *//'|tr ' ' '=' > $url/"thread_forum.csv"
more $url/fjb.log|cut -d'"' -f4|sort |uniq -c | sed 's/^ *//'|tr ' ' '=' > $url/"thread_fjb.csv"


mysql -u$username -p$password -h 172.20.0.170 -s -N -e "create database request_log";
mysql -u$username -p$password -h 172.20.0.170 -s -N -e "use request_log;CREATE TABLE post_forum (userid INT,total int);ALTER TABLE post_forum ADD INDEX userid (userid);"
mysql -u$username -p$password -h 172.20.0.170 -s -N -e "use request_log;CREATE TABLE thread_fjb (userid INT,total int);ALTER TABLE thread_fjb ADD INDEX userid (userid);"
mysql -u$username -p$password -h 172.20.0.170 -s -N -e "use request_log;CREATE TABLE useridlogin (userid INT);ALTER TABLE useridlogin ADD INDEX userid2 (userid);"
mysql -u$username -p$password -h 172.20.0.170 -s -N -e "use request_log;CREATE TABLE thread_forum (userid INT,total int);ALTER TABLE thread_forum ADD INDEX userid3 (userid);"
mysqlimport --fields-terminated-by='=' --columns='total,userid' --local -u$username -p$password -h 172.20.0.170 request_log $url/thread_fjb.csv
mysqlimport --fields-terminated-by='=' --columns='total,userid' --local -u$username -p$password -h 172.20.0.170 request_log $url/thread_forum.csv
mysqlimport --columns='userid' --local -u$username -p$password -h 172.20.0.170 request_log $url/useridlogin.csv
mysqlimport --fields-terminated-by='=' --columns='total,userid' --local -u$username -p$password -h 172.20.0.170 request_log $url/post_forum.txt

mysql -u$username -p$password -h 172.20.0.170 -e "use request_log;delete from thread_fjb where userid not in (select userid from useridlogin);";
mysql -u$username -p$password -h 172.20.0.170 -e "use request_log;delete from thread_forum where userid not in (select userid from useridlogin);";
mysql -u$username -p$password -h 172.20.0.170 -e "use request_log;insert into thread_fjb select userid,0 from useridlogin where userid not in (select userid from thread_fjb);"
mysql -u$username -p$password -h 172.20.0.170 -e "use request_log;insert into thread_forum select userid,0 from useridlogin where userid not in (select userid from thread_forum);"
mysql -u$username -p$password -h 172.20.0.170 -e "use request_log; select a.*,from_unixtime(c.joindate),from_unixtime(b.lastlogin) from thread_fjb a,kaskus_user.userlogin b,kaskus_user.userinfo c where a.userid=b.userid and b.userid=c.userid;" > $url/hasilFJB.txt
mysql -u$username -p$password -h 172.20.0.170 -e "use request_log; select a.*,from_unixtime(c.joindate),from_unixtime(b.lastlogin) from thread_forum a,kaskus_user.userlogin b,kaskus_user.userinfo c where a.userid=b.userid and b.userid=c.userid;" > $url/hasilForum.txt
mysql -u$username -p$password -h 172.20.0.170 -e "use request_log; select a.*,from_unixtime(c.joindate),from_unixtime(b.lastlogin) from post_forum a,kaskus_user.userlogin b,kaskus_user.userinfo c where a.userid=b.userid and b.userid=c.userid;" > $url/post_forum_hasil.txt;
mysql -u$username -p$password -h 172.20.0.170 -s -N -e "drop database request_log";



rm $url/forum.log;
rm $url/fjb.log;
rm $url/useridlogin.csv;
rm $url/"thread_fjb.csv";
rm $url/"thread_forum.csv"
echo "Finish"

date


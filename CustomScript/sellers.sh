#1 bulan yg lalu
lastpost=`date -d '1 month ago' "+%s"`
url="/home/rully"
kaskususer="172.20.0.170"
kaskusforum="172.20.0.165"

mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskusforum -s -N -e "use kaskus_forum;select child_list from forum_list where forum_id in (210,205,317,196,197,221,195,220,198,588);" >> $url/"forum1.log"
for i in `more $url/"forum1.log"`; do echo $i|sed 's/.\{3\}$//' >> $url/"forum.log"; done
forum_id=`more $url/"forum.log"|tr '\n' ',' |sed 's/.\{1\}$//'`
rm $url/"forum1.log";
rm $url/"forum.log";

mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$in:[$forum_id]},prefix_id:'WTS',last_post:{\$gt:$lastpost}},{post_userid:1,_id:0}).forEach(printjson)" >> $url/"userid.log";
more $url/"userid.log" |grep -v MongoDB |grep -v connecting |cut -d':' -f2|cut -d'"' -f2|sort|uniq -c > $url/"userid2.log"

for i in `more  $url/"userid2.log" |sed 's/^ *//'|tr ' ' '.'`
do
totalpost=`echo $i|cut -d'.' -f1`;
if [ $totalpost -gt 4 ]
then
	echo $i|cut -d'.' -f2 >> $url/"userid3.log"
fi
done

#5 bulan yg lalu
fivemonth=`date -d '5 month ago' "+%s"`
totaldata=`more $url/"userid3.log" |wc -l`
totallooping=`expr $totaldata / 999`
#proses loop
num=1;
while (($num <= $totallooping+1)); 
do
	atas=`expr $num \* 999`;  
	bawah=`expr $atas - 998`;	
	userid=`more $url/"userid3.log" |sed -n "$bawah,$atas p" |tr '\n' ','|sed 's/.\{1\}$//'`;
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskususer -s -N -e "use kaskus_user;select userid from userinfo where userid in ($userid) and joindate > $fivemonth;" >> $url/"userid4.log";
	((num++));
done




#5 Maret 2014
twomonth=`date -d '2 month ago' "+%s"`
totaldata=`more $url/"userid4.log" |wc -l`
totallooping=`expr $totaldata / 999`
num=1;
while (($num <= $totallooping+1)); 
do
	atas=`expr $num \* 999`;  
	bawah=`expr $atas - 998`;	
	userid=`more $url/"userid4.log" |sed -n "$bawah,$atas p" |tr '\n' ','|sed 's/.\{1\}$//'`;
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskususer -s -N -e "use kaskus_user;select userid from userlogin where userid in ($userid) and lastlogin > $twomonth" >> $url/"userid5.log";

	((num++));
done


totaldata=`more $url/"userid5.log" |wc -l`
totallooping=`expr $totaldata / 999`
num=1;
while (($num <= $totallooping+1)); 
do
	atas=`expr $num \* 999`;  
	bawah=`expr $atas - 998`;	
	userid=`more $url/"userid5.log" |sed -n "$bawah,$atas p" |tr '\n' ','|sed 's/.\{1\}$//'`;
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskususer -e "use kaskus_user; select 	userinfo.userid,userlogin.username,userinfo.email,userinfo.gender,userinfo.dateofbirth,userinfo.phone from userinfo join userlogin on userinfo.userid = userlogin.userid where userinfo.userid in ($userid) order by userlogin.lastlogin desc limit 5000;" >> $url/"5000_active.csv";
	((num++));
done

cp $url/"5000_active.csv" $url/report/

[ -f $url"userid.log" ] && rm $url"userid.log"

[ -f $url"userid2.log" ] && rm $url"userid2.log"

[ -f $url"userid3.log" ] && rm $url"userid3.log"

[ -f $url"userid4.log" ] && rm $url"userid4.log"

[ -f $url"userid5.log" ] && rm $url"userid5.log"

$url/report/sellersnotactive.sh



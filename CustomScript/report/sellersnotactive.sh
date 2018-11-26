#1 bulan lalu
lastpost=`date -d '1 month ago' "+%s"`
url="/home/rully/report";
kaskusforum="172.20.0.165"
kaskususer="172.20.0.170"
#host2="10.10.3.239"
#where 
mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskusforum -s -N -e "use kaskus_forum;select child_list from forum_list where forum_id in (196,210,317,197)" >> $url/"forum1.log"
for i in `more $url/"forum1.log"`; do echo $i|sed 's/.\{3\}$//' >> $url/"forum.log"; done
forum_id=`more $url/"forum.log"|tr '\n' ',' |sed 's/.\{1\}$//'`
rm $url/"forum1.log";
rm $url/"forum.log";

mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$in:[$forum_id]},prefix_id:'WTS',last_post:{\$gt:$lastpost}},{post_userid:1,_id:0}).forEach(printjson)" >> $url/"userid.log";
more $url/"userid.log" |grep -v MongoDB |grep -v connecting |cut -d':' -f2|cut -d'"' -f2|sort|uniq -c > $url/"userid2.log"

for i in `more $url/"userid2.log" |sed 's/^ *//'|tr ' ' '.'`
do
totalpost=`echo $i|cut -d'.' -f1`;
if [ $totalpost -gt 2 ]
then
	echo $i|cut -d'.' -f2 >> $url/"userid3.log"
fi
done

#8 bulan lalu
eightmonth=`date -d '8 month ago' "+%s"`
totaldata=`more $url/"userid3.log" |wc -l`
totallooping=`expr $totaldata / 999`
#proses loop
num=1;
while (($num <= $totallooping+1)); 
do
	atas=`expr $num \* 999`;  
	bawah=`expr $atas - 998`;	
	userid=`more $url/"userid3.log" |sed -n "$bawah,$atas p" |tr '\n' ','|sed 's/.\{1\}$//'`;
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskususer -s -N -e "use kaskus_user;select userid from userinfo where userid in ($userid) and joindate > $eightmonth" >> $url/"userid4.log";
	((num++));
done




#6 bulan lalu
sixmonth=`date -d '6 month ago' "+%s"`
totaldata=`more $url/"userid4.log" |wc -l`
totallooping=`expr $totaldata / 999`
num=1;
while (($num <= $totallooping+1));
do
	atas=`expr $num \* 999`;
	bawah=`expr $atas - 998`;
	userid=`more $url/"userid4.log" |sed -n "$bawah,$atas p" |tr '\n' ','|sed 's/.\{1\}$//'`;
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskususer -s -N -e "use kaskus_user;select userid from userlogin where userid in ($userid) and lastlogin > $sixmonth" >> $url/"userid5.log";

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
	userid_active=`more $url/5000_active.csv|tr '\t' ','|cut -d',' -f1|grep -v userid|sed -n "$bawah,$atas p" |tr '\n' ','|sed 's/.\{1\}$//'`;
	#active=`expr length $userid_active`;
	if [ "$userid_active" = "" ]
	then
		userid_active="''"
	fi
echo $userid_active
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h $kaskususer -e "use kaskus_user; select 	userinfo.userid,userlogin.username,userinfo.email,userinfo.gender,userinfo.dateofbirth,userinfo.phone from userinfo join userlogin on userinfo.userid = userlogin.userid where userinfo.userid in ($userid) and userinfo.userid not in($userid_active) order by userlogin.lastlogin desc  limit 5000;" >> $url/"5000_nonactive.csv";
	((num++));
done

sendemail -f statistic@kaskusnetworks.com -t stevi.larasati@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com,alken@kaskusnetworks.com,sista.wulandari@kaskusnetworks.com,soegi@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,stevan.soplanit@kaskusnetworks.com -u "[FJB Store Survey] Penarikan Data Responden" -m "Dear All, \n Berikut request data seller sesuai dengan category dan parameter yang telah ditentukan. \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $url/"5000_active.csv" $url/"5000_nonactive.csv" -s 172.16.0.5 > /dev/null  2>&1


[ -f $url"userid.log" ] && rm $url"userid.log"

[ -f $url"userid2.log" ] && rm $url"userid2.log"

[ -f $url"userid3.log" ] && rm $url"userid3.log"

[ -f $url"userid4.log" ] && rm $url"userid4.log"

[ -f $url"userid5.log" ] && rm $url"userid5.log"





#5 April 2014
username="root";
host="172.20.0.170";
url="/home/rully";

totaldata=`more $url/hasil_nonactive.log |wc -l`
jumlahloop=`expr $totaldata / 999`
num=1;
while (($num <= $jumlahloop+1));
do
	atas=`expr $num \* 999`;
	bawah=`expr $atas - 998`;
	userid=`more $url/"hasil_nonactive.log"|grep -v "userid" |sed -n "$bawah,$atas p" |tr '\t' '.'|cut -d'.' -f1|tr '\n' ','|sed 's/.\{1\}$//'`;
	mysql -u $MYSQL_USER -p$MYSQL_PASS -h$host -e "use kaskus_user; select 	userinfo.userid,userlogin.username,userinfo.email,userinfo.gender,userinfo.dateofbirth,userinfo.phone from userinfo join userlogin on userinfo.userid = userlogin.userid where userinfo.userid in ($userid) and userinfo.usergroupid != 23" >> $url/"hasil_active2.log";
	((num++));
done





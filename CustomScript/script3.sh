condition=$1
. /home/rully/data_analityc/test/initialize.sh $condition


#Klasifikasi user KASKUS berdasarkan lokasi (Provinsi)
mysql -u$username -p$password -h $host_user -s -N -e "use user; select province,country from userinfo where joindate >= $lastweek and joindate <= $tanggal" > $url/"province_"$condition".log"
cat $url/"province_"$condition".log"|tr '\t' '.'|cut -d'.' -f1 |sort|uniq -c >> $url/"prov_uniq_"$condition".log"
cat $url/"province_"$condition".log"|tr '\t' '.'|cut -d'.' -f2 |sort|uniq -c >> $url/"country_uniq_"$condition".log"
rm $url/"province_"$condition".log"
mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic; select id_report,name_report from report_info where id_report like 'KK-$code-DEM-04-ID-%'" > $url/"request_province_"$condition".log"

mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic; select * from report_info where id_report like 'KK-$code-DEM-04-%' and id_report not in (select id_report from report_info where id_report like 'KK-$code-DEM-04-ID-%');" > $url/"request_country_"$condition".log"
for i in `cat $url/"request_province_"$condition".log"|tr '\t' '.' |tr ' ' '_'`
do
	kode=`echo $i|cut -d'.' -f1`;
	nama=`echo $i|cut -d'.' -f2|tr '_' ' '`;
	total_data=`cat $url/"prov_uniq_"$condition".log" |grep "$nama$"`;
	a=`echo $total_data|cut -d' ' -f1`;
	echo $kode"="$a >> $url/"Demographic_"$tanggal"_"$condition".log";
done
echo "Klasifikasi user KASKUS berdasarkan lokasi (Provinsi) - [DONE]"




#Klasifikasi user KASKUS berdasarkan lokasi Country
for i in `cat $url/"request_country_"$condition".log"|tr '\t' '.' |tr ' ' '_'`
do
	kode=`echo $i|cut -d'.' -f1`;
	nama=`echo $kode| tail -c 2`
	total_data=`cat $url/"country_uniq_"$condition".log" |sort -rnk1|grep "$nama$"|sed -n "1,1p"|sed 's/^ *//'|cut -d' ' -f1`;
	echo $kode"="$total_data >> $url/"Demographic_"$tanggal"_"$condition".log";

done
echo "Klasifikasi user KASKUS berdasarkan lokasi Country - [DONE]"
[ -f $url/"province_"$condition".log" ] && rm $url/"province_"$condition".log"
[ -f $url/"request_province_"$condition".log" ] && rm $url/"request_province_"$condition".log"
[ -f $url/"prov_uniq_"$condition".log" ] && rm $url/"prov_uniq_"$condition".log"
[ -f $url/"country_uniq_"$condition".log" ] && rm $url/"country_uniq_"$condition".log"




#Jumlah user KASKUS yang membuat akun KASKUS+login pertama kali melalui akun Facebook G+ and Twitter
userfb=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(userinfo.userid) as Total from fbuser join userinfo on fbuser.kaskususerid = userinfo.userid where userinfo.joindate >= $lastweek and userinfo.joindate <= $tanggal"`; 

twitter=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(userinfo.userid) as Total from twitteruser join userinfo on twitteruser.kaskususerid = userinfo.userid where userinfo.joindate >= $lastweek and userinfo.joindate <= $tanggal"`; 

gplus=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(userinfo.userid) as Total from gpuser join userinfo on gpuser.kaskususerid = userinfo.userid where userinfo.joindate >= $lastweek and userinfo.joindate <= $tanggal"`; 

total=`expr $userfb + $twitter + $gplus`

echo "KK-$code-LOG-02""="$total>> $url/"Demographic_"$tanggal"_"$condition".log";
echo "KK-$code-LOG-02-01""="$userfb>> $url/"Demographic_"$tanggal"_"$condition".log";
echo "KK-$code-LOG-02-02""="$twitter>> $url/"Demographic_"$tanggal"_"$condition".log";
echo "KK-$code-LOG-02-03""="$gplus>> $url/"Demographic_"$tanggal"_"$condition".log";

echo "Kaskus User Sosial Media Only [DONE]"




#Klasifikasi user KASKUS di FJB berdasarkan jenis kelamin
id_fjb=`mysql -u$username -p$password -h $host_forum forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`
mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$in:[$id_fjb]},dateline:{\$lte:$tanggal,\$gte:$lastweek} },{_id:0,post_userid:1}).forEach(printjson)"	 |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' >> $url/"userid2_"$condition".log"
cat $url/"userid2_"$condition".log" |sort|uniq >> $url/"userid_"$condition".log"
cat $url/"userid_"$condition".log"|grep post_userid |cut -d':' -f2|cut -d' ' -f2|cut -d'"' -f2|sort|uniq|head -c-1 >> $url/"distinctuserid_"$condition".log"
totaluser=`cat $url/"distinctuserid_"$condition".log"|wc -l`

[ -f $url/"userid2_"$condition".log" ] && rm $url/"userid2_"$condition".log"
[ -f $url/"userid_"$condition".log" ] && rm $url/"userid_"$condition".log"

jumlahloop=`expr $totaluser \/ 999`
atas=0;
bawah=0;
male=0;
female=0;
num=1;
for num in `seq 1 $jumlahloop`;
do
	atas=`expr $num \* 999`;
	bawah=`expr $atas - 998`;
	id=`cat $url/"distinctuserid_"$condition".log" |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`;
	mysql -u$username -p$password -h $host_user -s -N -e "use user;select province,country from userinfo where userid in($id)" >> $url/"prov_country_data_"$condition".log";
	m=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(gender) from userinfo where userid in($id) and gender = 1"`;
	f=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(gender) from userinfo where userid in($id) and gender = 0"`;
	male=`expr $male + $m`;
	female=`expr $female + $f`;
	mysql -u$username -p$password -h $host_user -s -N -e "use user;  select dateofbirth from userinfo where userid in($id)" >> $url/"lahir_"$condition".log";
done


echo "KK-$code-DEM-FJB-01-01""="$male >> $url/"Fjbreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FJB-01-02""="$female >> $url/"Fjbreport_"$tanggal"_"$condition".log";
echo "Klasifikasi user KASKUS di FJB berdasarkan jenis kelamin [DONE]"

if [ $condition == "month" ]
then
	#MONTHLY
	for i in `cat $url/"lahir_"$condition".log"|cut -d'-' -f1|sort|uniq -c| sed 's/^ *//' | sed 's/ *$//'|tr ' ' '.'`
	do
			total=`echo $i|cut -d'.' -f1`
			tahunlahir=`echo $i|cut -d'.' -f2`

			AGE=`expr $tahun - $tahunlahir`;
			if [ "$AGE" -lt 16 ]
			then
				TOTAL_AGE_15=`expr $TOTAL_AGE_15  + $total`;
			elif [ "$AGE" -ge 16 ] && [ "$AGE" -lt 21 ]
			then
				TOTAL_AGE_1620=`expr $TOTAL_AGE_1620  + $total`;
			elif [ "$AGE" -ge 21 ] && [ "$AGE" -lt 26 ]
			then
				TOTAL_AGE_2125=`expr $TOTAL_AGE_2125  + $total`;
			elif [ "$AGE" -ge 26 ] && [ "$AGE" -lt 31 ]
			then
				TOTAL_AGE_2630=`expr $TOTAL_AGE_2630  + $total`;
			elif [ "$AGE" -ge 31 ] && [ "$AGE" -lt 36 ]
			then
				TOTAL_AGE_3135=`expr $TOTAL_AGE_3135  + $total`;
			elif [ "$AGE" -ge 36 ] && [ "$AGE" -lt 41 ]
			then
				TOTAL_AGE_3640=`expr $TOTAL_AGE_3640  + $total`;
			elif [ "$AGE" -ge 41 ] && [ "$AGE" -lt 46 ]
			then
				TOTAL_AGE_4145=`expr $TOTAL_AGE_4145  + $total`;
			elif [ "$AGE" -ge 46 ] && [ "$AGE" -lt 51 ]
			then
				TOTAL_AGE_4650=`expr $TOTAL_AGE_4650  + $total`;
			elif [ "$AGE" -ge 51 ] && [ "$AGE" -lt 56 ]
			then
				TOTAL_AGE_5155=`expr $TOTAL_AGE_5155  + $total`;
			elif [ "$AGE" -ge 56 ] && [ "$AGE" -lt 61 ]
			then
				TOTAL_AGE_5660=`expr $TOTAL_AGE_5660  + $total`;
			elif [ "$AGE" -ge 61 ] && [ "$AGE" -lt 66 ]
			then
				TOTAL_AGE_6165=`expr $TOTAL_AGE_6165  + $total`;
			elif [ "$AGE" -ge 66 ]
			then
				TOTAL_AGE_66=`expr $TOTAL_AGE_66  + $total`;
			fi

	done

	echo "KK-$code-DEM-FJB-02-01=$TOTAL_AGE_15" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-02=$TOTAL_AGE_1620" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-03=$TOTAL_AGE_2125" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-04=$TOTAL_AGE_2630" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-05=$TOTAL_AGE_3135" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-06=$TOTAL_AGE_3640" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-07=$TOTAL_AGE_4145" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-08=$TOTAL_AGE_4650" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-09=$TOTAL_AGE_5155" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-10=$TOTAL_AGE_5660" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-11=$TOTAL_AGE_6165" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-02-12=$TOTAL_AGE_66" >> $url/"Fjbreport_"$tanggal"_"$condition".log";


	#MONTHLY
	#replies umur

	mongo kaskus_forum1 --eval "db.thread.find({prefix_id:{\$in:['wts','wtb','WTS','WTB']},dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$id_fjb]}},{_id:1}).forEach(printjson)"|grep -v Mongo|grep -v connect|cut -d':' -f2|cut -d'(' -f2|cut -d")" -f1 |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' >> $url/"thread_id_"$condition".log"

	totalthread=`cat $url/"thread_id_"$condition".log" |wc -l`
	jumlahloop=`expr $totalthread \/ 999`
	atas=0;
	bawah=0;
	num=1;
	#get data userid
	for num in `seq 1 $jumlahloop`;
	do
		atas=`expr $num \* 999`;
		bawah=`expr $atas - 998`;
		id=`cat $url/"thread_id_"$condition".log" |sed -n "$bawah,$atas p"|tr '"' "'" | tr '\n' ','|sed -e 's/,$//g'`;
		mongo kaskus_forum1 --eval "db.post.find({thread_id:{\$in:[$id]}},{_id:0,post_userid:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' >> $url/"thread_id_temp_"$condition".log"	

	done

	rm $url/"thread_id_"$condition".log";
	#mapping data with age
	cat $url/"thread_id_temp_"$condition".log"|grep -v Mongo|grep -v connect|cut -d':' -f2|cut -d' ' -f2|sort|uniq >> $url/"userdistinct_"$condition".log"
	totalthread=`cat $url/"userdistinct_"$condition".log" |wc -l`
	jumlahloop=`expr $totalthread \/ 999`
	num=1;
	for num in `seq 1 $jumlahloop`;
	do
		atas=`expr $num \* 999`;
		bawah=`expr $atas - 998`;
		id=`cat $url/"userdistinct_"$condition".log"|sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`;
		mysql -u$username -p$password -h $host_user -s -N -e "use user;  select dateofbirth from userinfo where userid in($id)" >> $url/"lahir_"$condition".log";
	
	done
	rm $url/"thread_id_temp_"$condition".log";
	rm  $url/"userdistinct_"$condition".log";


	#GET DATA
	TOTAL_AGE_15=0;
	TOTAL_AGE_1620=0;
	TOTAL_AGE_2125=0;
	TOTAL_AGE_2630=0;
	TOTAL_AGE_3135=0;
	TOTAL_AGE_3640=0;
	TOTAL_AGE_4145=0;
	TOTAL_AGE_4650=0;
	TOTAL_AGE_5155=0;
	TOTAL_AGE_5660=0;
	TOTAL_AGE_6165=0;
	TOTAL_AGE_66=0;

	for i in `cat $url/"lahir_"$condition".log"|cut -d'-' -f1|sort|uniq -c|sed 's/^ *//' | sed 's/ *$//'|tr ' ' '.'`
	do

			total=`echo $i|cut -d'.' -f1`
			tahunlahir=`echo $i|cut -d'.' -f2`

			AGE=`expr $tahun - $tahunlahir`;
			if [ "$AGE" -lt 16 ]
			then
				TOTAL_AGE_15=`expr $TOTAL_AGE_15  + $total`;
			elif [ "$AGE" -ge 16 ] && [ "$AGE" -lt 21 ]
			then
				TOTAL_AGE_1620=`expr $TOTAL_AGE_1620  + $total`;
			elif [ "$AGE" -ge 21 ] && [ "$AGE" -lt 26 ]
			then
				TOTAL_AGE_2125=`expr $TOTAL_AGE_2125  + $total`;
			elif [ "$AGE" -ge 26 ] && [ "$AGE" -lt 31 ]
			then
				TOTAL_AGE_2630=`expr $TOTAL_AGE_2630  + $total`;
			elif [ "$AGE" -ge 31 ] && [ "$AGE" -lt 36 ]
			then
				TOTAL_AGE_3135=`expr $TOTAL_AGE_3135  + $total`;
			elif [ "$AGE" -ge 36 ] && [ "$AGE" -lt 41 ]
			then
				TOTAL_AGE_3640=`expr $TOTAL_AGE_3640  + $total`;
			elif [ "$AGE" -ge 41 ] && [ "$AGE" -lt 46 ]
			then
				TOTAL_AGE_4145=`expr $TOTAL_AGE_4145  + $total`;
			elif [ "$AGE" -ge 46 ] && [ "$AGE" -lt 51 ]
			then
				TOTAL_AGE_4650=`expr $TOTAL_AGE_4650  + $total`;
			elif [ "$AGE" -ge 51 ] && [ "$AGE" -lt 56 ]
			then
				TOTAL_AGE_5155=`expr $TOTAL_AGE_5155  + $total`;
			elif [ "$AGE" -ge 56 ] && [ "$AGE" -lt 61 ]
			then
				TOTAL_AGE_5660=`expr $TOTAL_AGE_5660  + $total`;
			elif [ "$AGE" -ge 61 ] && [ "$AGE" -lt 66 ]
			then
				TOTAL_AGE_6165=`expr $TOTAL_AGE_6165  + $total`;
			elif [ "$AGE" -ge 66 ]
			then
				TOTAL_AGE_66=`expr $TOTAL_AGE_66  + $total`;
			fi

	done

	rm $url/"lahir_"$condition".log";
	echo "KK-$code-DEM-FJB-03-01=$TOTAL_AGE_15" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-02=$TOTAL_AGE_1620" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-03=$TOTAL_AGE_2125" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-04=$TOTAL_AGE_2630" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-05=$TOTAL_AGE_3135" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-06=$TOTAL_AGE_3640" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-07=$TOTAL_AGE_4145" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-08=$TOTAL_AGE_4650" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-09=$TOTAL_AGE_5155" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-10=$TOTAL_AGE_5660" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-11=$TOTAL_AGE_6165" >> $url/"Fjbreport_"$tanggal"_"$condition".log";
	echo "KK-$code-DEM-FJB-03-12=$TOTAL_AGE_66" >> $url/"Fjbreport_"$tanggal"_"$condition".log";

fi




#Klasifikasi user KASKUS di FJB berdasarkan lokasi PROV	
mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic; select id_report,name_report from report_info where id_report like 'KK-$code-DEM-FJB-04-ID-%';" >> $url/"prov_req_"$condition".log"

mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic; select id_report,name_report from report_info where id_report like 'KK-$code-DEM-FJB-04-%' and id_report not in (select id_report from report_info where id_report like 'KK-$code-DEM-FJB-04-ID-%');" >> $url/"country_req_"$condition".log"
for i in `cat $url/"prov_req_"$condition".log" |tr '\t' '.' |tr ' ' '_'`; do
	prov=`echo $i|cut -d'.' -f2|tr '_' ' '`;
	kode=`echo $i|cut -d'.' -f1`;
	total=`cat $url/"prov_country_data_"$condition".log" |tr '\t' '.' |cut -d'.' -f1 |grep "^$prov$"|wc -l`;
	echo $kode"="$total >> $url/"Fjbreport_"$tanggal"_"$condition".log";
done;
echo "Klasifikasi user KASKUS di FJB berdasarkan lokasi PROV	 [DONE]"




#Klasifikasi user KASKUS di FJB berdasarkan lokasi Country
for i in `cat $url/"country_req_"$condition".log" |tr '\t' '.' |tr ' ' '_'`; do
	country=`echo $i|cut -d'.' -f2|tr '_' ' '`;
	kode=`echo $i|cut -d'.' -f1`;
	total=`cat $url/"prov_country_data_"$condition".log" |tr '\t' '.' |cut -d'.' -f2 |grep "^$country$"|wc -l`;
	echo $kode"="$total >> $url/"Fjbreport_"$tanggal"_"$condition".log";
done;
[ -f $url/"prov_req_"$condition".log" ] && rm $url/"prov_req_"$condition".log"
[ -f $url/"country_req_"$condition".log" ] && rm $url/"country_req_"$condition".log"
[ -f $url/"distinctuserid_"$condition".log" ] && rm $url/"distinctuserid_"$condition".log"
#[ -f $url/"prov_country_data_"$condition".log" ] && rm $url/"prov_country_data_"$condition".log"

echo "Klasifikasi user KASKUS di FJB berdasarkan lokasi Country	 [DONE]"

id_fjb=`mysql -u$username -p$password -h $host_forum forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`




#Distribusi thread WTB pada categories di FJB 
for i in `mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic;select forum_id,id_report from report_info where id_report like 'KK-$code-FJB-10-%';"|tr '\t' '.'`; do
	kode=`echo $i|cut -d'.' -f2`;

	a=`echo $i|cut -d'.' -f1`

	forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use forum; select child_list from forum_list where forum_id = $a"`

	mongo kaskus_forum1 --eval "db.thread.find({prefix_id:{\$in:['WTB','wtb']},dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]}},{_id:0,post_userid:1,forum_id:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"wtb_"$condition".log";

	total=`cat $url/"wtb_"$condition".log" |grep -v Mongo |grep -v connect|cut -d',' -f2|cut -d':' -f2 |cut -d'"' -f2|wc -l`;

	echo $kode"="$total >> $url/"Fjbreport_"$tanggal"_"$condition".log";
done

echo "Distribusi thread WTB pada categories di FJB  [DONE]"




#Distribusi thread WTS pada categories di FJB 
for i in `mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic;select forum_id,id_report from report_info where id_report like 'KK-$code-FJB-11-%';"|tr '\t' '.'`
do
	kode=`echo $i|cut -d'.' -f2`;
	a=`echo $i|cut -d'.' -f1`
forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use forum; select child_list from forum_list where forum_id = $a"`
	mongo kaskus_forum1 --eval "db.thread.find({prefix_id:{\$in:['WTS','wts']},dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]}},{_id:0,post_userid:1,forum_id:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' >$url/"wts_"$condition".log";

	total=`cat  $url/"wts_"$condition".log"|grep -v Mongo |grep -v connect|cut -d',' -f2|cut -d':' -f2 |cut -d'"' -f2|wc -l`;
	echo $kode"="$total >> $url/"Fjbreport_"$tanggal"_"$condition".log";
done
mongo kaskus_forum1 --eval "db.thread.count({dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$id_fjb]},prefix_id:{\$nin:['wtb','WTB','wts','WTS']}})"|sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"tempunidentified_"$condition".log"

hasilunidentified=`cat $url/"tempunidentified_"$condition".log"|grep -v MongoDB|grep -v connecting`
echo "KK-W-FJB-12="$hasilunidentified >> $url/"Fjbreport_"$tanggal"_"$condition".log";
rm $url/"tempunidentified_"$condition".log";
rm $url/"wtb_"$condition".log";
rm $url/"wts_"$condition".log";
echo "Distribusi thread WTB pada categories di FJB  [DONE]";



#Distribusi reply/post thread WTB pada categories di FJB
for i in `mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic;select forum_id,id_report from report_info where id_report like 'KK-$code-FJB-19-%';"|tr '\t' '.'`
do
	kode=`echo $i|cut -d'.' -f2`;
	a=`echo $i|cut -d'.' -f1`
	total_post=0;
	forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use forum; select child_list from forum_list where forum_id = $a"`
	mongo kaskus_forum1 --eval "db.thread.find({prefix_id:{\$in:['WTB','wtb']},dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]},reply_count:{\$gt:0}},{_id:0,reply_count:1,forum_id:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"wtb_"$condition".log";
	
	for i in `cat $url/"wtb_"$condition".log" |grep -v Mongo|grep -v connect|cut -d',' -f2|cut -d':' -f2|cut -d' ' -f2`
	do
		 total_post=`expr $total_post + $i`;
	done
	echo $kode"="$total_post >> $url/"Fjbreport_"$tanggal"_"$condition".log";
done
rm $url/"wtb_"$condition".log";
echo "Distribusi reply/post thread WTB pada categories di FJB  [DONE]"




#Distribusi reply/post thread WTS pada categories di FJB
for i in `mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic;select forum_id,id_report from report_info where id_report like 'KK-$code-FJB-20-%';"|tr '\t' '.'`
do
	kode=`echo $i|cut -d'.' -f2`;
	a=`echo $i|cut -d'.' -f1`;

	total_post=0;
	forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use forum; select child_list from forum_list where forum_id = $a"`

	mongo kaskus_forum1 --eval "db.thread.find({prefix_id:{\$in:['WTS','wts']},dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]},reply_count:{\$gt:0}},{_id:0,reply_count:1,forum_id:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"wtb_"$condition".log";
	for i in `cat $url/"wtb_"$condition".log" |grep -v Mongo|grep -v connect|cut -d',' -f2|cut -d':' -f2|cut -d' ' -f2`
	do
		 total_post=`expr $total_post + $i`;
	done
	echo $kode"="$total_post >> $url/"Fjbreport_"$tanggal"_"$condition".log";
done
echo "Distribusi reply/post thread WTS pada categories di FJB [DONE]";
rm $url/"wtb_"$condition".log";




#Distribusi reply/post thread unditifiend pada categories di FJB
total_post=0;
forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use forum; select child_list from forum_list where forum_id = 25"`

mongo kaskus_forum1 --eval "db.thread.find({prefix_id:{\$nin:['WTS','wts','WTB','wtb']},dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]},reply_count:{\$gt:0}},{_id:0,reply_count:1,forum_id:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"wtb_"$condition".log";

for i in `cat $url/"wtb_"$condition".log" |grep -v Mongo|grep -v connect|cut -d',' -f2|cut -d':' -f2|cut -d' ' -f2`
do
		 total_post=`expr $total_post + $i`;
done

echo "KK-$code-FJB-21="$total_post >> $url/"Fjbreport_"$tanggal"_"$condition".log";





#Klasifikasi user KASKUS di FORUM berdasarkan jenis kelamin

id_fjb=`mysql -u$username -p$password -h $host_forum forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`
mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$nin:[$id_fjb]},dateline:{\$lte:$tanggal,\$gte:$lastweek} },{_id:0,post_userid:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' >> $url/"userid2_"$condition".log"
cat $url/"userid2_"$condition".log" |sort|uniq >> $url/"userid_"$condition".log"
cat $url/"userid_"$condition".log"|grep post_userid |cut -d':' -f2|cut -d' ' -f2|cut -d'"' -f2|sort|uniq|head -c-1 >> $url/"distinctuserid_"$condition".log"

totaluser=`cat $url/"distinctuserid_"$condition".log"|wc -l`

[ -f $url/"userid2_"$condition".log" ] && rm $url/"userid2_"$condition".log"
[ -f $url/"userid_"$condition".log" ] && rm $url/"userid_"$condition".log"

jumlahloop=`expr $totaluser \/ 999`
atas=0;
bawah=0;
male=0;
female=0;
num=1;

for num in `seq 1 $jumlahloop`;
do
	atas=`expr $num \* 999`;
	bawah=`expr $atas - 998`;
	id=`cat $url/"distinctuserid_"$condition".log" |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`;
	mysql -u$username -p$password -h $host_user -s -N -e "use user;select province,country from userinfo where userid in($id)" >> 			$url/"prov_country_data_"$condition".log";
	m=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(gender) from userinfo where userid in($id) and gender = 1"`;
	f=`mysql -u$username -p$password -h $host_user -s -N -e "use user;select count(gender) from userinfo where userid in($id) and gender = 0"`;
	male=`expr $male + $m`;
	female=`expr $female + $f`;
	mysql -u$username -p$password -h $host_user -s -N -e "use user;  select dateofbirth from userinfo where userid in($id)" >> $url/"lahir_"$condition".log";
	    let num=num+1 
done
echo "KK-$code-DEM-FRM-01-01""="$male >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-01-02""="$female >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "Klasifikasi user KASKUS di FORUM berdasarkan jenis kelamin [DONE]"

TOTAL_AGE_15=0;
TOTAL_AGE_1620=0;
TOTAL_AGE_2125=0;
TOTAL_AGE_2630=0;
TOTAL_AGE_3135=0;
TOTAL_AGE_3640=0;
TOTAL_AGE_4145=0;
TOTAL_AGE_4650=0;
TOTAL_AGE_5155=0;
TOTAL_AGE_5660=0;
TOTAL_AGE_6165=0;
TOTAL_AGE_66=0;

for i in `cat $url/"lahir_"$condition".log"|cut -d'-' -f1|sort|uniq -c|sed 's/^ *//' | sed 's/ *$//'|tr ' ' '.'`
do

		total=`echo $i|cut -d'.' -f1`
		tahunlahir=`echo $i|cut -d'.' -f2`
		AGE=`expr $tahun - $tahunlahir`;
		if [ "$AGE" -lt 16 ]
		then
			TOTAL_AGE_15=`expr $TOTAL_AGE_15  + $total`;
		elif [ "$AGE" -ge 16 ] && [ "$AGE" -lt 21 ]
		then
			TOTAL_AGE_1620=`expr $TOTAL_AGE_1620  + $total`;
		elif [ "$AGE" -ge 21 ] && [ "$AGE" -lt 26 ]
		then
			TOTAL_AGE_2125=`expr $TOTAL_AGE_2125  + $total`;
		elif [ "$AGE" -ge 26 ] && [ "$AGE" -lt 31 ]
		then
			TOTAL_AGE_2630=`expr $TOTAL_AGE_2630  + $total`;
		elif [ "$AGE" -ge 31 ] && [ "$AGE" -lt 36 ]
		then
			TOTAL_AGE_3135=`expr $TOTAL_AGE_3135  + $total`;
		elif [ "$AGE" -ge 36 ] && [ "$AGE" -lt 41 ]
		then
			TOTAL_AGE_3640=`expr $TOTAL_AGE_3640  + $total`;
		elif [ "$AGE" -ge 41 ] && [ "$AGE" -lt 46 ]
		then
			TOTAL_AGE_4145=`expr $TOTAL_AGE_4145  + $total`;
		elif [ "$AGE" -ge 46 ] && [ "$AGE" -lt 51 ]
		then
			TOTAL_AGE_4650=`expr $TOTAL_AGE_4650  + $total`;
		elif [ "$AGE" -ge 51 ] && [ "$AGE" -lt 56 ]
		then
			TOTAL_AGE_5155=`expr $TOTAL_AGE_5155  + $total`;
		elif [ "$AGE" -ge 56 ] && [ "$AGE" -lt 61 ]
		then
			TOTAL_AGE_5660=`expr $TOTAL_AGE_5660  + $total`;
		elif [ "$AGE" -ge 61 ] && [ "$AGE" -lt 66 ]
		then
			TOTAL_AGE_6165=`expr $TOTAL_AGE_6165  + $total`;
		elif [ "$AGE" -ge 66 ]
		then
			TOTAL_AGE_66=`expr $TOTAL_AGE_66  + $total`;
		fi

done

rm $url/"lahir_"$condition".log";
echo "KK-$code-DEM-FRM-02-01=$TOTAL_AGE_15" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-02=$TOTAL_AGE_1620" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-03=$TOTAL_AGE_2125" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-04=$TOTAL_AGE_2630" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-05=$TOTAL_AGE_3135" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-06=$TOTAL_AGE_3640" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-07=$TOTAL_AGE_4145" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-08=$TOTAL_AGE_4650" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-09=$TOTAL_AGE_5155" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-10=$TOTAL_AGE_5660" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-11=$TOTAL_AGE_6165" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-02-12=$TOTAL_AGE_66" >> $url/"Forumreport_"$tanggal"_"$condition".log";

#replies umur
mongo kaskus_forum1 --eval "db.thread.find({dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$nin:[$id_fjb]}},{_id:1}).forEach(printjson)"|grep -v Mongo|grep -v connect|cut -d':' -f2|cut -d'(' -f2|cut -d")" -f1 >> $url/"thread_id_"$condition".log"

totalthread=`cat $url/"thread_id_"$condition".log" |wc -l`
jumlahloop=`expr $totalthread \/ 999`
atas=0;
bawah=0;
num=1;
#get data userid
for num in `seq 1 $jumlahloop`;
do

	atas=`expr $num \* 999`;
	bawah=`expr $atas - 998`;
	id=`cat $url/"thread_id_"$condition".log" |sed -n "$bawah,$atas p"|tr '"' "'" | tr '\n' ','|sed -e 's/,$//g'`;
	mongo kaskus_forum1 --eval "db.post.find({thread_id:{\$in:[$id]}},{_id:0,post_userid:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g'  >> $url/"thread_id_temp_"$condition".log"	
done

rm $url/"thread_id_"$condition".log";
#mapping data with age
cat $url/"thread_id_temp_"$condition".log"|grep -v Mongo|grep -v connect|cut -d':' -f2|cut -d' ' -f2|sort|uniq >> $url/"userdistinct_"$condition".log"
totalthread=`cat $url/"userdistinct_"$condition".log" |wc -l`
jumlahloop=`expr $totalthread \/ 999`
num=1;
for num in `seq 1 $jumlahloop`;
do
	atas=`expr $num \* 999`;
	bawah=`expr $atas - 998`;
	id=`cat $url/"userdistinct_"$condition".log"|sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`;
	mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_user;  select dateofbirth from userinfo where userid in($id)" >> $url/"lahir_"$condition".log";

done
rm $url/"thread_id_temp_"$condition".log";
rm  $url/"userdistinct_"$condition".log";

#GET DATA
TOTAL_AGE_15=0;
TOTAL_AGE_1620=0;
TOTAL_AGE_2125=0;
TOTAL_AGE_2630=0;
TOTAL_AGE_3135=0;
TOTAL_AGE_3640=0;
TOTAL_AGE_4145=0;
TOTAL_AGE_4650=0;
TOTAL_AGE_5155=0;
TOTAL_AGE_5660=0;
TOTAL_AGE_6165=0;
TOTAL_AGE_66=0;

#cp $url/"lahir_"$condition".log" $url/"lahir_"$condition"2.log";
for i in `cat $url/"lahir_"$condition".log"|cut -d'-' -f1|sort|uniq -c|sed 's/^ *//' | sed 's/ *$//'|tr ' ' '.'`
do

		total=`echo $i|cut -d'.' -f1`
		tahunlahir=`echo $i|cut -d'.' -f2`

		AGE=`expr $tahun - $tahunlahir`;
		if [ "$AGE" -lt 16 ]
		then
			TOTAL_AGE_15=`expr $TOTAL_AGE_15  + $total`;
		elif [ "$AGE" -ge 16 ] && [ "$AGE" -lt 21 ]
		then
			TOTAL_AGE_1620=`expr $TOTAL_AGE_1620  + $total`;
		elif [ "$AGE" -ge 21 ] && [ "$AGE" -lt 26 ]
		then
			TOTAL_AGE_2125=`expr $TOTAL_AGE_2125  + $total`;
		elif [ "$AGE" -ge 26 ] && [ "$AGE" -lt 31 ]
		then
			TOTAL_AGE_2630=`expr $TOTAL_AGE_2630  + $total`;
		elif [ "$AGE" -ge 31 ] && [ "$AGE" -lt 36 ]
		then
			TOTAL_AGE_3135=`expr $TOTAL_AGE_3135  + $total`;
		elif [ "$AGE" -ge 36 ] && [ "$AGE" -lt 41 ]
		then
			TOTAL_AGE_3640=`expr $TOTAL_AGE_3640  + $total`;
		elif [ "$AGE" -ge 41 ] && [ "$AGE" -lt 46 ]
		then
			TOTAL_AGE_4145=`expr $TOTAL_AGE_4145  + $total`;
		elif [ "$AGE" -ge 46 ] && [ "$AGE" -lt 51 ]
		then
			TOTAL_AGE_4650=`expr $TOTAL_AGE_4650  + $total`;
		elif [ "$AGE" -ge 51 ] && [ "$AGE" -lt 56 ]
		then
			TOTAL_AGE_5155=`expr $TOTAL_AGE_5155  + $total`;
		elif [ "$AGE" -ge 56 ] && [ "$AGE" -lt 61 ]
		then
			TOTAL_AGE_5660=`expr $TOTAL_AGE_5660  + $total`;
		elif [ "$AGE" -ge 61 ] && [ "$AGE" -lt 66 ]
		then
			TOTAL_AGE_6165=`expr $TOTAL_AGE_6165  + $total`;
		elif [ "$AGE" -ge 66 ]
		then
			TOTAL_AGE_66=`expr $TOTAL_AGE_66  + $total`;
		fi

done

#cp $url/"lahir_"$condition".log" $url/lahir_cekindong.log;
rm $url/"lahir_"$condition".log";
echo "KK-$code-DEM-FRM-03-01=$TOTAL_AGE_15" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-02=$TOTAL_AGE_1620" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-03=$TOTAL_AGE_2125" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-04=$TOTAL_AGE_2630" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-05=$TOTAL_AGE_3135" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-06=$TOTAL_AGE_3640" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-07=$TOTAL_AGE_4145" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-08=$TOTAL_AGE_4650" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-09=$TOTAL_AGE_5155" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-10=$TOTAL_AGE_5660" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-11=$TOTAL_AGE_6165" >> $url/"Forumreport_"$tanggal"_"$condition".log";
echo "KK-$code-DEM-FRM-03-12=$TOTAL_AGE_66" >> $url/"Forumreport_"$tanggal"_"$condition".log";





#Klasifikasi user KASKUS di FJB berdasarkan lokasi PROV
mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic; select id_report,name_report from report_info where id_report like 'KK-$code-DEM-FRM-04-ID-%';" >> $url/"prov_req_"$condition".log"
mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic; select id_report,name_report from report_info where id_report like 'KK-$code-DEM-FRM-04-%' and id_report not in (select id_report from report_info where id_report like 'KK-$code-DEM-FRM-04-ID-%');" >> $url/"country_req_"$condition".log"

for i in `cat $url/"prov_req_"$condition".log" |tr '\t' '.' |tr ' ' '_'`
do
	prov=`echo $i|cut -d'.' -f2|tr '_' ' '`;
	kode=`echo $i|cut -d'.' -f1`;
	total=`cat $url/"prov_country_data_"$condition".log" |tr '\t' '.' |cut -d'.' -f1 |grep "^$prov$"|wc -l`;
	echo $kode"="$total >> $url/"Forumreport_"$tanggal"_"$condition".log";
done;
echo "Klasifikasi user KASKUS di FJB berdasarkan lokasi PROV [DONE]"





#Klasifikasi user KASKUS di FJB berdasarkan lokasi Country
for i in `cat $url/"country_req_"$condition".log" |tr '\t' '.' |tr ' ' '_'`
do
	country=`echo $i|cut -d'.' -f2|tr '_' ' '`;
	kode=`echo $i|cut -d'.' -f1`;
	total=`cat $url/"prov_country_data_"$condition".log" |tr '\t' '.' |cut -d'.' -f2 |grep "^$country$"|wc -l`;
	echo $kode"="$total >> $url/"Forumreport_"$tanggal"_"$condition".log";
done;

[ -f $url/"prov_req_"$condition".log" ] && rm $url/"prov_req_"$condition".log"
[ -f $url/"request_country_"$condition".log" ] && rm $url/"request_country_"$condition".log"
[ -f $url/"country_req_"$condition".log" ] && rm $url/"country_req_"$condition".log"
[ -f $url/"distinctuserid_"$condition".log" ] && rm $url/"distinctuserid_"$condition".log"
[ -f $url/"prov_country_data_"$condition".log" ] && rm $url/"prov_country_data_"$condition".log"


echo "Klasifikasi user KASKUS di FJB berdasarkan lokasi Country [DONE]"





#Distribusi thread pada categories di Forum
for i in `mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic;select forum_id,id_report from report_info where id_report like 'KK-$code-FRM-06-%';"|tr '\t' '.'`
do
	kode=`echo $i|cut -d'.' -f2`;
	a=`echo $i|cut -d'.' -f1`;
	forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use forum; select child_list from forum_list where forum_id = $a"`
	mongo kaskus_forum1 --eval "db.thread.count({dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]}})"|grep -v MongoDB |grep -v connect |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"temp_"$condition".log";
	echo $kode"="`cat $url/"temp_"$condition".log"` >> $url/"Forumreport_"$tanggal"_"$condition".log";
	rm  $url/"temp_"$condition".log"
done
echo "Distribusi thread pada categories di Forum  [DONE]"





#Distribusi reply/post thread pada categories di Forum
for i in `mysql -u$username -p$password -h $host_user -s -N -e "use kaskus_statistic;select forum_id,id_report from report_info where id_report like 'KK-$code-FRM-08-%';"|tr '\t' '.'`
do
	kode=`echo $i|cut -d'.' -f2`;
	a=`echo $i|cut -d'.' -f1`
	total_post=0;
	forum_child=`mysql -u$username -p$password -h $host_forum -s -N -e "use kaskus_forum; select child_list from forum_list where forum_id = $a"`
	mongo kaskus_forum1 --eval "db.thread.find({dateline:{\$lte:$tanggal,\$gte:$lastweek},forum_id:{\$in:[$forum_child]},reply_count:{\$gt:0}},{_id:0,reply_count:1,forum_id:1}).forEach(printjson)" |sed 's/\<NumberLong\>//g'| sed 's/[\)(]//g' > $url/"wtb_"$condition".log";
	for i in `cat $url/"wtb_"$condition".log" |grep -v Mongo|grep -v connect|cut -d',' -f2|cut -d':' -f2|cut -d' ' -f2`
	do
		 total_post=`expr $total_post + $i`;
	done
	echo $kode"="$total_post >> $url/"Forumreport_"$tanggal"_"$condition".log";
done
echo "Distribusi reply/post thread pada categories di Forum [DONE] in" date
echo "DONE ALL"

rm $url/"wtb_"$condition".log";
echo "Finish on :"; date

. /home/rully/data_analityc/test/statistic_monthly.sh $condition


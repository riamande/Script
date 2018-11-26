startdate=`date +%s`
datapath=/home/rully/temp_data
active_date=`date --date='3 months ago' +%s`
last_kpdonat=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select max(dateline) from kp_donat;"`

mysql -h 172.20.0.77 -upercona -pkaskus2014 test -e "create table userdonatur (userid int(11) primary key);"
mysql -h 172.20.0.252 -ureport -preportkaskus test -e "create table userdonatur (userid int(11) primary key);"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "create table userdonatur_sell_pasif (userid int(11) primary key);"

rm $datapath/userdonatur_sell_pasif.txt $datapath/sellerpkt_* $datapath/selleraktifpkt_*
rm $datapath/kp_donat.csv
rm $datapath/donatur_pk? $datapath/donatur_pk??

mysql -h 172.85.0.252 -ureport -preportkaspay kp_prod --batch -N -e "select a.datetransaction, REPLACE(a.message, '\n', '') from kaspay_users u inner join kaspay_account a on u.uaccount = a.uaccount where a.uaccount <> '39752111' and (a.message like '%AKTB%') and a.datetransaction>= '$last_kpdonat' order by a.datetransaction;" |sed -e 's$\t$,$g' > $datapath/kp_donat_diff.txt
cat $datapath/kp_donat_diff.txt |grep "1 Bulan" > $datapath/kp_donat-1.txt
cat $datapath/kp_donat_diff.txt |grep "3 Bulan" > $datapath/kp_donat-3.txt
cat $datapath/kp_donat_diff.txt |grep "6 Bulan" > $datapath/kp_donat-6.txt
cat $datapath/kp_donat_diff.txt |grep "1 Tahun" > $datapath/kp_donat-12.txt

for j in `ls $datapath |grep kp_donat-`
do
bln=`echo $j |sed 's/[^0-9]*//g'`
for ((i=1;i<=`cat $datapath/$j |wc -l`;i++))
do
a=`cat $datapath/$j |sed -n $i'p' |cut -d',' -f1`
b=`cat $datapath/$j |sed -n $i'p' |cut -d',' -f2,3,4,5 |cut -d':' -f2 |sed 's/[^0-9]*//g'`
echo $a,'"'$bln'"','"'$b'"' >> $datapath/kp_donat.csv
done
done

mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -upercona -pkaskus2014 -h 172.20.0.73 test $datapath/kp_donat.csv


mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where usergroupid=16;" > $datapath/userdonatur.txt
totaldonatur=`cat $datapath/userdonatur.txt |wc -l`
echo "total donatur = $totaldonatur "

mysqlimport -h 172.20.0.77 -upercona -pkaskus2014 --local test $datapath/userdonatur.txt

mysql -h 172.20.0.77 -upercona -pkaskus2014 kaspoints -r -s -N -e "select a.userid from subscriptionlog a,test.userdonatur b where a.userid=b.userid and a.expirydate > $startdate ;" > $datapath/userdonatur.txt
totaldonattracked=`cat $datapath/userdonatur.txt |wc -l`
totaldonatuntracked=`expr $totaldonatur - $totaldonattracked`
echo "total donatur tracked = $totaldonattracked "
echo "total donatur untracked = $totaldonatuntracked "

for k in `cat $datapath/userdonatur.txt`
do
mongo kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[25,662,690,221,220,589,283,686,687,615,616,227,264,625,200,266,265,329,195,313,255,254,196,216,302,310,660,657,658,659,311,215,257,197,218,219,296,679,681,680,682,151,210,527,574,381,573,212,286,287,448,288,202,553,631,269,268,284,603,285,293,605,294,604,683,298,299,305,447,446,198,261,231,262,444,606,233,291,590,292,676,300,312,317,326,320,322,330,328,318,323,327,321,324,325,319,303,314,201,228,607,199,223,225,222,229,588,614,316,610,611,205,208,334,209,333,206,207,256,593,295,608,609,304,297,612,613,677]},post_userid:'$k',prefix_id:{\$in:['WTS','wts']}})" |grep -v MongoDB |grep -v connecting > $datapath/ttl_wts_thread.txt
ttl_wts_thread=`cat $datapath/ttl_wts_thread.txt`
if [ $ttl_wts_thread -gt 4 ]
then
echo $k >> $datapath/userdonatur_sell_pasif.txt
fi
done

userdonatur_pasif=`cat $datapath/userdonatur_sell_pasif.txt |wc -l`

mysqlimport -h 172.20.0.73 -upercona -pkaskus2014 --local test $datapath/userdonatur_sell_pasif.txt

userdonatur_active=`mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select count(*) from userlogin a,test.userdonatur_sell_pasif b where a.userid=b.userid and lastlogin>=$active_date;"`
mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select a.userid from userlogin a,test.userdonatur_sell_pasif b where a.userid=b.userid and lastlogin>=$active_date;" > $datapath/userdonatur_sell_aktif.txt

for l in `cat $datapath/userdonatur_sell_pasif.txt`
do

counter_api=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.count({user_id:$l,processname:/donating/},{_id:0,date:1})" |grep -v MongoDB |grep -v connecting`
counter_kp=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select count(*) from kp_donat where userid=$l;"`

if [ $counter_api -gt 0 ]
then
api_date=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.find({user_id:$l,processname:/donating/},{_id:0,date:1}).sort({_id:-1}).limit(1).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d'"' -f4 |cut -d' ' -f1 |sed 's/[^0-9]*//g'`
else
api_date=0
fi

if [ $counter_kp -gt 0 ]
then
kp_date=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select max(dateline) from kp_donat where userid=$l;" |cut -d' ' -f1 |sed 's/[^0-9]*//g'`
else
kp_date=0
fi

if [ $api_date -gt $kp_date ]
then
seller_pkt=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.find({user_id:$l,processname:/donating/},{_id:0,description:1}).sort({_id:-1}).limit(1).forEach(printjson)" |grep -v MongoDB |grep -v connecting |sed 's/[^0-9]*//g'`
elif [ $kp_date -gt $api_date ]
then
seller_pkt=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select paket from kp_donat where userid=$l order by dateline desc limit 1;"`
fi

echo $l >> $datapath/sellerpkt_"$seller_pkt".txt
done


for m in `cat $datapath/userdonatur_sell_aktif.txt`
do

counter_api=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.count({user_id:$m,processname:/donating/},{_id:0,date:1})" |grep -v MongoDB |grep -v connecting`
counter_kp=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select count(*) from kp_donat where userid=$m;"`

if [ $counter_api -gt 0 ]
then
api_date=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.find({user_id:$m,processname:/donating/},{_id:0,date:1}).sort({_id:-1}).limit(1).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d'"' -f4 |cut -d' ' -f1 |sed 's/[^0-9]*//g'`
else
api_date=0
fi

if [ $counter_kp -gt 0 ]
then
kp_date=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select max(dateline) from kp_donat where userid=$m;" |cut -d' ' -f1 |sed 's/[^0-9]*//g'`
else
kp_date=0
fi

if [ $api_date -gt $kp_date ]
then
seller_pkt=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.find({user_id:$m,processname:/donating/},{_id:0,description:1}).sort({_id:-1}).limit(1).forEach(printjson)" |grep -v MongoDB |grep -v connecting |sed 's/[^0-9]*//g'`
elif [ $kp_date -gt $api_date ]
then
seller_pkt=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select paket from kp_donat where userid=$m order by dateline desc limit 1;"`
fi

echo $m >> $datapath/selleraktifpkt_"$seller_pkt".txt
done

echo "total donatur seller pasif = $userdonatur_pasif"
echo "total donatur seller pasif = $userdonatur_active"

mysqlimport -h 172.20.0.252 -ureport -preportkaskus --local test $datapath/userdonatur.txt

#for i in `mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -r -s -N -e "select distinct a.userid from transaksi a,test.userdonatur b where a.userid=b.userid and #a.trxid != '' and a.status = 1 ;"`
#do
#mindate=`mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -r -s -N -e "select min(dateline) from transaksi where userid=$i and trxid != '' and status = 1 ;"`
#curdate=$mindate
#for j in `mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -r -s -N -e "select (if(packetid='1',1,if(packetid=2,3,if(packetid=3,6,if(packetid=4,12,0)))) * 2592000) as #paket from transaksi where userid=$i and trxid != '' and status = 1 order by dateline asc;"`
#do
#curdate=`expr $curdate + $j`
#if [ $curdate -gt $startdate ]
#then
#pkdonat=`expr $j / 2592000`
#echo $i >> $datapath/donatur_pk"$pkdonat"
#break
#fi
#done
#done

for l in `cat $datapath/userdonatur.txt`
do

counter_api=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.count({user_id:$l,processname:/donating/},{_id:0,date:1})" |grep -v MongoDB |grep -v connecting`
counter_kp=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select count(*) from kp_donat where userid=$l;"`

if [ $counter_api -gt 0 ]
then
api_date=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.find({user_id:$l,processname:/donating/},{_id:0,date:1}).sort({_id:-1}).limit(1).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d'"' -f4 |cut -d' ' -f1 |sed 's/[^0-9]*//g'`
else
api_date=0
fi

if [ $counter_kp -gt 0 ]
then
kp_date=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select max(dateline) from kp_donat where userid=$l;" |cut -d' ' -f1 |sed 's/[^0-9]*//g'`
else
kp_date=0
fi

if [ $api_date -gt $kp_date ]
then
seller_pkt=`mongo 172.20.0.91/kaskus_user_log --eval "db.user_account_activity_log.find({user_id:$l,processname:/donating/},{_id:0,description:1}).sort({_id:-1}).limit(1).forEach(printjson)" |grep -v MongoDB |grep -v connecting |sed 's/[^0-9]*//g'`
elif [ $kp_date -gt $api_date ]
then
seller_pkt=`mysql -h 172.20.0.73 -upercona -pkaskus2014 test -r -s -N -e "select paket from kp_donat where userid=$l order by dateline desc limit 1;"`
fi

echo $l >> $datapath/donatur_pk"$seller_pkt"
done


mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "create table donatur_pk1 (userid int(11) primary key);"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "create table donatur_pk3 (userid int(11) primary key);"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "create table donatur_pk6 (userid int(11) primary key);"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "create table donatur_pk12 (userid int(11) primary key);"

mysqlimport -h 172.20.0.73 -upercona -pkaskus2014 --local test $datapath/donatur_pk1
mysqlimport -h 172.20.0.73 -upercona -pkaskus2014 --local test $datapath/donatur_pk3
mysqlimport -h 172.20.0.73 -upercona -pkaskus2014 --local test $datapath/donatur_pk6
mysqlimport -h 172.20.0.73 -upercona -pkaskus2014 --local test $datapath/donatur_pk12

mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select a.province,count(*) from userinfo a, test. donatur_pk1 b where a.userid=b.userid group by a.province order by count(*) desc ;" > $datapath/donatur_pk1_location.csv
mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select a.province,count(*) from userinfo a, test. donatur_pk3 b where a.userid=b.userid group by a.province order by count(*) desc ;" > $datapath/donatur_pk3_location.csv
mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select a.province,count(*) from userinfo a, test. donatur_pk6 b where a.userid=b.userid group by a.province order by count(*) desc ;" > $datapath/donatur_pk6_location.csv
mysql -h 172.20.0.73 -upercona -pkaskus2014 user -r -s -N -e "select a.province,count(*) from userinfo a, test. donatur_pk12 b where a.userid=b.userid group by a.province order by count(*) desc ;" > $datapath/donatur_pk12_location.csv

mysql -h 172.20.0.77 -upercona -pkaskus2014 test -e "drop table userdonatur;"
mysql -h 172.20.0.252 -ureport -preportkaskus test -e "drop table userdonatur;"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "drop table userdonatur_sell_pasif;"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "drop table donatur_pk1;"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "drop table donatur_pk3;"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "drop table donatur_pk6;"
mysql -h 172.20.0.73 -upercona -pkaskus2014 test -e "drop table donatur_pk12;"



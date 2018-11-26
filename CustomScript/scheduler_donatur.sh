tgl_1week=`date +%s -d "1 week ago"`
tgl_2week=`date +%s -d "2 weeks ago"`
tanggalan=`date +%d-%m-%Y`
rm list_renew_donat.txt
mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -s -N -e "select distinct userid from transaksi where dateline>=$tgl_1week and status=1;" > list_new_donat.txt

paket1=`mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tgl_1week and status=1 and packetid=1;"`
paket2=`mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tgl_1week and status=1 and packetid=2;"`
paket3=`mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tgl_1week and status=1 and packetid=3;"`
paket4=`mysql -h 172.20.0.252 -ureport -preportkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tgl_1week and status=1 and packetid=4;"`
paket5=`mysql -h 172.20.0.73 -upercona -pkaskus2014 user -s -N -e "select count(*) from userinfo where usergroupid=16;"`

for i in `cat list_new_donat.txt`
do
mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select distinct userid from transaksi where dateline<=$tgl_1week and status=1 and userid=$i ;" >> list_renew_donat.txt
done

ttl_all=`cat list_new_donat.txt |wc -l`
ttl_renew=`cat list_renew_donat.txt |wc -l`
ttl_new=`expr $ttl_all - $ttl_renew`
untung=`expr $paket1 \* 30000 + $paket2 \* 80000 + $paket3 \* 150000 + $paket4 \* 300000`

ttl_this_week=`mysql -upercona -pkaskus2014 -h 172.20.0.73 user -s -N -e "select count(*) from userinfo where joindate>=$tgl_1week;"`
ttl_last_week=`mysql -upercona -pkaskus2014 -h 172.20.0.73 user -s -N -e "select count(*) from userinfo where joindate>=$tgl_2week and joindate<=$tgl_1week;"`
selisih=`expr $ttl_this_week - $ttl_last_week |tr -d -`


sendemail -f statistic@kaskusnetworks.com -t riamande.tambunan@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com,ardy.alam@kaskusnetworks.com,resty.fauziah@kaskusnetworks.com,hilda@kaskusnetworks.com  -u "WEEKLY STATISTIC" -m "STATISTIC PER $tanggalan : \n\n\n New Donatur = $ttl_new \n Donatur Renew = $ttl_renew \n Total Income = $untung \n Total Registered Users (this week) = $ttl_this_week \n Total Registered Users (last week) = $ttl_last_week \n Total Registered Users (difference) = $selisih \n Total Donator = $paket5 \n\n\n\n Regards, \n DBA" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

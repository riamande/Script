tglstart=`date -d $1 +%s`
tglend=`date -d $2 +%s`
total_uniq=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select distinct userid from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1;" |wc -l`

paket1=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=1;"`
paket2=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=2;"`
paket3=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=3;"`
paket4=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select count(*) from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=4;"`


total_renew=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select userid,count(*) from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 group by userid having count(userid)>1;" |wc -l`

untung=`expr $paket1 \* 30000 + $paket2 \* 80000 + $paket3 \* 150000 + $paket4 \* 300000`

echo paket1 = $paket1
echo paket2 = $paket2
echo paket3 = $paket3
echo paket4 = $paket4
echo income = $untung
echo total donatur = $total_uniq
echo total renew = $total_renew

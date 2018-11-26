for i in `mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select trxid from transaksi where dateline>=1388509200 and dateline<=1420045200 and status=1 and packetid=$1;"`
do
mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "delete from kaspay_trxid where trxid='$i';"
done

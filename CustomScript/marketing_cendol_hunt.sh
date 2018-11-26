############# Data Peserta Ramadan Cendol Hunt #############
DATE_END_STR=`date +%Y%m%d`
DATE_START_TS="1526662800"
DATE_END_TS=`date -d"$DATE_END_STR" +%s`
DATE_FILE_START=`date -d@$DATE_START_TS +"%Y-%m-%d"`
DATE_FILE_END=`date -d "yesterday" +"%Y-%m-%d"`
DATADIR="/home/rully/marketing_req"

mysql -h 172.20.0.73 -upercona -pkaskus2014 -e "select username, FROM_UNIXTIME(a.dateline,'%Y-%m-%d') tanggal from forum.forum_reputation a,user.userlogin b where a.user_id=b.userid and a.whoadded in (10176496,10215790) AND a.dateline >= $DATE_START_TS AND a.dateline < $DATE_END_TS group by a.user_id,FROM_UNIXTIME(a.dateline,'%Y-%m-%d') order by FROM_UNIXTIME(a.dateline,'%Y-%m-%d') desc;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $DATADIR/participant_cendol_hunt_daily.csv

mysql -h 172.20.0.73 -upercona -pkaskus2014 -e "select username,(count(*) * 10) total_cendol from (select a.user_id,username, FROM_UNIXTIME(a.dateline,'%Y-%m-%d') tanggal from forum.forum_reputation a,user.userlogin b where a.user_id=b.userid and a.whoadded in (10176496,10215790) AND a.dateline >= $DATE_START_TS AND a.dateline < $DATE_END_TS group by a.user_id,FROM_UNIXTIME(a.dateline,'%Y-%m-%d')) cendol group by username order by total_cendol desc;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $DATADIR/cendol_acquired_per_participant.csv

TOT_ALL=`cat $DATADIR/cendol_acquired_per_participant.csv |wc -l`
TOT_GIVEN=`cat $DATADIR/participant_cendol_hunt_daily.csv |wc -l`
TOTAL_UNIQUE_USER=`expr $TOT_ALL - 1`
TOTAL_CENDOL=`expr $TOT_GIVEN \* 10 - 10`
############# END OF THE CODE #############

sendemail -f statistic@kaskusnetworks.com -t zarona@kaskusnetworks.com,agnes.revian@kaskusnetworks.com,rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com,db@kaskusnetworks.com -u "Data Peserta Ramadan Cendol Hunt" -m "Dear Mbak Izar, \n\n Berikut data participant RAMADHAN CENDOL HUNT dari $DATE_FILE_START s/d $DATE_FILE_END \n Total Unique User = $TOTAL_UNIQUE_USER \n Total Cendol Sent = $TOTAL_CENDOL \n\n AUTO GENERATED CONTENT \n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATADIR/participant_cendol_hunt_daily.csv $DATADIR/cendol_acquired_per_participant.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

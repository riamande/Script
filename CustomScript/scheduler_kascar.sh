periode_run="$1" # value= daily/weekly/monthly
datadir="/home/rully/garasi_report"
destdir="/home/rully/kpi_garasi"

if [ $periode_run = 'daily' ]
then
DATESTART_STR=`date -d "-1 day" +%Y%m%d`
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
#DATESTART_STR=`date -d "$DATEEND_STR - 1 day" +%Y%m%d`
START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR daily
!
#mongo SG-KaskusCarProduction-10223.servers.mongodirector.com/kaskus_car -u admin -pyO0BNafuud5G1qYC --authenticationDatabase=admin --eval "db.vehicles.aggregate([ {\$match: {status:'sold',sold_at:{\$gte: new Date($start_date),\$lt: new Date($end_date)}}}, {\$project:{tanggal:{\$dateToString: { format: '%Y-%m-%d', date: '\$sold_at' }}}}, {\$group:{_id:'\$tanggal', count:{\$sum:1}}},{\$sort:{_id:1}} ]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d ' ' -f4,7 |sed 's/ /"/g;s/$/"/g' > $datadir/garasi_sold_"$DATESTART_STR".csv

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/garasi_sold_"$DATESTART_STR".csv
bye
!
mv garasi_sold_"$DATESTART_STR".csv $destdir/garasi_sold_"$DATESTART_STR".csv
cat $destdir/garasi_sold_"$DATESTART_STR".csv > $destdir/garasi_sold.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/garasi_sold.csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,riza.putri@garasi.id,hartono.sulaiman@kaskusnetworks.com,antonia.kalisa@kaskusnetworks.com,galih.agung@kaskusnetworks.com,irwan.mulyawan@kaskusnetworks.com,sandy.soesilo@garasi.id -u "[DAILY] GARASI SOLD $DATESTART_STR" -m "STATISTIC PER $DATESTART_STR \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/garasi_sold_"$DATESTART_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[DAILY] GARASI SOLD $DATESTART_STR" -m "STATISTIC PER $DATESTART_STR \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/garasi_sold_"$DATESTART_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

#sendemail -f statistic@kaskusnetworks.com -t antonia.kalisa@kaskusnetworks.com,Shella.kharimah@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY KASADS" -m "STATISTIC PER $DATESTART_STR s/d $ENDDATE_MOD \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a kasads_weekly_"$DATEEND_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi

if [ $periode_run = 'daily_summary' ]
then
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
DATESTART_STR=`date -d "$DATEEND_STR - 1 day" +%Y%m%d`
START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR daily_summary
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/daily_summary.csv
bye
!
mv daily_summary.csv $destdir/daily_summary.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/daily_summary.csv
fi

if [ $periode_run = 'weekly' ]
then
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
DATESTART_STR=`date -d "$DATEEND_STR - 7 day" +%Y%m%d`
START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR weekly
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/weekly_summary_"$DATESTART_STR".csv
bye
!
mv weekly_summary_"$DATESTART_STR".csv $destdir/weekly_summary_"$DATESTART_STR".csv
cat $destdir/weekly_summary_"$DATESTART_STR".csv > $destdir/weekly_summary.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/weekly_summary.csv
fi

# Raw data listing
if [ $periode_run = 'halfmonthly' ]
then
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
CUR_DAY=`date -d "$DATEEND_STR" +%d`

#if [ "$CUR_DAY" = "16" ]
#then
#DATESTART_STR=`date -d "$DATEEND_STR" +"%Y%m01"`
if [ "$CUR_DAY" = "01" ]
then
#DATESTART_STR=`date -d "$DATEEND_STR - 1 day" +"%Y%m16"`
DATESTART_STR=`date -d "$DATEEND_STR - 1 month" +"%Y%m%d"`
fi

START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR halfmonthly
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/sold_kascar.csv
get $datadir/approved_kascar.csv
bye
!

mv sold_kascar.csv $destdir/sold_kascar.csv
mv approved_kascar.csv $destdir/approved_kascar.csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,riza.putri@garasi.id,galih.agung@kaskusnetworks.com,irwan.mulyawan@kaskusnetworks.com -u "[MONTHLY] GARASI RAW LISTING AND SOLD" -m "RAW DATA PER $DATESTART_STR to $DATEEND_STR \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/sold_kascar.csv $destdir/approved_kascar.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[MONTHLY] GARASI RAW LISTING AND SOLD" -m "RAW DATA PER $DATESTART_STR to $DATEEND_STR \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/sold_kascar.csv $destdir/approved_kascar.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi

if [ $periode_run = 'active_seller' ]
then
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
DATESTART_STR=`date -d "$DATEEND_STR - 30 day" +%Y%m%d`
START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR active_seller
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/active_seller_dashboard.csv
bye
!
mv active_seller_dashboard.csv $destdir/active_seller_dashboard.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/active_seller_dashboard.csv
fi

if [ $periode_run = 'listing_source' ]
then
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
DATESTART_STR=`date -d "$DATEEND_STR - 1 day" +%Y%m%d`
START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR listing_source
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/listing_source.csv
bye
!
mv listing_source.csv $destdir/listing_source.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/listing_source.csv
fi


if [ $periode_run = 'car_recommendation' ]
then
date_name=`date +"%Y-%m-%d"`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh 0 0 0 car_recommendation
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/recommendation_car_email.csv
get $datadir/recommendation_car_handphone.csv
bye
!

mv recommendation_car_email.csv $destdir/recommendation_car_email.csv
mv recommendation_car_handphone.csv $destdir/recommendation_car_handphone.csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com,db@kaskusnetworks.com,irwan.mulyawan@garasi.id,yanuar.suhardiman@garasi.id,ayu.wardhani@garasi.id,ferania.prasetyanti@garasi.id,sandy.tirtokusumo@garasi.id,sandy.soesilo@garasi.id,riza.putri@garasi.id  -u "DAILY SALES LEADS" -m "STATISTIC CAR RECOMMENDATION  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/recommendation_car_email.csv $destdir/recommendation_car_handphone.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "DAILY CAR RECOMMENDATION" -m "STATISTIC CAR RECOMMENDATION  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/recommendation_car_email.csv $destdir/recommendation_car_handphone.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi


if [ $periode_run = 'mobil_pilihan' ]
then
date_name=`date +"%Y-%m-%d"`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh 0 0 0 mobil_pilihan
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/mobil_pilihan_email.csv
get $datadir/mobil_pilihan_handphone.csv
bye
!

mv mobil_pilihan_email.csv $destdir/mobil_pilihan_email.csv
mv mobil_pilihan_handphone.csv $destdir/mobil_pilihan_handphone.csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com,db@kaskusnetworks.com,irwan.mulyawan@garasi.id,sandy.soesilo@garasi.id  -u "DAILY MOBIL PILIHAN LEADS" -m "STATISTIC MOBIL PILIHAN  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/mobil_pilihan_email.csv $destdir/mobil_pilihan_handphone.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t riamande.tambunan@kaskusnetworks.com  -u "DAILY MOBIL PILIHAN LEADS" -m "STATISTIC MOBIL PILIHAN  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/mobil_pilihan_email.csv $destdir/mobil_pilihan_handphone.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi

if [ $periode_run = 'jual_kilat' ]
then
DATEEND_STR=`date +%Y%m%d`
#DATEEND_STR="$2"
DATESTART_STR=`date -d "$DATEEND_STR - 1 day" +%Y%m%d`
START_DATE_TIMESTAMP=`date -d "$DATESTART_STR - 7 hour" +%s`
END_DATE_TIMESTAMP=`date -d "$DATEEND_STR - 7 hour" +%s`
start_date=`expr $START_DATE_TIMESTAMP \* 1000`
end_date=`expr $END_DATE_TIMESTAMP \* 1000`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh $start_date $end_date $DATESTART_STR jual_kilat
!

sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/report_jual_kilat.csv
get $datadir/total_penawaran.csv
bye
!
mv report_jual_kilat.csv $destdir/report_jual_kilat.csv
mv total_penawaran.csv $destdir/total_penawaran.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/report_jual_kilat.csv
mysqlimport --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" --local -h kk-db-dba.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -ukaskusdba -pkkdba2143 garasi_report $destdir/total_penawaran.csv
fi


if [ $periode_run = 'chat_showroom' ]
then
date_name=`date +"%Y-%m-%d"`
DATESTART_STR=`date -d '7 day ago' +%d%m%y`'_'`date -d "yesterday" +%d%m%y`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh 0 0 $DATESTART_STR chat_showroom
!
sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/chat_showroom_"$DATESTART_STR".csv
bye
!
mv chat_showroom_"$DATESTART_STR".csv $destdir/chat_showroom_"$DATESTART_STR".csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com,db@kaskusnetworks.com,irwan.mulyawan@garasi.id,sandy.soesilo@garasi.id,sandy.tirtokusumo@garasi.id,ferania.prasetyanti@garasi.id,mohammad.noufal@garasi.id  -u "[WEEKLY] Chat_Showrooms" -m "STATISTIC CHAT SHOWROOM  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/chat_showroom_"$DATESTART_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

#sendemail -f statistic@kaskusnetworks.com -t riamande.tambunan@kaskusnetworks.com  -u "[WEEKLY] Chat_Showrooms" -m "STATISTIC CHAT SHOWROOM  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/chat_showroom_"$DATESTART_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi



if [ $periode_run = 'call_showroom' ]
then
date_name=`date +"%Y-%m-%d"`
DATESTART_STR=`date -d '7 day ago' +%d%m%y`'_'`date -d "yesterday" +%d%m%y`
ssh -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
/home/rully/garasi_cron.sh 0 0 $DATESTART_STR call_showroom
!
sftp -i /home/rully/.ssh/rully88 rully@13.250.159.41 << !
get $datadir/call_showroom_"$DATESTART_STR".csv
bye
!
mv call_showroom_"$DATESTART_STR".csv $destdir/call_showroom_"$DATESTART_STR".csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com,db@kaskusnetworks.com,irwan.mulyawan@garasi.id,sandy.soesilo@garasi.id,sandy.tirtokusumo@garasi.id,ferania.prasetyanti@garasi.id,mohammad.noufal@garasi.id  -u "[WEEKLY] Call_Showrooms" -m "STATISTIC CALL SHOWROOM  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/call_showroom_"$DATESTART_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[WEEKLY] Call_Showrooms" -m "STATISTIC CALL SHOWROOM  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $destdir/call_showroom_"$DATESTART_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
fi

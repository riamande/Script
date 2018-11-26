MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
datadir="/home/rully/kpi_report"
start_date=`date +%Y%m%d`
> $datadir/bot_subscriber.csv
for i in `mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.253 kaskus_microsite -r -s -N -e "show tables like '%subscribers%';"`
do
a=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.253 kaskus_microsite -r -s -N -e "select count(*) from $i;"`
echo '"'$i'","'$a'"' >> $datadir/bot_subscriber.csv
done
sendemail -f statistic@kaskusnetworks.com -t hans.lesmana@kaskusnetworks.com,irwan.mulyawan@kaskusnetworks.com,jurnalistika.ariella@kaskusnetworks.com,rully@kaskusnetworks.com,db@kaskusnetworks.com -u "MONTHLY SUBSCRIBER" -m "TOTAL Official Account Subscriber PER $start_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/bot_subscriber.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

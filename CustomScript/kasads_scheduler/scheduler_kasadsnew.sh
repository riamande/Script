DATESTART_STR=`date +%Y%m'01'`
DATEEND_STR=`date +%Y%m%d`
#DATESTART_STR="20170601"
#DATEEND_STR="20170606"
DATESTART_T=`date -d "$DATESTART_STR" "+%Y-%m-%d %T"`
DATEEND_T=`date -d "$DATEEND_STR" "+%Y-%m-%d %T"`
ENDDATE_MOD=`date -d "$DATEEND_STR 1 day ago" +%Y%m%d`
cd /home/rully/kasads_scheduler/
ssh -i /home/rully/KK_INFRA_SG.pem ec2-user@52.220.152.10 << !
mysql -h kk-kad-production-db.civaxibhuqmv.ap-southeast-1.rds.amazonaws.com -u kadProduction -pkadProductionPass dmiKadRdsProduction -e "SELECT  @start_date := '$DATESTART_T', @end_date := '$DATEEND_T';SELECT u.username, u.userid, o.id as order_id, c.title, c.description, c.url, l.creation_date_time as date, l.budget, l.status, t.payment_method FROM users u, order_ads o, line_item l, creative c, lica lc, transactions t WHERE CONCAT(t.ref_no,'/',t.id) = o.po_number AND u.userid = o.advertiser_id AND l.order_ads_id = o.id AND l.id = lc.line_item_id AND c.id = lc.creative_id AND l.creation_date_time >= @start_date AND l.creation_date_time < @end_date GROUP BY o.id;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > kasads_weekly_"$DATEEND_STR".csv
!

sftp -i /home/rully/KK_INFRA_SG.pem ec2-user@52.220.152.10 << !
get kasads_weekly_"$DATEEND_STR".csv
bye
!

sendemail -f statistic@kaskusnetworks.com -t antonia.kalisa@kaskusnetworks.com,Shella.kharimah@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY KASADS" -m "STATISTIC PER $DATESTART_STR s/d $ENDDATE_MOD \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a kasads_weekly_"$DATEEND_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t antonia.kalisa@kaskusnetworks.com,Shella.kharimah@kaskusnetworks.com,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY KASADS" -m "STATISTIC PER $DATESTART_STR s/d $ENDDATE_MOD \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a kasads_weekly_"$DATEEND_STR".csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

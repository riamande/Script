datadir="/home/rully/data_thread_share/daily"
date_end=`date -d "- 1 day" +%Y%m%d`
end_date=`date -d "$date_end" +%s`
start_date=`date -d "$date_end - 1 day" +%s`
date_onfile=`date -d@$start_date +%Y%m%d`

/opt/mongodb_3.0.10/bin/mongo 172.20.0.242/kaskus_forum1 -ukkreplrw5 -p3xTYNeE6Ky5ahby5 --authenticationDatabase=auth_db --eval "rs.slaveOk();db.thread_warehouse.find({plagiarism_status:1,current_status:2,dateline:{\$gte:$start_date,\$lt:$end_date}},{_id:0,thread_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $datadir/thread_creator.csv
cat $datadir/thread_creator.csv |cut -d '"' -f4 > $datadir/thread_creator.txt
sed -i 's@^@https://www.kaskus.co.id/thread/@g' $datadir/thread_creator.txt
sed -i 's@^@"@g;s@$@"@g' $datadir/thread_creator.txt
mv $datadir/thread_creator.txt $datadir/thread_creator.csv

sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,marsha.septiani@kaskusnetworks.com,amelia@kaskusnetworks.com -u "[DAILY] THREAD CREATOR" -m "RAW DATA PER $date_onfile \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/thread_creator.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[DAILY] THREAD CREATOR" -m "RAW DATA PER $date_end \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $datadir/thread_creator.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

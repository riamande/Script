condition="$1"
tanggal="$2"
lastweek="$3"
#if [ "$condition" = "week" ]
#then
#rangetype=`date -d '1 week ago' "+%s"`
#elif [ "$condition" = "month" ]
#then
#rangetype=`date -d '1 month ago' "+%s"`
#fi

#tanggal=`date "+%s"`
tanggal_date=`date -d @$tanggal "+%Y-%m-%d %H:%M:%S"`
rangeweek=`expr 3600 \* 24 \* 7`
#lastweek="$rangetype"
lastweek_date=`date -d @$lastweek "+%Y-%m-%d %H:%M:%S"`
kaskus_misc="172.20.0.91"
temp_mongo_script="/home/rully"
MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
reportweek="/home/rully/reportweekly"

#tanggal=1461258001
for ((i=1;i=1;i=1))
do
countfile=`cat $temp_mongo_script/"$condition"_filesummary.log |wc -l`
echo $countfile
echo $tanggal
if [ $countfile = 5 ]
then
for j in `cat $temp_mongo_script/"$condition"_filesummary.log`
do
cat $j >> $reportweek/"$condition"_report_"$tanggal".txt
done
sendemail -f statistic@kaskusnetworks.com -t hilda@kaskusnetworks.com,sista.wulandari@kaskusnetworks.com,zarona@kaskusnetworks.com,elsa@kaskusnetworks.com,taofik.saleh@kaskusnetworks.com,rio.odang@kaskusnetworks.com,rae.mandela@kaskusnetworks.com,ecky.putrady@gdplabs.id,farman.kosim@gdplabs.id,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER $lastweek_date s/d $tanggal_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $reportweek/"$condition"_report_"$tanggal".txt -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t hilda@kaskusnetworks.com,sista.wulandari@kaskusnetworks.com,zarona@kaskusnetworks.com,elsa@kaskusnetworks.com,taofik.saleh@kaskusnetworks.com,rio.odang@kaskusnetworks.com,rae.mandela@kaskusnetworks.com,ecky.putrady@gdplabs.id,weiping.mandrawa@kaskusnetworks.com,farman.kosim@gdplabs.id,glen@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER 2016-04-15 00:00:01 s/d 2016-04-22 00:00:01 \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $reportweek/"$condition"_report_"$tanggal".txt -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sleep 20
mv $temp_mongo_script/"$condition"_filesummary.log $temp_mongo_script/"$condition"_filesummary.temp
break
fi
sleep 300
done




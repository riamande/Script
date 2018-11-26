echo "... Importing to database ...";
rangetype="$1"
if [ "$rangetype" = "week" ]
then
typereport="W"
elif [ "$rangetype" = "month" ]
then
typereport="M"
fi

for i in `more $url/"Fjbreport_"$tanggal"_"$condition".log"`
do 
	kode=`echo $i|cut -d'=' -f1`;
	hasil=`echo $i|cut -d'=' -f2`;
	mysql -u$username -p$password  -h $host_user -e "use kaskus_statistic; insert into general_report(id_report,total_data,start_date,last_date) values('$kode','$hasil','$tanggal','$lastweek')"
done


for i in `more $url/"Forumreport_"$tanggal"_"$condition".log"`
do 
	kode=`echo $i|cut -d'=' -f1`;
	hasil=`echo $i|cut -d'=' -f2`;
	mysql -u$username -p$password  -h $host_user -e "use kaskus_statistic; insert into general_report(id_report,total_data,start_date,last_date) values('$kode','$hasil','$tanggal','$lastweek')"
done


for i in `more $url/"Demographic_"$tanggal"_"$condition".log"`
do
	kode=`echo $i|cut -d'=' -f1`;
	hasil=`echo $i|cut -d'=' -f2`;
	mysql -u$username -p$password  -h $host_user -e "use kaskus_statistic; insert into general_report(id_report,total_data,start_date,last_date) values('$kode','$hasil','$tanggal','$lastweek')"
done

echo "... Export to Excel ...";
mysql -u$username -p$password -h $host_user -e "use kaskus_statistic;select report_info.id_report,report_info.descrtiption_report,report_info.name_report,report_info.type,general_report.total_data from general_report join report_info on general_report.id_report=report_info.id_report where general_report.start_date= $tanggal and general_report.last_date=$lastweek AND report_info.type=\"$typereport\";" > $url/"Report_"$tanggal"_"$condition.csv


sendemail -f statistic@kaskusnetworks.com -t mega.saraswati@kaskusnetworks.com,glen@kaskusnetworks.com,stevi.larasati@kaskusnetworks.com,yesika.manik@kaskusnetworks.com,rully@kaskusnetworks.com,alken@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER $lastweek_date s/d $tanggal_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $url/"Report_"$tanggal"_"$condition.csv -s 172.16.0.5 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t alken@kaskusnetworks.com,rully@kaskusnetworks.com -u "WEEKLY STATISTIC" -m "STATISTIC PER $lastweek_date s/d $tanggal_date \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $url/"Report_"$tanggal"_"$condition.csv -s 172.16.0.5 > /dev/null  2>&

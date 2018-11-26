url="/home/p2-0063/Desktop";
username="percona";
password="percona";
host="10.10.2.218";

for i in `cat $url/month_fjbreport_$tanggal.log |tr ' ' '_'`
do
	kode=`echo $i|cut -d'_' -f1`;
	value=`echo $i|cut -d'_' -f3`;
	mysql -u$username -p$password -h$host -e "use kaskus_statistic;insert into general_report(id_report,total_data,start_date,last_date) values (\"$kode\",\"$value\",\"$tanggal\",\"$lastweek\")";
done

for i in `cat $url/month_forumreport_$tanggal.log |tr ' ' '_'`
do
	kode=`echo $i|cut -d'_' -f1`;
	value=`echo $i|cut -d'_' -f3`;
	mysql -u$username -p$password -h$host -e "use kaskus_statistic;insert into general_report(id_report,total_data,start_date,last_date) values (\"$kode\",\"$value\",\"$tanggal\",\"$lastweek\")";
done

for i in `cat $url/month_demographicreport_$tanggal.log |tr ' ' '_'`
do
	kode=`echo $i|cut -d'_' -f1`;
	value=`echo $i|cut -d'_' -f3`;
	mysql -u$username -p$password -h$host -e "use kaskus_statistic;insert into general_report(id_report,total_data,start_date,last_date) values (\"$kode\",\"$value\",\"$tanggal\",\"$lastweek\")";
done

for i in `cat $url/month_generalreport_$tanggal.log |tr ' ' '_'`
do
	kode=`echo $i|cut -d'_' -f1`;
	value=`echo $i|cut -d'_' -f3`;
	mysql -u$username -p$password -h$host -e "use kaskus_statistic;insert into general_report(id_report,total_data,start_date,last_date) values (\"$kode\",\"$value\",\"$tanggal\",\"$lastweek\")";
done

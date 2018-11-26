data_dir="/home/rully/kpi_report/forum_funnel/daily"
month_naming=`date -d"yesterday" +"%Y-%m"`
file_naming='voters_'$month_naming


start_date=`date +%Y%m01`
akhir=`date  +%Y%m%d`
if [ $start_date -eq $akhir ]
  then
  start_date=`date -d "- 1 month" +%Y%m01`
fi
month_start=`date -d "$start_date" +%s`
date_end=`date -d "$akhir" +%s`
mulai=`date -d "$akhir - 1 day" +%s`
date_name=`date -d@$mulai +%Y-%m-%d`


#user_give_reputation
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum -r -s -N -e "select whoadded from forum_reputation where dateline >= $mulai and dateline < $date_end;" > $data_dir/ugr.temp
user_give_reputation=`cat $data_dir/ugr.temp |sort |uniq |wc -l`

#user_give_vote
mysql -h 172.20.0.73 -uriamande -pchopinnocturne92 forum  -r -s -N -e "select  userid from  forum_poll_vote where votedate >= $mulai and votedate < $date_end;" > $data_dir/ugv.temp
user_give_vote=`cat $data_dir/ugv.temp |sort |uniq |wc -l`

user_voter=`cat $data_dir/ugr.temp $data_dir/ugv.temp |sort |uniq |wc -l`


event_ugr=`cat $data_dir/ugr.temp  |wc -l`
event_ugv=`cat $data_dir/ugv.temp |wc -l`
event_uv=`cat $data_dir/ugr.temp $data_dir/ugv.temp |wc -l`

echo '"'$date_name'","'$user_give_reputation'","'$user_give_vote'","'$user_voter'","'$event_ugr'","'$event_ugv'","'$event_uv'"' > $data_dir/voters_daily.csv

#create table voters_daily (date_created date, user_voters int(11),user_give_reputation int(11), user_give_vote int(11));
mysqlimport --fields-terminated-by=,  --fields-optionally-enclosed-by='"'  --replace --local -h 172.20.0.159 -ubackup -pkaskus  test $data_dir/voters_daily.csv;
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "select * from voters_daily where date_created >='$start_date' and date_created < '$akhir' ;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $data_dir/$file_naming".csv"

bq load kaskus_reporting.voters_daily $data_dir/voters_daily.csv date_created:date,user_voters:integer,user_give_reputation:integer,user_give_vote:integer,event_user_voter:integer,event_user_give_reputation:integer,event_user_give_vote:integer
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,riamande.tambunan@kaskusnetworks.com -u "[DAILY] MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM FUNNEL VOTER PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1
sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com,db@kaskusnetworks.com,romy.husodo@kaskusnetworks.com,medy.priangga@kaskusnetworks.com,ronald.seng@kaskusnetworks.com,maylina.kurniawati@kaskusnetworks.com,lisa@kaskusnetworks.com,seno@kaskusnetworks.com -u "MONTHLY FORUM STATISTIC" -m "STATISTIC FORUM FUNNEL  VOTER  PER $date_name \n\n\n Details information is attached below. \n\n\n\n Regards, \n DBA" -a $data_dir/$file_naming".csv" -o tls=no -s 103.6.117.20 > /dev/null  2>&1

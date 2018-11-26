condition=$1;
echo $condition;
tanggal=`date "+%s"`

if [ $condition = "week" ]
then
	lastweek=`date -d '1 week ago' "+%s"`
	code="W";
elif [ $condition = "month" ]
then
	lastweek=`date -d '1 month ago' "+%s"`
	code="M";
fi

tahun=$(date +"%Y");
echo "Execute on :"; date
tanggal_date=`date -d @$tanggal "+%Y-%m-%d %H:%M:%S"`
lastweek_date=`date -d @$lastweek "+%Y-%m-%d %H:%M:%S"`
url="/home/rully/data_analityc"
username="kaskus_fight"
password="tryITharder1990"
host_forum="172.20.0.165"
host_user="172.20.0.170"
#host2="10.10.2.17"
#mongo="10.10.2.17/kaskus_solr"
TOTAL_AGE_15=0;
TOTAL_AGE_1620=0;
TOTAL_AGE_2125=0;
TOTAL_AGE_2630=0;
TOTAL_AGE_3135=0;
TOTAL_AGE_3640=0;
TOTAL_AGE_4145=0;
TOTAL_AGE_4650=0;
TOTAL_AGE_5155=0;
TOTAL_AGE_5660=0;
TOTAL_AGE_6165=0;
TOTAL_AGE_66=0;

echo '"month","number of kplus user","number of active kplus users"' > kplus_users.csv
datestart=20140101
while [ $datestart -lt 20171101 ]
do
startdate_str=`date -d "$datestart" +"%Y-%m-%d"`
enddate_str=`date -d "$datestart + 1 month" +"%Y-%m-%d"`
startdate_ts=`date -d "$datestart" +%s`
enddate_ts=`date -d "$datestart + 1 month" +%s`
date_onfile=`date -d "$datestart" +"%m/%Y"`

total_unknown_kplus=`mysql -ubackup -pkaskus -h 172.20.0.159 test -r -s -N -e "select count(distinct(a.userid)) from userinfo a left join kplus_retention_detail b on a.userid=b.userid where a.usergroupid=16 and b.userid is null and a.joindate<$enddate_ts;"`

total_kplus=`mysql -ubackup -pkaskus -h 172.20.0.159 test -r -s -N -e "select count(distinct(userid)) from kplus_retention_detail where start_date<'$enddate_str' and end_date>='$startdate_str';"`

total_unknown_kplus_login=`mysql -ubackup -pkaskus -h 172.20.0.159 test -r -s -N -e "select count(distinct(a.userid)) from userlog_login a join (select distinct(a.userid) from userinfo a left join kplus_retention_detail b on a.userid=b.userid where a.usergroupid=16 and b.userid is null and a.joindate<$enddate_ts) b on a.userid=b.userid where a.login_date>='$startdate_str' and a.login_date<'$enddate_str';"`

total_kplus_login=`mysql -ubackup -pkaskus -h 172.20.0.159 test -r -s -N -e "select count(distinct(a.userid)) from kplus_retention_detail a join userlog_login b on a.userid=b.userid where a.start_date<'$enddate_str' and a.end_date>='$startdate_str' and b.login_date>=a.start_date and b.login_date<a.end_date and b.login_date>='$startdate_str' and b.login_date<'$enddate_str';"`

all_kplus=`expr $total_unknown_kplus + $total_kplus`
all_kplus_login=`expr $total_unknown_kplus_login + $total_kplus_login`

echo '"'$date_onfile'","'$all_kplus'","'$all_kplus_login'"' >> kplus_users.csv
datestart=`date -d "$datestart + 1 month" +%Y%m%d`
done

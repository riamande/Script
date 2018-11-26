maxid_info=`mysql -h 172.20.0.159 -ubackup -pkaskus -r -s -N -e "select max(userid) from test.userinfo;"`
maxid_login=`mysql -h 172.20.0.159 -ubackup -pkaskus -r -s -N -e "select max(userid) from test.userlogin;"`
maxid_merge=`mysql -h 172.20.0.159 -ubackup -pkaskus -r -s -N -e "select max(userid) from test.merge;"`
mysqldump -h 172.20.0.73 -upercona -pkaskus2014 user userinfo --no-create-info --where="userid > $maxid_info " > userinfo_latest.sql
mysqldump -h 172.20.0.73 -upercona -pkaskus2014 user userlogin --no-create-info --where="userid > $maxid_login " > userlogin_latest.sql
mysql -h 172.20.0.159 -ubackup -pkaskus test < userinfo_latest.sql
mysql -h 172.20.0.159 -ubackup -pkaskus test < userlogin_latest.sql
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "insert into merge (userid,firstname,lastname,gender,joindate,dateofbirth,email) ( select userid,firstname,lastname,gender,joindate,dateofbirth,email from userinfo where userid not in(select userid from merge));"
mysql -h 172.20.0.159 -ubackup -pkaskus test -e "update merge a join userlogin b on a.userid=b.userid set a.username=b.username where a.userid>$maxid_merge;"

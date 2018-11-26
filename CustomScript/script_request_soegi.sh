MYSQL_USER="percona"
MYSQL_PASS="kaskus2014"
tglstart=`date -d $1 +%s`
tglend=`date -d $2 +%s`

mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 -B forum -e "select forum_id,name from forum_list where forum_id in (25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,196,216,302,660,657,658,659,311,215,257,310,197,218,219,296,151,210,527,574,381,573,212,286,287,448,288,202,269,268,553,631,284,603,285,293,605,294,604,299,198,261,231,262,444,606,233,291,590,292,676,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,208,334,209,333,206,207,256,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,677) ;" > fjb_forumlist.xls

for i in `mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.73 forum -s -N -e "select forum_id from forum_list where forum_id in (25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,196,216,302,660,657,658,659,311,215,257,310,197,218,219,296,151,210,527,574,381,573,212,286,287,448,288,202,269,268,553,631,284,603,285,293,605,294,604,299,198,261,231,262,444,606,233,291,590,292,676,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,208,334,209,333,206,207,256,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,677) ;"`
do
mongo kaskus_forum1 --eval "db.thread.find({forum_id:$i,dateline:{\$gte:$tglstart,\$lte:$tglend}},{_id:0,post_userid:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting > counteruser.txt
mongo kaskus_forum1 --eval "db.thread.find({forum_id:$i,dateline:{\$gte:$tglstart,\$lte:$tglend},prefix_id:'SOLD'},{_id:0,post_userid:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting > counterusersold.txt
ttluser=`cat counteruser.txt |wc -l`
ttluniquser=`cat counteruser.txt |sort |uniq |wc -l`
ttlusersold=`cat counterusersold.txt |wc -l`
ttluniqusersold=`cat counterusersold.txt |sort |uniq |wc -l`
echo $i','$ttluser >> total_new_thread.csv
echo $i','$ttluniquser >> total_user_create_new_thread.csv
echo $i','$ttlusersold >> total_thread_sold.csv
echo $i','$ttluniqusersold >> total_user_use_fitur_sold.csv
done

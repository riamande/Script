fjb_id=`mysql -u$MYSQL_USER -p$MYSQL_PASS -h 172.20.0.165 kaskus_forum -s -N -e "select child_list from forum_list where forum_id=25;" |sed -e 's$\,\-1$$g'`

for i in `mysql -h 172.20.0.170 -u $MYSQL_USER -p$MYSQL_PASS stevi_donat -r -s -N -e "select userid from tab_user;"`
do
mongo 172.20.0.15/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTB'})" |sed -n 3p > a.test1
mongo 172.20.0.16/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTB'})" |sed -n 3p > a.test2
mongo 172.20.0.19/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTB'})" |sed -n 3p > a.test3
mongo 172.20.0.24/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTB'})" |sed -n 3p > a.test4
mongo 172.20.0.28/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTB'})" |sed -n 3p > a.test5
mongo 172.20.0.30/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTB'})" |sed -n 3p > a.test6

mongo 172.20.0.15/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTS'})" |sed -n 3p > b.test1
mongo 172.20.0.16/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTS'})" |sed -n 3p > b.test2
mongo 172.20.0.19/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTS'})" |sed -n 3p > b.test3
mongo 172.20.0.24/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTS'})" |sed -n 3p > b.test4
mongo 172.20.0.28/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTS'})" |sed -n 3p > b.test5
mongo 172.20.0.30/kaskus_forum1 --eval "db.thread.count({forum_id:{\$in:[$fjb_id]},post_userid:'$i',prefix_id:'WTS'})" |sed -n 3p > b.test6
wtb1=`cat a.test1`
wtb2=`cat a.test2`
wtb3=`cat a.test3`
wtb4=`cat a.test4`
wtb5=`cat a.test5`
wtb6=`cat a.test6`
wtb=`expr $wtb1 + $wtb2 + $wtb3 + $wtb4 + $wtb5 + $wtb6`

wts1=`cat b.test1`
wts2=`cat b.test2`
wts3=`cat b.test3`
wts4=`cat b.test4`
wts5=`cat b.test5`
wts6=`cat b.test6`
wts=`expr $wts1 + $wts2 + $wts3 + $wtbs4 + $wts5 + $wts6`

if [ $wts -gt $wtb ]
then
fjb=1
elif [ $wts -lt $wtb ]
then
fjb=2
elif [ $wts = 0 -a $wtb = 0 ]
then
fjb=0
fi
mysql -h 172.20.0.170 -u $MYSQL_USER -p$MYSQL_PASS stevi_donat -e "update tab_user set fjbstatus=$fjb where userid=$i;"
echo "user $i" >> log.stevi
done

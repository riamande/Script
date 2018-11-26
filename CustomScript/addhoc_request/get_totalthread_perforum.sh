echo '"periode","sista","fashionista","Beauty","womens health"' > google_pd_womenforum.csv
for i in `seq 1 20`
do
start_date=`date -d "20160101 + $i month - 1 month" +%s`
end_date=`date -d "20160101 + $i month" +%s`
month_start=`date -d@$start_date +%Y%m`
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.aggregate([ { \$match : { forum_id:{\$in:[715,716,717,718]}, dateline:{\$gte:$start_date,\$lt:$end_date}} }, { \$group : { _id:{forum_id:'\$forum_id'}, total:{\$sum:1} } }, {\$sort:{forum_id:1}}, {\$limit:10} ]).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d':' -f4 |sed 's/[^0-9]*//g;s@^@"@g;s@$@"@g;' |sed ':a;N;$!ba;s@\n@,@g' > temp_result.temp
result=`cat temp_result.temp`
echo '"'$month_start'",'$result >> google_pd_womenforum.csv
done

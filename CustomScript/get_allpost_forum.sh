mongoexport -h 127.0.0.1 --port 27018 -d kaskus_forum -c thread -uforumshardrw -pG5NVEI5WkLFgGTB1 --authenticationDatabase=kaskus_forum -q '{forum_id:275,dateline:{$gte:1496250000,$lt:1504198800},visible:1}' --fields _id,title --type=csv -o nightlive_ds_data.csv
cat nightlive_ds_data.csv |cut -d',' -f1 |sed 's@ObjectId(@@g;s@)@@g' > nightlive_ds_data.txt
for i in `cat nightlive_ds_data.txt`
do
	mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "hex_md5('$i')" |grep -v 'MongoDB shell version:\|connecting to:' > temp_hexid.temp
	hex_id=`cat temp_hexid.temp`
	mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.post.find({hash_thread_id:'$hex_id'},{_id:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |cut -d'"' -f4 > loop_postnightlive.txt
	for j in `cat loop_postnightlive.txt`
	do
		mongoexport -h 127.0.0.1 --port 27018 -d kaskus_forum -c post -uforumshardrw -pG5NVEI5WkLFgGTB1 --authenticationDatabase=kaskus_forum -q "{_id:ObjectId('$j')}" --fields dateline,post_username,pagetext --type=csv -o nightlive_post.csv
		sed -i '/dateline,post_username,pagetext/d;:a;N;$!ba;s/\n/\\n/g' nightlive_post.csv
		mysqlimport -h 172.20.0.159 -ubackup -pkaskus --local --fields-optionally-enclosed-by="\"" --fields-terminated-by=, --lines-terminated-by="\n" test nightlive_post.csv
		rm nightlive_post.csv
	done
done
mysql -h 172.20.0.159 -ubackup -pkaskus -e "select from_unixtime(dateline) date,username,replace(title,'\n','\\n') title,replace(pagetext,'\n','\\n') pagetext from nightlive_post a,nightlive_ds_data b where a.threadid=b.threadid;" |sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > nightlife_jun-agt.csv
sed -i 's@\\\\n@\\n@g' nightlife_jun-agt.csv

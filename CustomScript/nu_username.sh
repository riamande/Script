for i in `cat nu_postid.txt`
do
mongo kaskus_forum1 --eval "db.post.find({_id:ObjectId('$i')},{_id:0,post_username:1}).forEach(printjson)" >> nu_username.csv
done

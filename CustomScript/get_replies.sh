strip_tglstart=`echo $1 |cut -d':' -f1`
strip_jamstart=`echo $1 |cut -d':' -f2`
strip_tglend=`echo $2 |cut -d':' -f1`
strip_jamend=`echo $2 |cut -d':' -f2`

tglstart=`date -d $strip_tglstart +%s`
tglend=`date -d $strip_tglend +%s`
threadid="$3"
ttl_loop=`expr $tglend - $tglstart + 86400`
tgl_loop=`expr $ttl_loop / 86400`

tglstart1=$tglstart
if [ $strip_jamstart -gt 0 ]
then
plusstart=`expr $strip_jamstart \* 3600`
else
plusstart=0
fi
tglstart=`expr $tglstart + $plusstart`

if [ $strip_jamend -gt 0 ]
then
plusend=`expr $strip_jamend \* 3600`
else
plusend=86400
fi

i=1
while [ $i -le $tgl_loop ]
do
if [ $i -eq $tgl_loop ]
then
tglend=`expr $tglend + $plusend`
else
tglend=`expr $tglstart1 + 86400 \* $i`
fi
mongo 172.16.0.88/kaskus_forum1 --eval "db.post.count({thread_id:'$threadid',dateline:{\$gte:$tglstart,\$lt:$tglend}})" |grep -v MongoDB |grep -v connecting > temp_count.txt
text1=`cat temp_count.txt`
text2=`date -d@$tglstart +%Y%m%d`
echo $text2 = $text1
tglstart="$tglend"
let i=i+1
done

DATE_END_STR=$(env TZ=Asia/Jakarta date +'%Y%m%d')
DATE_END=$(env TZ=Asia/Jakarta date -d $DATE_END_STR +"%s") # get now 
DATE_START_STR=$(env TZ=Asia/Jakarta date -d "-1 day" +'%Y%m%d')
DATE_START=$(env TZ=Asia/Jakarta date -d $(env TZ=Asia/Jakarta date -d "-1 day" +'%Y/%m/%d') +"%s") # get 1 day ago
OID_START=`mongo --eval "Math.floor($DATE_START).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
OID_END=`mongo --eval "Math.floor($DATE_END).toString(16) + '0000000000000000';" |grep -v 'MongoDB shell\|connecting'`
DATA_DIR="/home/rully/campaign_oppo"

#forum image
#thread
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({visible:1,forum_id:6,_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{post_userid:1,post_username:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $DATA_DIR/forum_image.csv
sed -i ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/thread/@g' $DATA_DIR/forum_image.csv
sed -i ':a;N;$!ba;s@),\n\t"post_username" : @,@g' $DATA_DIR/forum_image.csv
sed -i ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' $DATA_DIR/forum_image.csv
sed -i '/}/d' $DATA_DIR/forum_image.csv
cat $DATA_DIR/forum_image.csv |cut -d ',' -f3 |cut -d '/' -f6 |cut -d '"' -f1 |sort |uniq > $DATA_DIR/forum_image_loop.csv
totalthread=`cat $DATA_DIR/forum_image_loop.csv |wc -l`
modulus_thread=`expr $totalthread % 999`
if [ $modulus_thread -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalthread \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/forum_image_trim.sh
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/forum_image_loop.csv |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`
mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where userid in ($id) and usergroupid in (3,23,36,28,6,31,35,34,33,27);" >> $DATA_DIR/forum_image_trim.sh
done
sed -i '/^$/d' $DATA_DIR/forum_image_trim.sh
sed -i 's@^@sed -i "/\\/@g' $DATA_DIR/forum_image_trim.sh
sed -i 's@$@\\"/d" \/home\/rully\/campaign_oppo\/forum_image.csv@g' $DATA_DIR/forum_image_trim.sh
chmod 700 $DATA_DIR/forum_image_trim.sh
. $DATA_DIR/forum_image_trim.sh

cat $DATA_DIR/forum_image.csv |sort |uniq > $DATA_DIR/thread_image_$DATE_START_STR.csv

#post
> $DATA_DIR/post_image.csv
i=0
for i in `seq 1 499`
do
mongo 172.20.0.156/kaskus_forum1 --eval "rs.slaveOk();db.mypost_$i.find({forum_id:'6',visible:1,_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $DATA_DIR/post_image.csv
done
cat $DATA_DIR/post_image.csv |sed 's@{ "_id" : ObjectId("@"https://www.kaskus.co.id/show_post/@g' |sed 's@), "post_userid" : @,@g' |sed 's@ }@@g' |grep -v '")$' > $DATA_DIR/postreply_image.csv
cat $DATA_DIR/post_image.csv |cut -d ',' -f2 |cut -d '"' -f4 |sort |uniq > $DATA_DIR/post_image_loop.csv
totalpost=`cat $DATA_DIR/post_image_loop.csv |wc -l`
modulus_post=`expr $totalpost % 999`
if [ $modulus_post -gt 0 ]
then
adjustment_add=1
else 
adjustment_add=0          
fi
jumlahloop=`expr $totalpost \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/post_image_trim.sh
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`            
id=`cat $DATA_DIR/post_image_loop.csv |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`
mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where userid in ($id) and usergroupid in (3,23,36,28,6,31,35,34,33,27);" >> $DATA_DIR/post_image_trim.sh
done
sed -i '/^$/d' $DATA_DIR/post_image_trim.sh
sed -i 's@^@sed -i "/\\"@g' $DATA_DIR/post_image_trim.sh
sed -i 's@$@\\"/d" \/home\/rully\/campaign_oppo\/post_image.csv@g' $DATA_DIR/post_image_trim.sh
chmod 700 $DATA_DIR/post_image_trim.sh              
. $DATA_DIR/post_image_trim.sh

cat $DATA_DIR/post_image.csv |cut -d ',' -f1|sed 's@{ "_id" : @@g' > $DATA_DIR/postreply_image_loop.csv

totalpost=`cat $DATA_DIR/postreply_image_loop.csv |wc -l`
modulus_post=`expr $totalpost % 999`
if [ $modulus_post -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalpost \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/postreply_image_$DATE_START_STR.csv
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/postreply_image_loop.csv |sed -n "$bawah,$atas p" |tr '"' "'" | tr '\n' ','|sed -e 's/,$//g'`
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.post.find({visible:1,_id:{\$in:[$id]}},{post_username:1,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/show_post/@g' |sed ':a;N;$!ba;s@),\n\t"post_username" : @,@g' |sed ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' |sed '/}/d' >> $DATA_DIR/postreply_image_$DATE_START_STR.csv
done

#a=`cat $DATA_DIR/postreply_image.csv |wc -l`
#> $DATA_DIR/postreply_image_$DATE_START_STR.csv
#for ((i=1;i<=$a;i++))
#do
#userid=`cat $DATA_DIR/postreply_image.csv |sed -n $i'p' |cut -d',' -f2 |sed 's@"@@g'`
#link=`cat $DATA_DIR/postreply_image.csv |sed -n $i'p' |cut -d',' -f1 |sed 's@"@@g'`
#user_name=`mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select username from userlogin where userid=$userid;"`
#echo '"'$link'","'$user_name'","https://www.kaskus.co.id/profile/aboutme/'$userid'"' >> $DATA_DIR/postreply_image_$DATE_START_STR.csv
#done

#forum video
#thread
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({forum_id:8,visible:1,_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{post_userid:1,post_username:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $DATA_DIR/forum_video.csv
sed -i ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/thread/@g' $DATA_DIR/forum_video.csv
sed -i ':a;N;$!ba;s@),\n\t"post_username" : @,@g' $DATA_DIR/forum_video.csv
sed -i ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' $DATA_DIR/forum_video.csv
sed -i '/}/d' $DATA_DIR/forum_video.csv
cat $DATA_DIR/forum_video.csv |cut -d ',' -f3 |cut -d '/' -f6 |cut -d '"' -f1 |sort |uniq > $DATA_DIR/forum_video_loop.csv
totalthread=`cat $DATA_DIR/forum_video_loop.csv |wc -l`
modulus_thread=`expr $totalthread % 999`
if [ $modulus_thread -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalthread \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/forum_video_trim.sh
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/forum_video_loop.csv |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`
mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where userid in ($id) and usergroupid in (3,23,36,28,6,31,35,34,33,27);" >> $DATA_DIR/forum_video_trim.sh
done
sed -i '/^$/d' $DATA_DIR/forum_video_trim.sh
sed -i 's@^@sed -i "/\\/@g' $DATA_DIR/forum_video_trim.sh
sed -i 's@$@\\"/d" \/home\/rully\/campaign_oppo\/forum_video.csv@g' $DATA_DIR/forum_video_trim.sh
chmod 700 $DATA_DIR/forum_video_trim.sh
. $DATA_DIR/forum_video_trim.sh

cat $DATA_DIR/forum_video.csv |sort |uniq > $DATA_DIR/thread_video_$DATE_START_STR.csv

#post
> $DATA_DIR/post_video.csv
i=0
for i in `seq 1 499`
do
mongo 172.20.0.156/kaskus_forum1 --eval "rs.slaveOk();db.mypost_$i.find({forum_id:'8',visible:1,_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $DATA_DIR/post_video.csv
done
cat $DATA_DIR/post_video.csv |sed 's@{ "_id" : ObjectId("@"https://www.kaskus.co.id/show_post/@g' |sed 's@), "post_userid" : @,@g' |sed 's@ }@@g' |grep -v '")$' > $DATA_DIR/postreply_video.csv
cat $DATA_DIR/post_video.csv |cut -d ',' -f2 |cut -d '"' -f4 |sort |uniq > $DATA_DIR/post_video_loop.csv
totalpost=`cat $DATA_DIR/post_video_loop.csv |wc -l`
modulus_post=`expr $totalpost % 999`    
if [ $modulus_post -gt 0 ]  
then
adjustment_add=1
else 
adjustment_add=0          
fi
jumlahloop=`expr $totalpost \/ 999 + $adjustment_add`    
atas=0
bawah=0
num=1
> $DATA_DIR/post_video_trim.sh 
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`            
id=`cat $DATA_DIR/post_video_loop.csv |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'` 
mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where userid in ($id) and usergroupid in (3,23,36,28,6,31,35,34,33,27);" >> $DATA_DIR/post_video_trim.sh 
done
sed -i '/^$/d' $DATA_DIR/post_video_trim.sh 
sed -i 's@^@sed -i "/\\"@g' $DATA_DIR/post_video_trim.sh
sed -i 's@$@\\"/d" \/home\/rully\/campaign_oppo\/post_video.csv@g' $DATA_DIR/post_video_trim.sh  
chmod 700 $DATA_DIR/post_video_trim.sh
. $DATA_DIR/post_video_trim.sh 

cat $DATA_DIR/post_video.csv |cut -d ',' -f1|sed 's@{ "_id" : @@g' > $DATA_DIR/postreply_video_loop.csv

totalpost=`cat $DATA_DIR/postreply_video_loop.csv |wc -l`
modulus_post=`expr $totalpost % 999`
if [ $modulus_post -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalpost \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/postreply_video_$DATE_START_STR.csv
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/postreply_video_loop.csv |sed -n "$bawah,$atas p" |tr '"' "'" | tr '\n' ','|sed -e 's/,$//g'`    
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.post.find({visible:1,_id:{\$in:[$id]}},{post_username:1,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/show_post/@g' |sed ':a;N;$!ba;s@),\n\t"post_username" : @,@g' |sed ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' |sed '/}/d' >> $DATA_DIR/postreply_video_$DATE_START_STR.csv
done

#a=`cat $DATA_DIR/postreply_video.csv |wc -l`
#> $DATA_DIR/postreply_video_$DATE_START_STR.csv
#for ((i=1;i<=$a;i++))
#do
#userid=`cat $DATA_DIR/postreply_video.csv |sed -n $i'p' |cut -d',' -f2 |sed 's@"@@g'`
#link=`cat $DATA_DIR/postreply_video.csv |sed -n $i'p' |cut -d',' -f1 |sed 's@"@@g'`
#user_name=`mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select username from userlogin where userid=$userid;"`
#echo '"'$link'","'$user_name'","https://www.kaskus.co.id/profile/aboutme/'$userid'"' >> $DATA_DIR/postreply_video_$DATE_START_STR.csv
#done

#forum others
#thread
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.thread.find({visible:1,forum_id:{\$nin:[25,221,784,849,850,848,778,305,793,804,805,447,446,803,769,283,256,785,687,686,758,615,616,227,845,844,847,264,843,842,625,846,841,780,195,837,313,839,255,840,254,838,779,196,216,302,660,659,311,657,215,257,310,658,756,197,218,219,781,296,790,787,788,786,791,792,789,760,679,681,680,682,759,210,527,739,740,738,741,381,573,743,212,742,762,286,287,795,448,288,794,298,763,202,269,631,574,268,553,293,294,797,604,605,796,765,284,603,285,764,677,295,814,815,608,609,774,299,229,801,802,800,767,317,330,328,318,323,327,321,324,325,319,326,320,322,772,198,261,231,262,444,606,799,798,233,291,292,676,766,201,829,811,810,228,607,771,729,200,266,265,853,329,220,826,827,834,835,830,836,589,832,590,833,828,831,777,205,334,333,206,818,207,593,208,209,816,817,819,776,300,806,312,770,151,820,821,822,823,824,825,761,199,812,813,223,225,222,773,303,807,852,808,809,783,314,782,768,614,316,610,611,775,304,297,612,613,757,588,662,6,8]},_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{post_userid:1,post_username:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' > $DATA_DIR/forum_others.csv
sed -i ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/thread/@g' $DATA_DIR/forum_others.csv
sed -i ':a;N;$!ba;s@),\n\t"post_username" : @,@g' $DATA_DIR/forum_others.csv
sed -i ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' $DATA_DIR/forum_others.csv
sed -i '/}/d' $DATA_DIR/forum_others.csv
cat $DATA_DIR/forum_others.csv |cut -d ',' -f3 |cut -d '/' -f6 |cut -d '"' -f1 |sort |uniq > $DATA_DIR/forum_others_loop.csv
totalthread=`cat $DATA_DIR/forum_others_loop.csv |wc -l`
modulus_thread=`expr $totalthread % 999`
if [ $modulus_thread -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalthread \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/forum_others_trim.sh
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/forum_others_loop.csv |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'`
mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where userid in ($id) and usergroupid in (3,23,36,28,6,31,35,34,33,27);" >> $DATA_DIR/forum_others_trim.sh
done
sed -i '/^$/d' $DATA_DIR/forum_others_trim.sh
sed -i 's@^@sed -i "/\\/@g' $DATA_DIR/forum_others_trim.sh
sed -i 's@$@\\"/d" \/home\/rully\/campaign_oppo\/forum_others.csv@g' $DATA_DIR/forum_others_trim.sh
chmod 700 $DATA_DIR/forum_others_trim.sh
. $DATA_DIR/forum_others_trim.sh

cat $DATA_DIR/forum_others.csv |sort |uniq > $DATA_DIR/thread_others_$DATE_START_STR.csv

#post
> $DATA_DIR/post_others.csv
i=0
for i in `seq 1 499`
do
mongo 172.20.0.156/kaskus_forum1 --eval "rs.slaveOk();db.mypost_$i.find({visible:1,forum_id:{\$nin:['25','221','784','849','850','848','778','305','793','804','805','447','446','803','769','283','256','785','687','686','758','615','616','227','845','844','847','264','843','842','625','846','841','780','195','837','313','839','255','840','254','838','779','196','216','302','660','659','311','657','215','257','310','658','756','197','218','219','781','296','790','787','788','786','791','792','789','760','679','681','680','682','759','210','527','739','740','738','741','381','573','743','212','742','762','286','287','795','448','288','794','298','763','202','269','631','574','268','553','293','294','797','604','605','796','765','284','603','285','764','677','295','814','815','608','609','774','299','229','801','802','800','767','317','330','328','318','323','327','321','324','325','319','326','320','322','772','198','261','231','262','444','606','799','798','233','291','292','676','766','201','829','811','810','228','607','771','729','200','266','265','853','329','220','826','827','834','835','830','836','589','832','590','833','828','831','777','205','334','333','206','818','207','593','208','209','816','817','819','776','300','806','312','770','151','820','821','822','823','824','825','761','199','812','813','223','225','222','773','303','807','852','808','809','783','314','782','768','614','316','610','611','775','304','297','612','613','757','588','662','6','8']},_id:{\$gte:ObjectId('$OID_START'),\$lte:ObjectId('$OID_END')}},{post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' >> $DATA_DIR/post_others.csv
done
cat $DATA_DIR/post_others.csv |sed 's@{ "_id" : ObjectId("@"https://www.kaskus.co.id/show_post/@g' |sed 's@), "post_userid" : @,@g' |sed 's@ }@@g' |grep -v '")$' > $DATA_DIR/postreply_others.csv
cat $DATA_DIR/post_others.csv |cut -d ',' -f2 |cut -d '"' -f4 |sort |uniq > $DATA_DIR/post_others_loop.csv
totalpost=`cat $DATA_DIR/post_others_loop.csv |wc -l`
modulus_post=`expr $totalpost % 999`
if [ $modulus_post -gt 0 ]  
then
adjustment_add=1
else 
adjustment_add=0          
fi
jumlahloop=`expr $totalpost \/ 999 + $adjustment_add`    
atas=0
bawah=0
num=1
> $DATA_DIR/post_others_trim.sh 
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`            
id=`cat $DATA_DIR/post_others_loop.csv |sed -n "$bawah,$atas p" | tr '\n' ','|sed -e 's/,$//g'` 
mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select userid from userinfo where userid in ($id) and usergroupid in (3,23,36,28,6,31,35,34,33,27);" >> $DATA_DIR/post_others_trim.sh 
done
sed -i '/^$/d' $DATA_DIR/post_others_trim.sh 
sed -i 's@^@sed -i "/\\"@g' $DATA_DIR/post_others_trim.sh
sed -i 's@$@\\"/d" \/home\/rully\/campaign_oppo\/post_others.csv@g' $DATA_DIR/post_others_trim.sh  
chmod 700 $DATA_DIR/post_others_trim.sh
. $DATA_DIR/post_others_trim.sh 

cat $DATA_DIR/post_others.csv |cut -d ',' -f1|sed 's@{ "_id" : @@g' > $DATA_DIR/postreply_others_loop.csv

totalpost=`cat $DATA_DIR/postreply_others_loop.csv |wc -l`
modulus_post=`expr $totalpost % 999`
if [ $modulus_post -gt 0 ]
then
adjustment_add=1
else
adjustment_add=0
fi
jumlahloop=`expr $totalpost \/ 999 + $adjustment_add`
atas=0
bawah=0
num=1
> $DATA_DIR/postreply_others_$DATE_START_STR.csv
for num in `seq 1 $jumlahloop`
do
atas=`expr $num \* 999`
bawah=`expr $atas - 998`
id=`cat $DATA_DIR/postreply_others_loop.csv |sed -n "$bawah,$atas p" |tr '"' "'" | tr '\n' ','|sed -e 's/,$//g'`
/opt/mongodb_3.0.10/bin/mongo 127.0.0.1:27018/kaskus_forum -uforumshardrw -pG5NVEI5WkLFgGTB1 --eval "db.post.find({visible:1,_id:{\$in:[$id]}},{post_username:1,post_userid:1}).forEach(printjson)" |grep -v 'MongoDB shell version:\|connecting to:' |sed ':a;N;$!ba;s@{\n\t"_id" : ObjectId("@"https://www.kaskus.co.id/show_post/@g' |sed ':a;N;$!ba;s@),\n\t"post_username" : @,@g' |sed ':a;N;$!ba;s@\n\t"post_userid" : "@"https://www.kaskus.co.id/profile/aboutme/@g' |sed '/}/d' >> $DATA_DIR/postreply_others_$DATE_START_STR.csv
done

#a=`cat $DATA_DIR/postreply_others.csv |wc -l`
#> $DATA_DIR/postreply_others_$DATE_START_STR.csv
#for ((i=1;i<=$a;i++))
#do
#userid=`cat $DATA_DIR/postreply_others.csv |sed -n $i'p' |cut -d',' -f2 |sed 's@"@@g'`
#link=`cat $DATA_DIR/postreply_others.csv |sed -n $i'p' |cut -d',' -f1 |sed 's@"@@g'`
#user_name=`mysql -h 172.20.0.72 -upercona -pkaskus2014 user -r -s -N -e "select username from userlogin where userid=$userid;"`
#echo '"'$link'","'$user_name'","https://www.kaskus.co.id/profile/aboutme/'$userid'"' >> $DATA_DIR/postreply_others_$DATE_START_STR.csv
#done


sendemail -f statistic@kaskusnetworks.com -t zarona@kaskusnetworks.com,christoforus.stefanus@kaskusnetworks.com,giovani.ardy@kaskusnetworks.com,kk.community@kaskusnetworks.com,rully@kaskusnetworks.com,glen@kaskusnetworks.com -u "[DAILY - $DATE_START_STR] OPPO Online Activity" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_DIR/thread_image_$DATE_START_STR.csv $DATA_DIR/thread_video_$DATE_START_STR.csv $DATA_DIR/thread_others_$DATE_START_STR.csv $DATA_DIR/postreply_image_$DATE_START_STR.csv $DATA_DIR/postreply_video_$DATE_START_STR.csv $DATA_DIR/postreply_others_$DATE_START_STR.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1
#sendemail -f statistic@kaskusnetworks.com -t rully@kaskusnetworks.com -u "[ DAILY - $DATE_START_STR ] OPPO Online Activity" -m "Details information is attached below. \n\n\n\n Regards, \n DBA" -a $DATA_DIR/thread_image_$DATE_START_STR.csv $DATA_DIR/thread_video_$DATE_START_STR.csv $DATA_DIR/thread_others_$DATE_START_STR.csv $DATA_DIR/postreply_image_$DATE_START_STR.csv $DATA_DIR/postreply_video_$DATE_START_STR.csv $DATA_DIR/postreply_others_$DATE_START_STR.csv -o tls=no -s 103.6.117.20 > /dev/null  2>&1

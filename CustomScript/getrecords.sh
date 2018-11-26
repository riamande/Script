ipaddress="172.20.0.11,172.20.0.12,172.20.0.19,172.20.0.22,172.20.0.24,172.20.0.26,172.20.0.32,172.20.0.35,172.20.0.38,172.20.0.41,172.20.0.44"
port=27018
#start_date="570300000000000000000000"
#end_date="570451800000000000000000"
start_date=$1
end_date=$2
for ((i=1;i<=11;i++))
do
ip=`echo $ipaddress |cut -d',' -f$i`
/opt/mongodb_3.0.10/bin/mongo $ip:$port/forum_beacon --eval "db.post.count({_id:{\$gte:ObjectId('$start_date'),\$lt:ObjectId('$end_date')}})" |grep -v "MongoDB\|connecting"
done

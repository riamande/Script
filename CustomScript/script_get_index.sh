ip=$1
db=$2
count=`mysql -h $ip -ukaskus_fight -ptryITharder1990 $db -s -e "show tables;" |wc -l`
for ((i=1;i<=$count;i++))
do
table=`mysql -h $ip -ukaskus_fight -ptryITharder1990 $db -s -e "show tables;" |sed -n $i'p'`
mysql -h $ip -ukaskus_fight -ptryITharder1990 $db -e "show index from $table;"
done

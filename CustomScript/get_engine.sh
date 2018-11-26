ipdb=$1
totaldb=`mysql -h $ipdb -ukaskus_fight -ptryITharder1990 -s -N -e "show databases;" |grep -v information_schema |grep -v performance_schema |wc -l `
#echo $totaldb
for ((i=1;i<=$totaldb;i++))
do
dbname=`mysql -h $ipdb -ukaskus_fight -ptryITharder1990 -s -N -e "show databases;" |grep -v information_schema |grep -v performance_schema |sed -n $i'p'`
tablecount=`mysql -h $ipdb -ukaskus_fight -ptryITharder1990 $dbname -s -N -e "show tables;" |wc -l`
#echo $dbname $tablecount
for ((j=1;j<=$tablecount;j++))
do
tablename=`mysql -h $ipdb -ukaskus_fight -ptryITharder1990 $dbname -s -N -e "show tables;" |sed -n $j'p'`
countrow=`mysql -h $ipdb -ukaskus_fight -ptryITharder1990 $dbname -s -N -e "show create table $tablename;" |grep ENGINE=InnoDB |wc -l`
#echo $tablename 
#echo $countrow
echo "$dbname.$tablename : $countrow"
done
done


#tanggal ditentukan.
lastweek="2014-07-17" 
#jumlah Tabel yang akan diambil
jumlahTabel="100";

while (true)
do	
	a=$((RANDOM%500));
	echo $a >> random.log;
	num=`more random.log|sort|uniq|wc -l`
	
	if [ $num ==  $jumlahTabel ]
	then
		break;
	fi
done

for i in `cat random.log|sort|uniq`
do
	mysql -h 172.20.0.153 -u $MYSQL_USER -p$MYSQL_PASS -s -N -e "use kaskus_pm;select  length(message) from pm_user_$i where date > $lastweek" >> length_message.log
done
rm random.log
hasil=0;
max=`more length_message.log |sort -nr|head -n 1`;
min=`more length_message.log |sort -n|head -n 1`;
hasil=`awk '{ sum += $1 } END { print sum }' length_message.log`
JumlahData=`more length_message.log|wc -l`
hasilAverage=`expr $hasil \/ $JumlahData`
echo "" >> hasil.log;
echo "Hasil Panjang PM" >> hasil.log;
echo "Rata-Rata : $hasilAverage Karakter" >> hasil.log;
echo "Max : $max Karakter" >> hasil.log;
echo "Min : $min Karakter" >> hasil.log;
echo "Jumlah Data : $JumlahData PM Sent" >> hasil.log;
echo "" >> hasil.log;
echo "##########################STATISTIC##########################" >> hasil.log
seratus=0;
duaratus=0;
tigaratus=0;
empatratus=0;
limaratus=0;
diataslimaratus=0;

for i in `more length_message.log |sort |uniq -c|sort -nr | sed -e 's/^ *//' -e 's/ *$//'|tr ' ' '.'`
do
                        
                        jumlah=`echo $i |cut -d'.' -f1`
                        panjang=`echo $i |cut -d'.' -f2`
			if [ "$panjang" -lt 100 ]
			then
				seratus=`expr $seratus  + $jumlah`;
			elif [ "$panjang" -ge 100 ] && [ "$panjang" -lt 200 ]
			then
				duaratus=`expr $duaratus  + $jumlah`;
			elif [ "$panjang" -ge 200 ] && [ "$panjang" -lt 300 ]
			then
				tigaratus=`expr $tigaratus  + $jumlah`;
			elif [ "$panjang" -ge 300 ] && [ "$panjang" -lt 400 ]
			then
				empatratus=`expr $empatratus + $jumlah`;
                        elif [ "$panjang" -ge 400 ] && [ "$panjang" -lt 500 ]
			then
				limaratus=`expr $limaratus + $jumlah`;
			elif [ "$panjang" -ge 500 ]
			then
				diataslimaratus=`expr $diataslimaratus  + $jumlah`;
			fi

done

echo "0 - 100 = $seratus Data"  >> hasil.log;
echo "100 - 200 = $duaratus Data"  >> hasil.log;
echo "200 - 300 = $tigaratus Data"  >> hasil.log;
echo "300 - 400 = $empatratus Data"  >> hasil.log;
echo "400 - 500 = $limaratus Data"  >> hasil.log;
echo "> 500 = $diataslimaratus Data"  >> hasil.log;
echo "" >> hasil.log;



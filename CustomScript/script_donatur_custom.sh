tglstart=`date -d $1 +%s`
tglend=`date -d $2 +%s`
total_uniq=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select distinct userid from transaksi_promo where dateline>=$tglstart and dateline<=$tglend and status=1;" |wc -l`

mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select userid from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=1;" > uniq_donatur_pk1.txt
mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select userid from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=2;" > uniq_donatur_pk2.txt
mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select userid from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=3;" > uniq_donatur_pk3.txt
mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select userid from transaksi where dateline>=$tglstart and dateline<=$tglend and status=1 and packetid=4;" > uniq_donatur_pk4.txt

a=`cat uniq_donatur_pk1.txt |sort |uniq |wc -l`
b=`cat uniq_donatur_pk2.txt |sort |uniq |wc -l`
c=`cat uniq_donatur_pk3.txt |sort |uniq |wc -l`
d=`cat uniq_donatur_pk4.txt |sort |uniq |wc -l`

cat uniq_donatur_pk1.txt |sort |uniq > uniq_donatur_temp.txt
cat uniq_donatur_pk2.txt |sort |uniq >> uniq_donatur_temp.txt
cat uniq_donatur_pk3.txt |sort |uniq >> uniq_donatur_temp.txt
cat uniq_donatur_pk4.txt |sort |uniq >> uniq_donatur_temp.txt

cp uniq_donatur_pk1.txt uniq_donatur_pk1_counter.txt
cp uniq_donatur_pk2.txt uniq_donatur_pk2_counter.txt
cp uniq_donatur_pk3.txt uniq_donatur_pk3_counter.txt
cp uniq_donatur_pk4.txt uniq_donatur_pk4_counter.txt

sed -i 's\^\@\g' uniq_donatur_pk1_counter.txt; sed -i 's\$\@\g' uniq_donatur_pk1_counter.txt;
sed -i 's\^\@\g' uniq_donatur_pk2_counter.txt; sed -i 's\$\@\g' uniq_donatur_pk2_counter.txt;
sed -i 's\^\@\g' uniq_donatur_pk3_counter.txt; sed -i 's\$\@\g' uniq_donatur_pk3_counter.txt;
sed -i 's\^\@\g' uniq_donatur_pk4_counter.txt; sed -i 's\$\@\g' uniq_donatur_pk4_counter.txt;

#for i in `cat uniq_donatur_temp.txt |sort |uniq -c |sed -e 's$      $$g'`
#do
#e=`echo $i |cut -d ' ' -f1`
#if [ "$e" -gt "1" ]
#then
#echo $i |cut -d' ' -f2 >> nonuniq_donatur_temp.txt
#fi
#done

cat uniq_donatur_temp.txt |sort |uniq -c |sed -e 's$      $$g' |grep -v '1 ' |cut -d' ' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g' > nonuniq_donatur_temp.txt

for i in `cat nonuniq_donatur_temp.txt`
do
sed -i "/$i/d" uniq_donatur_pk1_counter.txt
sed -i "/$i/d" uniq_donatur_pk2_counter.txt
sed -i "/$i/d" uniq_donatur_pk3_counter.txt
sed -i "/$i/d" uniq_donatur_pk4_counter.txt
done

paket_uniq1=`cat uniq_donatur_pk1_counter.txt |sort |uniq |grep [0-9] |wc -l`
paket_uniq2=`cat uniq_donatur_pk2_counter.txt |sort |uniq |grep [0-9] |wc -l`
paket_uniq3=`cat uniq_donatur_pk3_counter.txt |sort |uniq |grep [0-9] |wc -l`
paket_uniq4=`cat uniq_donatur_pk4_counter.txt |sort |uniq |grep [0-9] |wc -l`
paket_uniq_rnd=`cat nonuniq_donatur_temp.txt |wc -l`

#total_renew=`mysql -h 172.20.0.53 -ukk_report -pkaskus kaskus_donatur -s -N -e "select userid,count(*) from transaksi_promo where dateline>=$tglstart and dateline<=$tglend and status=1 group by userid having count(userid)>1;" |wc -l`

#untung=`expr $paket1 \* 30000 + $paket2 \* 80000 + $paket3 \* 150000 + $paket4 \* 300000`

echo paket1 uniq = $paket_uniq1
echo paket2 uniq = $paket_uniq2
echo paket3 uniq = $paket_uniq3
echo paket4 uniq = $paket_uniq4
echo "paket random (ganti - ganti paket)" = $paket_uniq_rnd

#echo income = $untung
#echo total donatur = $total_uniq
#echo total renew = $total_renew

cat uniq_donatur_pk1.txt |sort |uniq -c |sed -e 's$      $$g' |grep '12 ' |cut -d' ' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g' > renew_paket1.txt
cat uniq_donatur_pk1.txt |sort |uniq -c |sed -e 's$      $$g' |grep -v '12 ' |sed -e 's/ /:/g' > renew_paket1_rnd.txt

#for i in `cat uniq_donatur_pk1.txt |sort |uniq -c |sed -e 's$      $$g'` 
#do
#f=`echo $i |cut -d ' ' -f1`
#if [ $f -eq 12 ]
#then
#echo $i |cut -d' ' -f2 >> renew_paket1.txt
#else
#text1=`echo $i |cut -d' ' -f2`
#text2=`echo $i |cut -d' ' -f1`
#echo $text1':'$text2 >> renew_paket1_rnd.txt
#fi
#done

cat uniq_donatur_pk2.txt |sort |uniq -c |sed -e 's$      $$g' |grep '4 ' |cut -d' ' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g' > renew_paket2_1th.txt
cat uniq_donatur_pk2.txt |sort |uniq -c |sed -e 's$      $$g' |grep '2 ' |cut -d' ' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g' > renew_paket2_6bln.txt
cat uniq_donatur_pk2.txt |sort |uniq -c |sed -e 's$      $$g' |grep '2 ' |sed -e 's/2 /6:/g' > renew_paket2_rnd.txt
cat uniq_donatur_pk2.txt |sort |uniq -c |sed -e 's$      $$g' |grep '1 ' |sed -e 's/1 /3:/g' >> renew_paket2_rnd.txt
cat uniq_donatur_pk2.txt |sort |uniq -c |sed -e 's$      $$g' |grep '3 ' |sed -e 's/3 /9:/g' >> renew_paket2_rnd.txt

#for i in `cat uniq_donatur_pk2.txt |sort |uniq -c |sed -e 's$      $$g'` 
#do
#f=`echo $i |cut -d ' ' -f1`
#if [ $f -eq 4 ]
#then
#echo $i |cut -d' ' -f2 >> renew_paket2_1th.txt
#elif [ $f -eq 2 ]
#then
#echo $i |cut -d' ' -f2 >> renew_paket2_6bln.txt
#echo `echo $i |cut -d' ' -f2`':6' >> renew_paket2_rnd.txt
#else
#text1=`echo $i |cut -d' ' -f2`
#counttext2=`echo $i |cut -d' ' -f1`
#text2=`expr $counttext2 \* 3`
#echo $text1':'$text2 >> renew_paket2_rnd.txt
#fi  
#done

cat uniq_donatur_pk3.txt |sort |uniq -c |sed -e 's$      $$g' |grep '2 ' |cut -d' ' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g' > renew_paket3.txt
cat uniq_donatur_pk3.txt |sort |uniq -c |sed -e 's$      $$g' |grep '1 ' |sed -e 's/1 /6:/g' > renew_paket3_rnd.txt

#for i in `cat uniq_donatur_pk3.txt |sort |uniq -c |sed -e 's$      $$g'` 
#do
#f=`echo $i |cut -d ' ' -f1`
#if [ $f -eq 2 ]
#then
#echo $i |cut -d' ' -f2 >> renew_paket3.txt
#else
#text1=`echo $i |cut -d' ' -f2`
#echo $text1':6' >> renew_paket3_rnd.txt
#fi  
#done

echo renew 1th paket1 = `cat renew_paket1.txt |wc -l`
echo renew 1th paket2 = `cat renew_paket2_1th.txt |wc -l`
echo renew 1th paket3 = `cat renew_paket3.txt |wc -l`
echo renew 6bln paket2 = `cat renew_paket2_6bln.txt |wc -l`

for i in `cat renew_paket2_rnd.txt |sed -e 's/ //g' |cut -d':' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g'`
do
cat renew_paket3_rnd.txt |sed -e 's/ //g' |cut -d':' -f2 |sed -e 's/^/@/g' |sed -e 's/$/@/g' |grep $i >> renew_1th_rnd.txt
done

echo "renew 1th paket(2,3)" = `cat renew_1th_rnd.txt |sort |uniq |wc -l`


rm renew_paket*
rm renew_1th_rnd.txt
rm uniq_donatur_*
rm nonuniq_donatur_temp.txt


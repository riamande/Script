wget "http://geolite.maxmind.com/download/geoip/database/GeoIPCountryCSV.zip"
unzip -o GeoIPCountryCSV.zip
tanggal=`date '+%Y%m%d'`
trimmer=`cat result.txt |head -n 1 |cut -d' ' -f5 |grep -o '..$'`
cyclecount=`expr $trimmer % 100 + 1`
if [ "$cyclecount" = "" ]
then
echo '$SOA 7200 countries-ns.mdc.dk. read.the.homepage.at.http.countries.nerd.dk. '$tanggal'00 28800 7200 604800 7200' > result.txt
elif [ $cyclecount -lt 10 ]
then
cyclecount=`echo 0$cyclecount`
echo '$SOA 7200 countries-ns.mdc.dk. read.the.homepage.at.http.countries.nerd.dk. '$tanggal$cyclecount' 28800 7200 604800 7200' > result.txt
else
echo '$SOA 7200 countries-ns.mdc.dk. read.the.homepage.at.http.countries.nerd.dk. '$tanggal$cyclecount' 28800 7200 604800 7200' > result.txt
fi
for i in `cat GeoIPCountryWhois.csv |sed -e 's$ $$g'`
do
a=`echo $i |cut -d ',' -f5 |sed -e 's$"$$g' |tr '[A-Z]' '[a-z]'`
ip1=`echo $i |cut -d ',' -f1 |sed -e 's$"$$g'`
ip2=`echo $i |cut -d ',' -f2 |sed -e 's$"$$g'`
x=`cat isolist.txt |grep $a |sed -e 's|\t|:|g' |cut -d ':' -f2`
if [ "$x" = "" ]
then
continue
fi
y=`echo $i |cut -d ',' -f5 |sed -e 's$"$$g' |tr '[A-Z]' '[a-z]'`
ipconvert=`ipcalc $ip1 - $ip2 |grep -v deaggregate`
countspace=`echo $ipconvert|grep -o ' ' |wc -l`
if [ $countspace = 0 ]
then
echo $ipconvert' :'$x':'$y >> result.txt
else
j=0
countspace=`expr $countspace + 1`
while [ $j -lt $countspace ]
do
k=`expr $j + 1`
echo `echo $ipconvert |cut -d' ' -f$k`' :'$x':'$y >> result.txt
j=`expr $j + 1`
done
fi
done

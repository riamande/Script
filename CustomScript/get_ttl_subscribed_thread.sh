e=0
f=0
mongo kaskus_forum1 --eval "db.thread.find({forum_id:{\$nin:[25,221,220,589,283,615,616,227,264,625,200,266,265,329,195,313,255,254,196,216,302,660,657,658,659,311,215,257,310,197,218,219,296,151,210,527,574,381,573,212,286,287,448,288,202,269,268,553,631,284,603,285,293,605,294,604,299,198,261,231,262,444,606,233,291,590,292,676,317,330,328,318,323,327,321,324,325,319,326,320,322,201,228,607,229,588,205,208,334,209,333,206,207,256,593,295,608,609,298,305,447,446,300,312,303,314,199,223,225,222,614,316,610,611,304,297,612,613,677]},dateline:{\$gte:1418922000,\$lt:1421600400}},{_id:1}).forEach(printjson)" |grep -v MongoDB |grep -v connecting |cut -d'"' -f4 > totalthreadsub1.txt
for i in `cat totalthreadsub1.txt`
do
mongo 172.20.0.242/kaskus_forum1 --eval "db.subscribethread.count({threadid:'$i'})" |grep -v MongoDB |grep -v connecting > countersubscribethread1.txt
g=`cat countersubscribethread1.txt`
e=`expr $e + 1`
f=`expr $f + $g`
h=`expr $f / $e`
echo $e >> countersubscribethreadresult2.txt
echo $f >> countersubscribethreadresult2.txt
echo $g >> countersubscribethreadresult2.txt
echo $h >> countersubscribethreadresult2.txt
done

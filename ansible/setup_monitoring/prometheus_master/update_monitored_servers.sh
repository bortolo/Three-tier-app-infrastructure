#!/bin/sh
temp=""
for server in `cat $1`;
do
    temp=$temp",'"$server":9100'"
done
temp=${temp#?}
echo $temp
echo "Sed start"
sed 's/'"'localhost:9100'"'/'"$temp"'/' <prometheus.yml >prometheus-new.yml
echo "Sed end"

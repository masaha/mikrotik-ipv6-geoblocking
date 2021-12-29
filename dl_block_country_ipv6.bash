#!/bin/bash
#
# Script to download country block lists for geofencing ipv6
#
lists=("https://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/br-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/id-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/in-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/ru-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/th-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/ua-aggregated.zone" "https://www.ipdeny.com/ipv6/ipaddresses/aggregated/za-aggregated.zone")

# Create temporary file and directory
TMPDIR=$(mktemp -d) || exit 1
TMPFILE=$(mktemp) || exit 1

echo "Temp dir: " $TMPDIR
echo "Tmp file: " $TMPFILE
# Download source files

for i in "${lists[@]}"
do
	wget -P $TMPDIR "$i"
done
#
# Make one file 
for files in "$TMPDIR/*"
do
	cat $files >> $TMPFILE
done

# Now add text to beinning and end of each line
# Add to beginning
sed -i -e 's/^/add list=badcountry address=/' $TMPFILE
# Add to the end of each line
# Use dynamic list in MT and set timeout to 6 days, 23 hours and 50 minutes. Adjust if needed
sed -i -e 's/$/ timeout=6d23:50:00 comment=geoblock/' $TMPFILE
# Add header to file
HEADER1=`date +"%Y-%m-%d %T"`
HEADER2="/ipv6 firewall address-list"
sed -i "1i $HEADER2" $TMPFILE
sed -i "1i # Created $HEADER1" $TMPFILE
# 
# Finally copy the file to whereever you want to have it
cp $TMPFILE /home/marko/mt-block/badcountry-ipv6.rsc || exit 1


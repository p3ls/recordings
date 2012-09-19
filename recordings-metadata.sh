#!/bin/bash

f=log
if [ ! -e $f ]; then 
mkdir -p $f 
fi

html=$f/html.meta
flat=$f/flat.meta
flat2=$f/flat2.meta
flat3=$f/flat3.meta
song=$f/song.meta
size=$f/size.meta
head=$f/head.meta
playlist="$f/$1.playlist"
playlist2="$f/$1.playlist2"
has_changed="0"
album_covers='jpg/album_covers'
touch $playlist $playlist2 			# needed fot the first 'cat'

echo "starting playlist routine..."
echo "writing to... $playlist"

count="0"

while [ "1" ] ; do
  curl -s http://www.novaplanet.com/sites/all/modules/novaradio/verifier_infos_player.php -o $html # -D $head
  html2text $html|head -3 > $flat
  imagepath=$(cat $flat|head -1|tail -1|cut -c 3-|cut -d']' -f1)
  imagename=$(echo $imagepath|cut -d'/' -f3)
  
  a=$(cat $flat|head -2|tail -1|cat|sed 's/_/ /g')
  t=$(cat $flat|head -3|tail -1)
  ts=$(date -u "+%s")	# now - universal time(stamp)
  tsn=$(($ts+7200))	# timestamp now in paris --- +2h in seconds
  l="$a;$t"
  last_line=$(cat $playlist|tail -1|cut -d';' -f2,3)


 # prevent from inserting duplicates by comparing last line in playlist with new string
  if [ "$l" != "$last_line" ] ; then   
 #  if [ "$count" = "1" ] ; then
 #   tsn=$(($tsn-10))
     # adjust the first new timestamp a bit, to have it less than script start time
     # we we dont know actually, use little less than the script start time instead  
#  fi
    echo "cover url: $c"
    l="$tsn;$l;$imagename"
    echo $l>>$playlist
     has_changed="1"
  else
    has_changed="0"
  fi
 at="TITLE=$t\nARTIST=$a\n.\n" # for streamripper's cue file
 echo $at>&1




 if [ "$has_changed" = "1" ] ; then  
 ref_time="0"
 echo "converting playlist file into readable format..."
 echo "saving as:        $playlist2"
 while read line ; do							# while 
   time=$(echo "$line"|cut -d';' -f1)
   artist=$(echo "$line"|cut -d';' -f2)
   title=$(echo "$line"|cut -d';' -f3)
   image=$(echo "$line"|cut -d';' -f4)
  if [ "$ref_time" = "0" ] ; then					# set ref time if needed
   ref_time=$(echo "$line\n"|cut -d';' -f1)
  # ref_time=$(($ref_time+55))
   #seconds=$(($time-$ref_time)) 					# adjustment: metadata arrives later than the track  
   #echo "reference time... $ref_time"
   echo "00:00   $artist - $title" > $playlist2
  else
   seconds=$(($time-$ref_time))
   minutes=$(($seconds%3600/60))
   if [ "$minutes" -lt "10" ] ; then
    minutes="0$minutes"
   fi
   secs=$(($seconds%60))
   if [ "$secs" -lt "10" ] ; then
    secs="0$secs"
   fi
   echo "$minutes:$secs   $artist - $title" >> $playlist2
  fi 

 ##########################################

 if [ ! -e "$album_covers/$image" ] ; then 
  curl -s "http://www.novaplanet.com/documents/album_cover/$image" -o "$album_covers/$image" 
 fi



  done < $playlist
  fi






























 sleep 16 # streamrippers interval
done

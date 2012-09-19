#!/bin/bash
#
#

dir='mp3'
log='log'
title='html/index-titles.html'
album='html/index-albums.html'
artist='html/index-artists.html'
track='html/index-tracks.html'
year='html/index-years.html'
time='html/index-times.html'
file='html/index-files.html'
ul='html/index-ul.html'
index='index.html'
index_new='html/index.html'
index_head='html/index-head.html'
index_tail='html/index-tail.html'
index_old='html/index-old.html'
ranges='log/titles-range.csv'
mp3list='log/mp3-list.csv'
echo 'cleaning up temp folders...'
rm -f $title
rm -f $album
rm -f $artist
rm -f $year
rm -f $track
rm -f $time
rm -f $file
rm -f $ul
rm -f $index_new
rm -f $ranges



# list | sort | group
echo 'list all mp3s and generate metadata files from them...'

find $dir -name "*.mp3" | sort -r > $mp3list  			# list all mp3 files, latest first


while read i ; do
 j=$(echo $i | cut -d'/' -f2|cut -d'.' -f1)	 
 id3file="$log/$j.id3"				# generate id3 metadata files  
 eyeD3 --no-color $i > $id3file
 mkdir -p "$log/$j"
 echo "write embedded images to...$log/$j"
 eyeD3 -i "$log/$j" $i
 cp "$log/$j/FRONT_COVER.jpeg" "jpg/final_covers/$j.jpg"
done < $mp3list 



echo 'loop through metadata files...'


while read i ; do
 n=$(echo $i | cut -d'/' -f2|cut -d'.' -f1)
 csv="$log/$n.csv" 
 id3file="$log/$n.id3"
 echo "reading id3 file... $id3file"
 cover_image="jpg/album_covers/null.jpg"
 generated_cover="jpg/final_covers/$n.jpg"

 if [ -e "$generated_cover"  ] ; then
  cover_image=$generated_cover
 fi 

 art=""
 tit=""
 alb=""
 yea=""
 tim=""
 lyr=""
 


 rm -f "$log/$n.lyr"

 while read j ; do
  ltitle=$(echo $j | grep title)				# TITLE
   if [ "$ltitle" != "" ] ; then 
    tit=$(echo $j | cut -d':' -f2) 
    titcc=$(echo $tit|wc -m)
    titcc=$(($titcc-7))
    tit=$(echo $tit|cut -c -$titcc|cut -c 1-)	  			
    art=$(echo $j | cut -d':' -f3|cut -c 2-) 	  			# ARTIST
   fi

  ltime=$(echo $j | grep Time)					# TIME
   if [ "$ltime" != "" ] ; then 
    tim=$(echo $j | cut -d' ' -f2)
   fi


  lya=$(echo $j | grep album)				# YEAR
   if [ "$lya" != "" ] ; then 				# ALBUM
    alb=$(echo $j | cut -d':' -f2) 
    albcc=$(echo $alb|wc -m)
    albcc=$(($albcc-5))
    alb=$(echo $alb|cut -c -$albcc|cut -c 1-)	  			
    yea=$(echo $j | cut -d':' -f3|cut -c 2-) 	  			# ARTIST
   fi

  lyr=$(echo $j | grep '^[0-9]')					# LYRICS
   if [ "$lyr" != "" ] ; then 
    echo $lyr >> "$log/$n.lyr"
    else
     lyr=""
    #alb=$(echo $j | cut -d' ' -f2) 
   fi  				# ALBUM
  # if [ "$alb" != "" ] ; then 
    #alb=$(echo $j | cut -d' ' -f3)    
   #fi

 done < $id3file
    
  							# CORRECTIONS
  if [ "$tit" = "" ] ; then
   tit=$n
   tit=$(echo $tit | cut -d'.' -f1 | sed 's/-/ /g' | sed 's/_/ /g')
  fi

  echo "" >> "$log/$n.lyr"


    echo "title: $tit"
    echo "artist: $art"
    echo "time : $tim" 
    echo "year : $yea" 
    echo "album : $alb"
    echo "lyrics:"
    cat "$log/$n.lyr" 

 echo "<li>" >> $ul
 echo "<a href=\"#\"><img src=\"$cover_image\" width=\"100px\" height=\"100px\" alt=\"Cover image\" class=\"img_left\"></a>" >> $ul
 echo "<div class=\"article\">" >> $ul
 echo "<p class=\"text_article\">$art</p>" >> $ul
 echo "<p class=\"title_article\">$alb</p>" >> $ul
 echo "<p class=\"title_article\">$tit</p>" >> $ul
 echo "<p class=\"text_article\">$tim</p>" >> $ul
 echo "<p class=\"text_article\">&nbsp; &nbsp;<br>" >> $ul
 echo "<audio controls src=\"mp3/$n.mp3\"></audio>" >> $ul
 echo "</p>" >> $ul

# if [ "$lyr" != "" ] ; then 
  echo "<p class=\"text_article\">" >> $ul
   numlyr=$(cat "$log/$n.lyr" | wc -l)
   numlyr=$(($numlyr-1))
   a="1"
   while read i ; do
    #echo "numlyr: $numlyr a: $a"
    if [ "$numlyr" = "$a" ] ; then
    # echo "got end."
     echo "$i" >> $ul 
     break
    else
     echo "$i<br>" >> $ul
    fi 
    a=$(($a+1))
   done < "$log/$n.lyr" 
  echo "</p>" >> $ul
  echo '<br>' >> $ul
  echo "<a title=\"Download\" class=\"button right_download\" href=\"mp3/$n.mp3\">" >> $ul
  echo "<span class=\"before\"></span>Download<span class=\"after\"></span>" >> $ul
  echo "</a>" >> $ul
  echo '<br><br>' >> $ul
  echo "</div>" >> $ul
  echo "<div class=\"separator\"></div>" >> $ul
  echo "</li>" >> $ul
 done < $mp3list

echo "wrote entries file to... $ul"
echo "concat + copy files..."

cat $index_head >> $index_new
cat $ul >> $index_new
cat $index_tail >> $index_new

#cat $index_new

cp $index $index_old
cp $index_new $index


while read i ; do
 j=$(echo $i | cut -d'/' -f2|cut -d'.' -f1)	 
 rm -Rif "$log/$j"
done < $mp3list 

echo 'finished. index.html generated.'
exit 0

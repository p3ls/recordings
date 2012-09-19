#!/bin/bash
#
######################### reading config ######################
###############################################################

if [ -z $1 ] ; then echo 'pass a conf file as argument. exit.'; exit 0; fi

echo "contents of config file: $1"


name='P1 REVERSE'
url='http://www.paris-one.com/pls/radio_v6.m3u'
length_in_min=60
expected_kbs=128
metafile='' # comes through stream in cue sheet recordings-metadata.sh'
log='log' # dep
logdir='log'
playlist='log/playlist.csv' # dep
playlist_file="log/playlist-file.csv" # dep
coverdir="jpg/final_covers"
cover_image="jpg/album_covers/null.jpg" #dep use front_cover
front_cover="jpg/album_covers/null.jpg"
destination_dir='mp3' #dep
destdir='mp3' # dep, use mp3dir
mp3dir='mp3'
id3_artist='www.paris-one.com'
id3_year='2012'
type='aac'


title=''
base_dir=''
stream_dir='audio'
cover_dir='img'
log_dir='log'
stream_format=''
stream_url=''
cover_url=''
cover_path=''
station_url=''
metadata_script=''
length_in_minutes=''

# iterating lines in config file.

while read i ; do
 
  j=$(echo $i|cut -d'=' -f1)
 
 #echo $j

 # found title in config file
 # create lower case project folder
 # create upper case station title
 if [ "$j" = "title" ] ; then
  base_dir=$(echo $i|cut -d'=' -f2|sed 's/ /-/g'| tr '[:upper:]' '[:lower:]')
  title=$(echo $i|cut -d'=' -f2|sed 's/-/ /g'| tr '[:lower:]' '[:upper:]')
 fi


 if [ "$j" = "stream_url" ] ; then
  stream_url=$(echo $i|cut -d'=' -f2)
 fi

 if [ "$j" = "stream_format" ] ; then
  stream_format=$(echo $i|cut -d'=' -f2)
 fi


 if [ "$j" = "cover_url" ] ; then
  cover_url=$(echo $i|cut -d'=' -f2)
  format=$(echo $cover_url|cut -d'.' -f4)  
  cover_path="$base_dir/$cover_dir/null.$format"
 fi

 if [ "$j" = "station_url" ] ; then
  station_url=$(echo $i|cut -d'=' -f2)
 fi

 if [ "$j" = "metadata_script" ] ; then
  metadata_script=$(echo $i|cut -d'=' -f2)
 fi


 if [ "$j" = "length_in_minutes" ] ; then
  length_in_minutes=$(echo $i|cut -d'=' -f2)
 fi


done < $1








echo 'summary:'
echo ''
echo "base_dir        : $base_dir"
echo "stream_dir      : $base_dir/$stream_dir"
echo "cover_dir       : $base_dir/$cover_dir"
echo "log_dir         : $base_dir/$log_dir"
echo "stream_format   : $stream_format"
echo "stream_url      : $stream_url"
echo "cover_url       : $cover_url"
echo "cover_path      : $cover_path"
echo "station_url     : $station_url"

echo ''


exit 0














# id3_album is MONTH XY
# id3_title is FROM TIME TO TIME 
###############################################################
####################### HERE ##################################	
###############################################################
u='UTF-8'
# 10 = debug 
ed=$(($length_in_min*60)) # expected duration in seconds
fd=""			  # final duration of file (measured)
cut="" # dep, use mp3cut_str 
mp3cut_str=""

if [ ! -e "$type/" ] ; then mkdir $type; fi

echo 'cleaning up previous temp files...'
echo "delete everything in $logdir" 
for file in $(find $logdir -name '*.*') ; do
 rm -Rif $file
done  

echo 'cleaning up cue sheets...'
for file in $(find $mp3dir -name '*.cue') ; do
 rm -f $file
done  


for i in 1 2 3 ; do
 ts=$(date -u "+%s")	# now - universal time
 tsn=$(($ts+7200))	# timestamp now in paris --- +2h in seconds
 tse=$(($tsn+$ed))	# expected timestamp at the end of file
 tsf=0			# final timestamp for the end of file 	
 ta=$(date -u -d "1970-01-01 $tsn sec" "+%Y-%m-%d %HH%M")
 taa=$(date -u -d "1970-01-01 $tsn sec" "+%HH%M")
 tb=$(date -u -d "1970-01-01 $tse sec" "+%HH%M")
 filename="$name $ta TO $tb"
 f2=$(echo $filename|sed 's/ /_/g') # deprecated, use filename2 instead
 filename2=$(echo $filename|sed 's/ /_/g')
 f3='' # deprec. 
 filename3='' # used for generated part files filename (1).mp3
 playlist="$logdir/$filename2.playlist"
 playlist2="$logdir/$filename2.playlist2"
 echo "start recording         : #$i $name"
 echo "time                    : $ta ($tsn)"
 echo "expected end            : $tb"
 echo "expected length         : $length_in_min min"
 #echo "writing playlist to     : $playlist2" 
#./recordings-metadata.sh $filename2 &
 echo "writing stream to       : $mp3dir/$filename2.mp3"
#streamripper $url --quiet -d $destination_dir -a $filename2 -A -l $ed --codeset-metadata=$u --codeset-filesys=$u --codeset-id3=$u --xs-offset=500

#       -A             - Don't write individual tracks
#      -L file        - Create a relay playlist file
#      -l seconds     - Number of seconds to run, otherwise runs forever

#--codeset-filesys=UTF-8 --codeset-id3=ISO-8859-15 --codeset-metadata=ISO-8859-15 --codeset-relay=ISO-8859-15

# cuetools:
# * Apply offset correction to a rip made without offset correction

# Convert text ISO to UTF-8
#     iconv --from-code=ISO-8859-1 --to-code=UTF-8 iso.txt > utf.txt

# cueprint
#EXAMPLES

 #      To display disc and track information (using the default  template  for
 #      both):

  #     % cueprint album.cue

   #    To print the number of tracks in a CUE file:

    #   % cueprint -d '%N\n' album.cue

# printf "Surname: %s\nName: %s\n" "$SURNAME" "$LASTNAME"





#iconv --from-code=ISO-8859-1 --to-code=UTF-8 BASSTUNE_2012-09-11_00H38_TO_00H48.cue > cue-utf.txt

streamripper $url -d $mp3dir -a $filename2 -A -l $ed --codeset-filesys=UTF-8 --codeset-id3=ISO-8859-15 --codeset-metadata=ISO-8859-15 --codeset-relay=ISO-8859-15 # --codeset-metadata=$u --codeset-filesys=$u --codeset-id3=$u

 echo "convert cuesheet into textfile"
 cuesheet=$(cat "$mp3dir/$filename2.cue") 
 printf "%s\n" "$cuesheet" | tr '[:lower:]' '[:upper:]' > "$mp3dir/$filename2.txt"

 #m=$(echo $m |tr '[:lower:]' '[:upper:]') # make all lowercase chars upper in month name


 echo "recording finished."
 echo "cleaning up..."
 echo "searching part files..."
 
 for j in 1 2 3 4 5 6 ; do		 # - number of part files
  b="$f2 ($j)"
  c="$mp3dir/$b.mp3"
  echo "searching for... $c"
   if [ -e "$c" ]; then
    echo "part file found... $c"
    f3=$(echo $c|sed 's/ /-/g')
    mv "$c" "$f3"
    echo "renamed to... $f3" # needed to have no whitespace in it    
    dd="-t 00:00 $f3"
    echo "string for mp3cut to add... "
    echo "$dd"
    cut="$cut $dd"	
   fi
 done 					# - number of part files
 if [ "$cut" = "" ]; then
  echo "no parts found."
 else
  cut="-o $mp3dir/$filename2.join.mp3 $cut -t 00:00 $mp3dir/$filename2.mp3" # add the original file, as last part for joining
  echo "join part files together in... $mp3dir/$filename2.mp3"  
  echo "final mp3cut string:"
  echo "$cut"
  mp3cut $cut
  sleep 1
  cut="" # reset
  rm -f "$destdir/$filename2-(1).mp3"
  rm -f "$destdir/$filename2-(2).mp3"
  rm -f "$destdir/$filename2-(3).mp3"
  rm -f "$destdir/$filename2-(4).mp3"
  rm -f "$destdir/$filename2-(5).mp3"
  rm -f "$destdir/$filename2-(6).mp3"
  rm -f "$destdir/$filename2.mp3"
  mv "$destdir/$filename2.join.mp3" "$destdir/$filename2.mp3"

 fi # if needs to join
  echo "adding id3 information to it..."
 m=$(date "+%B")
 d=$(date "+%d")
 m=$(echo $m |tr '[:lower:]' '[:upper:]') # make all lowercase chars upper in month name
 id3_playlist=$(cat $playlist2)
 id3_album="$m $d"
 id3_title="$taa TO $tb"

 #echo 'start cover generator...'
 #./recordings-cover.sh $f2

 #cover_path="$coverdir/$f2.jpg"
 #if [ -e $cover_path ] ; then 
 # echo 'generated cover found...' 
 # cover_image=$cover_path
 #fi
 
 echo "writing id3 tags..."

 echo "album   : $id3_album" # > "$log/$filename2.id3.album"
 echo "title   : $id3_title" # > "$log/$filename2.id3.title"
 echo "artist  : $id3_artist" # > "$log/$filename2.id3.artist"
 echo "year    : $id3_year" # > "$log/$filename2.id3.year"
 echo "cover   : $cover_image"
 #echo "playlist: $id3_playlist"

 eyeD3  -Y "$id3_year" -A "$id3_album" -t "$id3_title" -a "$id3_artist" --remove-all --add-image=$cover_image:FRONT_COVER: "$destdir/$filename2.mp3" 

 echo "tags set."

 echo 'generating index.html...'

 ./recordings-indexpage.sh

 echo "#$i complete."
done 									# for - number of recordings
echo "total recording finished."



#!/bin/bash
#
######################### reading config ######################
###############################################################

if [ -z $1 ] ; then echo 'pass a conf file as argument. exit.'; exit 0; fi

echo "contents of config file: $1"


#name='P1 REVERSE'
#url='http://www.paris-one.com/pls/radio_v6.m3u'
#length_in_min=60
#expected_kbs=128
#metafile='' # comes through stream in cue sheet recordings-metadata.sh'
#log='log' # dep
#logdir='log'
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
stream_dir=''
cover_dir=''
log_dir=''
stream_format=''
stream_url=''
cover_url=''
cover_path=''
station_url=''
metadata_script=''
length_in_minutes=''

playlist="$log_dir/playlist.csv" # dep
playlist_file="$log_dir/playlist-file.csv" # dep


# iterating lines in config file.

while read i ; do
 
  j=$(echo $i|cut -d'=' -f1)
 
 #echo $j

 # found title in config file
 # create lower case project folder
 # create upper case station title

 if [ "$j" = "stream_format" ] ; then
  stream_format=$(echo $i|cut -d'=' -f2)
 fi


 if [ "$j" = "title" ] ; then title=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "stream_url" ] ; then stream_url=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "stream_format" ] ; then stream_format=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "stream_dir" ] ; then stream_dir=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "cover_dir" ] ; then cover_dir=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "log_dir" ] ; then log_dir=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "station_url" ] ; then station_url=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "custom_metadata_script_path" ] ; then custom_metadata_script_path=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "length_per_session_in_min" ] ; then length_per_session_in_min=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "cover_path" ] ; then cover_path=$(echo $i|cut -d'=' -f2) ; fi
 if [ "$j" = "number_of_sessions" ] ; then number_of_sessions=$(echo $i|cut -d'=' -f2) ; fi



done < $1








echo 'summary:'
echo ''
echo "title             : $title"
echo "stream_dir        : $stream_dir"
echo "cover_dir         : $cover_dir"
echo "log_dir           : $log_dir"
echo "stream_format     : $stream_format"
echo "stream_url        : $stream_url"
echo "cover_path        : $cover_path"
echo "station_url       : $station_url"
echo "length_per_sessio : $length_per_session_in_min"
echo "metadata_script   : $custom_metadata_script_path"


echo ''

















# id3_album is MONTH XY
# id3_title is FROM TIME TO TIME 
###############################################################
####################### HERE ##################################	
###############################################################
u='UTF-8'
# 10 = debug 
ed=$(($length_per_session_in_min*60)) # expected duration in seconds
fd=""			  # final duration of file (measured)
cut=""            # dep, use mp3cut_str 
mp3cut_str=""

#if [ ! -e "$type/" ] ; then mkdir $type; fi

echo 'cleaning up previous temp files...'
echo "delete everything in $logdir" 
for file in $(find $log_dir -name '*.*') ; do
 rm -Rif $file
done  

echo 'cleaning up cue sheets...'
for file in $(find $stream_dir -name '*.cue') ; do
 rm -f $file
done  

#exit 0

for i in 1 2 3 ; do
 ts=$(date -u "+%s")	# now - universal time
 tsn=$(($ts+7200))	# timestamp now in paris --- +2h in seconds
 tse=$(($tsn+$ed))	# expected timestamp at the end of file
 tsf=0			# final timestamp for the end of file 	
 ta=$(date -u -d "1970-01-01 $tsn sec" "+%Y-%m-%d %HH%M")
 taa=$(date -u -d "1970-01-01 $tsn sec" "+%HH%M")
 tb=$(date -u -d "1970-01-01 $tse sec" "+%HH%M")
 title=$(echo $title|sed 's/ /-/g')
 filename="$title $ta TO $tb"
 f2=$(echo $filename|sed 's/ /_/g') # deprecated, use filename2 instead
 filename2=$(echo $filename|sed 's/ /_/g')
 f3='' # deprec. 
 filename3='' # used for generated part files filename (1).mp3
 playlist="$log_dir/$filename2.playlist"
 playlist2="$log_dir/$filename2.playlist2"
 echo "start recording         : #$i $title"
 echo "time                    : $ta ($tsn)"
 echo "expected end            : $tb"
 echo "expected length         : $length_per_session_in_min min"
 echo "writing stream to       : $stream_dir/$filename2.$stream_format"
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



#break;

#iconv --from-code=ISO-8859-1 --to-code=UTF-8 BASSTUNE_2012-09-11_00H38_TO_00H48.cue > cue-utf.txt

if [ "$custom_metadata_script_path" = "" ] ; then
 streamripper $stream_url -d $stream_dir -a $filename2 -A -l $ed --codeset-filesys=UTF-8 --codeset-id3=ISO-8859-15 --codeset-metadata=ISO-8859-15 --codeset-relay=ISO-8859-15
else
 streamripper $stream_url -d $stream_dir -E "sh $custom_metadata_script_path" -a $filename2 -A -l $ed --codeset-filesys=UTF-8 --codeset-id3=ISO-8859-15 --codeset-metadata=ISO-8859-15 --codeset-relay=ISO-8859-15
fi

 echo "convert cuesheet into textfile"
 cuesheet=$(cat "$stream_dir/$filename2.cue") 
 printf "%s\n" "$cuesheet" | tr '[:lower:]' '[:upper:]' > "$stream_dir/$filename2.txt"

 #m=$(echo $m |tr '[:lower:]' '[:upper:]') # make all lowercase chars upper in month name


 echo "recording finished."
 echo "cleaning up..."
 echo "searching part files..."
 
 if [ "$stream_format" = "mp3" ] ; then

 for j in 1 2 3 4 5 6 ; do		 # - number of part files
  b="$f2 ($j)"
  c="$stream_dir/$b.mp3"
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
  cut="-o $stream_dir/$filename2.join.mp3 $cut -t 00:00 $stream_dir/$filename2.mp3" # add the original file, as last part for joining
  echo "join part files together in... $stream_dir/$filename2.mp3"  
  echo "final mp3cut string:"
  echo "$cut"
  mp3cut $cut
  sleep 1
  cut="" # reset
  rm -f "$stream_dir/$filename2-(1).mp3"
  rm -f "$stream_dir/$filename2-(2).mp3"
  rm -f "$stream_dir/$filename2-(3).mp3"
  rm -f "$stream_dir/$filename2-(4).mp3"
  rm -f "$stream_dir/$filename2-(5).mp3"
  rm -f "$stream_dir/$filename2-(6).mp3"
  rm -f "$stream_dir/$filename2.mp3"
  mv "$stream_dir/$filename2.join.mp3" "$stream_dir/$filename2.mp3"

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

 eyeD3  -Y "$id3_year" -A "$id3_album" -t "$id3_title" -a "$id3_artist" --remove-all --add-image=$cover_image:FRONT_COVER: "$stream_dir/$filename2.mp3" 

 echo "tags set."


 
 fi
 


 echo 'generating index.html...'

 ./recordings-indexpage.sh

 echo "#$i complete."
done 									# for - number of recordings
echo "total recording finished."



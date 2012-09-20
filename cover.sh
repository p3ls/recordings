#!/bin/bash
# copy up to 4 images in folder and generate a tile - 2x2 montage

basename=$1
logdir='log'
srcdir='jpg/album_covers'
destdir='jpg/final_covers'
imagename="$basename.jpg"
imagepath="$destdir/$imagename"
playlist="$logdir/$basename.playlist"

for file in $(find $logdir -name '*.jpg') ; do rm -f $file; done 
if [ ! -e $playlist ]; then echo "playlist file not found. exit." exit 1; fi
if [ ! -e $srcdir ]; then exit 1; fi
if [ ! -e $destdir ]; then mkdir -p $destdir; fi # ; else # create if dest is missing
# for file in $(find $destdir -name '*.jpg') ; do rm -f $file; done # 
# fi

cp "$srcdir/null.jpg" "$logdir/null.jpg"

i=0
while read line ; do
 name=$(echo $line|cut -d';' -f4)
 echo $name
 if [ "$name" != "null.jpg" ] ; then i=$(($i+1)) ; fi
  cp "$srcdir/$name" "$logdir/$name" 
 if [ "$i" = "3" ] ; then break ;  fi
done < $playlist

 if [ "$i" > "3" ]; then
  exit 0 # no cover if less than 3 different ones
 fi

montage -thumbnail '100x100' -geometry '+2+2' -tile '2x2' "$logdir/*.jpg" "$imagepath"

exit 0


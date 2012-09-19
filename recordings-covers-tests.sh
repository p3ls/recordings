#!/bin/bash

#geometry='+6+6'

# copy 4 images in folder and generate a montage

srcdir='jpg/album_covers'
destdir='jpg/album_covers/4x4'

if [ ! -e $srcdir ]; then exit 1; fi
if [ ! -e $destdir ]; then mkdir -p $destdir; else
for file in $(find $destdir -name '*.jpg') ; do rm -f $file; done 
fi

cp "$srcdir/null.jpg" "$destdir/null.jpg"

i=0
for file in $(find $srcdir -name '*.jpg' | sort -R) ; do
 name=$(echo $file|cut -d'/' -f3)
 if [ "$name" != "null.jpg" ] ; then i=$(($i+1)) ; fi
 cp "$file" "$destdir/$name" 
 if [ "$i" = "3" ] ; then break ;  fi
done 

montage -thumbnail 100x100 -geometry +2+2 -tile 2x2 $destdir/*.jpg montage-thumbs-2x2.jpg

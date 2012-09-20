#!/bin/bash

if [ -z $1 ] ; then echo 'pass a conf file as argument. exit.'; exit 0; fi

# echo "contents of config file: $1"

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
custom_metadata_script_path=''
length_per_session_in_min=''
config_file=$1
number_of_sessions=''

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
  echo "creating directory... $base_dir"
  mkdir $base_dir 
  mkdir "$base_dir/$stream_dir" 
  mkdir "$base_dir/$log_dir"
  mkdir "$base_dir/$cover_dir"  
 fi


 if [ "$j" = "stream_url" ] ; then
  stream_url=$(echo $i|cut -d'=' -f2)
  echo "testing stream... $url"
  streamripper $stream_url --quiet -d $base_dir -a "test" -A -l 3

  if [ -e "$base_dir/test.aac" ] ; then
   echo "stream is in aac format."
   stream_format='aac'
   rm "$base_dir/test.aac" 
  fi

  if [ -e "$base_dir/test.mp3" ] ; then
   echo "stream is in mp3 format."
   stream_format='mp3'
   rm "$base_dir/test.mp3"
  fi

  rm "$base_dir/test.cue"

  
 fi

 if [ "$j" = "cover_url" ] ; then
  cover_url=$(echo $i|cut -d'=' -f2)
  format=$(echo $cover_url|cut -d'.' -f4)
  
  cover_path="$base_dir/$cover_dir/null.$format"
  echo "downloading cover to... $cover_path"
  curl -o $cover_path $cover_url
 fi

 if [ "$j" = "station_url" ] ; then
  station_url=$(echo $i|cut -d'=' -f2)
  echo "station url: $station_url"
 fi

 if [ "$j" = "custom_metadata_script_path" ] ; then
  custom_metadata_script_path=$(echo $i|cut -d'=' -f2)
  echo "custom_metadata_script_path: $custom_metadata_script_path"
 fi


 if [ "$j" = "length_per_session_in_min" ] ; then
  length_per_session_in_min=$(echo $i|cut -d'=' -f2)
  echo "length_per_session_in_min: $length_per_session_in_min"
 fi


 if [ "$j" = "number_of_sessions" ] ; then
  number_of_sessions=$(echo $i|cut -d'=' -f2)
  echo "number_of_sessions: $number_of_sessions"
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


echo 'creating extended config file. is later used by other scripts.'

echo "title=$title" > "$config_file"
echo "base_dir=$base_dir" >> "$config_file"
echo "stream_dir=$base_dir/$stream_dir" >> "$config_file"
echo "cover_dir=$base_dir/$cover_dir" >> "$config_file"
echo "log_dir=$base_dir/$log_dir" >> $config_file
echo "stream_format=$stream_format" >> $config_file
echo "stream_url=$stream_url" >> $config_file
echo "cover_url=$cover_url" >> $config_file
echo "cover_path=$cover_path" >> $config_file
echo "station_url=$station_url" >> $config_file
echo "number_of_sessions=$number_of_sessions" >> $config_file
echo "length_per_session_in_min=$length_per_session_in_min" >> $config_file
echo "custom_metadata_script_path=$metadata_script" >> $config_file

echo 'finish.'

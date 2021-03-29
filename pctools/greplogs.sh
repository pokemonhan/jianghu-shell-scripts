#!/bin/sh
dir=/d/log/;
word="sendCode: error:"
FILES="$dir*"
for f in $FILES
do
  # echo "Processing $f file..."
  out="$(basename $f)"
  echo "Filename is $out"
  grep --text -i -e "$word" $f > "$dir$out-Selected.log";
  # take action on each file. $f store current file name
done
echo Press Enter...
read

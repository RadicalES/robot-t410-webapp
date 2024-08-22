#!/bin/bash
# list files in a directory. Please not that it needs for Bash
printf "Content-Type: text/html\r\n"
printf "\r\n"

echo "<p>List of files in </strong><code>/</code></p>"

files=($(ls /))

for file in "${files[@]}"
do
echo "<code>$file</code><br>"
done
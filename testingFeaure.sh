#!/bin/bash

line=$(head -n 1 "username.csv")

echo "$line"

awk -F',' '{ for( i=1; i<=NF; i++ ) print $i }' <<<"$line"

exit 1

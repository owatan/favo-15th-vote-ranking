#!/usr/local/bin/bash

tmp=$(mktemp)
trap "rm -f ${tmp}" 0 1 2 3 15

list="__YOUR_DIRECTORY__/list.txt"
ranking="__YOUR_DIRECTORY__/favo.txt"
url="http://www.favo.co.jp/cgi/15th_vote/votelist.cgi"

# header
date="$(date "+%Y/%m/%d %H:%M")\t$(date +%s)"

cat ${list} | while read l; do
  next=1

  while :; do
    count=$(curl -sX POST \
      -d "next=${next}" \
      -d "SearchItem=${l}" \
      -d "pre=送信" \
      ${url} | grep "<td>${l}</td>" | wc -l | cut -f 1)

    if [ ${count} -eq 30 ]; then
      next=$(( ${next} + 30 ))
    else
      count=$(( ${next} + ${count} - 1))
      break
    fi
  done

  echo ${count} >> ${tmp}
done

echo -e "${date}\t$(cat ${tmp} | tr '\n' '\t' | sed "s/${IFS:1:1}$//")" >> ${ranking}

import os
from nre import re, match
import options
import strutils

import register.parser
import register.translit
import hugo.mdcontent

proc html2md(html: string): string =
  return html
    .replace("<br>", "\n\n")

# echo($ord(' '))

let contentDir = "../davojan.ru/register/txt"

let pattern = re"\d\d\.\d\d\.\d\d\d\d\.txt"

echo("Scanning register content directory")

for kind, path in walkDir(contentDir):
  let fileName = path.extractFilename
  # echo(kind, ", ", fileName)

  if fileName.match(pattern).isSome:
    let parts = fileName.split('.')
    let date = "$#-$#-$#".format(parts[2], parts[1], parts[0])

    let fileContents = readFile(path)
    # echo fileContents
    let entries = fileContents.split("<entry>")

    for entry in entries:
      if entry != "":
        let entryInfo = parseEntry(entry)

        let keyworldsStr =
          if entryInfo.keywords.len > 0:
            "categories = [\"$1\"]".format(entryInfo.keywords.join("\", \""))
          else:
            ""
        echo """
+++
date = "$1T$2+03:00"
title = "$3"
slug = $4
$5
+++

$6
"""     .format(
          date,
          entryInfo.time.get("12:00"),
          entryInfo.subject,
          translitTitle(entryInfo.subject),
          keyworldsStr,
          entryInfo.text.get("").html2md
        )




    # break

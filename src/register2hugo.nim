import os
from nre import re, match
import options
import strutils

import register.parser
import register.translit
import hugo.mdcontent

const contentDir = "../davojan.ru/register/txt"
const sectionDir = "../davojan.ru/content/blog"

let pattern = re"\d\d\.\d\d\.\d\d\d\d\.txt"

echo("Scanning register content directory")

for kind, path in walkDir(contentDir):
  let fileName = path.extractFilename

  if fileName.match(pattern).isSome:
    let parts = fileName.split('.')
    let date = "$#-$#-$#".format(parts[2], parts[1], parts[0])
    let year = parts[2]

    let fileContents = readFile(path)
    let entries = fileContents.split("<entry>")

    for entry in entries:
      if entry != "": # ignore first
        let entryInfo = parseEntry(entry)
        let slug = translitTitle(entryInfo.subject)

        let hugoContent = createHugoContent(
          entryInfo.subject,
          entryInfo.text.get(""),
          date, entryInfo.time.get("12:00"),
          slug,
          entryInfo.keywords
        )

        saveHugoContentFile(
          hugoContent,
          sectionDir,
          date, year, slug
        )

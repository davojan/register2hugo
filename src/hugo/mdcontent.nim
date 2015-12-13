import strutils
from os import `/`, createDir

proc html2md(html: string): string =
  return html
    .replace("<br>", "\n\n")
    .replace("<cut>", "<!--more-->")


const hugoContentTemplate = """
+++
date = "$1T$2:00+03:00"
title = "$3"
slug = "$4"$5
+++

$6
"""


proc createHugoContent*(title, text, date, time, slug: string, keywords: seq[string]): string =
  ## Composes Hugo content file contents with TOML front matter
  let keyworldsStr =
    if keywords.len > 0:
      "\ncategories = [\"$1\"]".format(keywords.join("\", \""))
    else:
      ""

  return hugoContentTemplate.format(
    date,
    time,
    title,
    slug,
    keyworldsStr,
    text.html2md
  )


proc saveHugoContentFile*(content, sectionDir, date, year, slug: string) =
  ## Saves given hugo markdown content to the right place based on the date and slug
  let yearDir = sectionDir / year
  let filePath = yearDir / date & "-" & slug & ".md"
  createDir(yearDir)
  echo " saving ", filePath
  writeFile(filePath, content)

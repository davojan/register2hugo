import strutils, nre, options
from os import `/`, createDir


proc fixBlockquotes(html: string): string =
  ## replaces html blockquote formatting with markdown formatting
  let pattern = "(*CRLF)(?m)(?U)<blockquote>(.+)</blockquote>".re
  let matches = html.findAll(pattern)
  result = html
  for quoteContent in matches:
    let fixed = quoteContent
      .replace("\n", "\n> ")
      .replace("<blockquote>", "\n\n> ")
      .replace("</blockquote>", "\n\n")
    result = result.replace(quoteContent, fixed)


proc cleanHtml(html: string): string =
  ## Removes some html tags and replaces &nbsp; with regular space
  html
    .replace("&nbsp;", " ")
    .replace("<b>", "").replace("</b>", "")
    .replace("<i>", "").replace("</i>", "")
    .replace("<tt>", "").replace("</tt>", "")
    .replace("<p>", "").replace("</p>", "")


proc fixCodeBlocks(html: string): string =
  ## replaces multiline code blocks with hugo formatted version
  let pattern = "(*CRLF)(?m)(?U)\n<code>(.+)</code>(\n|,)".re
  let matches = html.findAll(pattern)
  result = html
  for codeContent in matches:
    let cleaned = codeContent
      .cleanHtml
      .replace("\n\n", "\n")
      .replace("\n<code>", "\n{{< highlight c \"linenos=1\" >}}\n")
      .replace("</code>\n", "\n{{< /highlight >}}\n")
      .replace("</code>,", "\n{{< /highlight >}}\n")
    result = result.replace(codeContent, cleaned)


proc fixCodeInlines(html: string): string =
  ## replaces inline code blocks with hugo formatted version
  let pattern = "(?U)<code>(.+)</code>".re
  let matches = html.findAll(pattern)
  result = html
  for codeContent in matches:
    let cleaned = codeContent
      .cleanHtml
        .replace("<code>", "``")
      .replace("</code>", "``")
    result = result.replace(codeContent, cleaned)


proc html2md(html: string): string =
  return html
    .replace("<br>", "\n\n")
    .replace("<cut>", "<!--more-->")
    .fixBlockquotes
    .fixCodeBlocks
    .fixCodeInlines


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

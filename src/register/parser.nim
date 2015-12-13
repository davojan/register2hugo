import nre, options, strutils


type EntryInfo = tuple
  time: Option[string]
  subject: string
  text: Option[string]
  keywords: seq[string]
  commentCount: int


proc parseTag(entry: string, tagName: string): Option[string]
proc cleanUpTitle(title: string): string


proc parseEntry*(entry: string): EntryInfo =
  ## Parses register blog entry tags and returns according tuple
  return (
    entry.parseTag("time"),
    entry.parseTag("subj").get.cleanUpTitle,
    entry.parseTag("text"),
    entry.parseTag("keywords").get("").split(","),
    entry.parseTag("posts").get("0").parseInt
  )


proc parseTag(entry: string, tagName: string): Option[string] =
  ## extracts the given tag inner contents from the given html/xml string
  let pattern = "<$1>(.+)</$2>".format(tagName, tagName).re
  let matches = entry.find(pattern)
  if matches.isSome:
    return some(matches.get.captures[0])
  else:
    return none(string)


proc cleanUpTitle(title: string): string =
  ## Removes html tags and replaces html entities added by Register enging to titles
  result = title
    .replace(" <nobr>", " ") # invalid space \xc2
    .replace("<nobr>", "")
    .replace("</nobr>", "")
    .replace(" &nbsp;", " ") # invalid space \xc2
    .replace("&nbsp;", " ")
    .replace("&laquo;", "«")
    .replace("&raquo;", "»")
    .replace("&hellip;", "…")
    .replace("&#151;", "—")

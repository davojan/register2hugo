import strutils, unicode, strtabs

let translitMap = newStringTable(
  "а", "a",
  "б", "b",
  "в", "v",
  "г", "g",
  "д", "d",
  "е", "e",
  "ё", "yo",
  "ж", "zh",
  "з", "z",
  "и", "i",
  "й", "j",
  "к", "k",
  "л", "l",
  "м", "m",
  "н", "n",
  "о", "o",
  "п", "p",
  "р", "r",
  "с", "s",
  "т", "t",
  "у", "u",
  "ф", "f",
  "х", "h",
  "ц", "tc",
  "ч", "ch",
  "ш", "sh",
  "щ", "sch",
  "ъ", "'",
  "ы", "y",
  "ь", "'",
  "э", "e",
  "ю", "yu",
  "я", "ya",
  modeCaseInsensitive
)

proc utf8Translit(input: string): string =
  result = ""
  for char in input.runes:
    let lower = $(char.toLower)
    if translitMap.hasKey(lower):
      result &= translitMap[lower]
    else:
      result &= lower


proc slugify(input: string): string =
  ## Removes special chars and replaces spaces with dashes
  ## Such conversion is useful for slugs used in URLs
  result = ""
  for char in input:
    case char
    of ' ': result &= "-"
    of 'a'..'z', '0'..'9': result &= $char
    else: discard
  return result
    .strip(chars = {'-'})
    .replace("--", "-")


proc translitTitle*(russianTitle: string): string =
  return russianTitle
    .utf8Translit
    .slugify

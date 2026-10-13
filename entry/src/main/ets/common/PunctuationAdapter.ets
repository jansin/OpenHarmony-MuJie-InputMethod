const HALF_TO_FULL: Record<string, string> = {
  ',': '，',
  '.': '。',
  '?': '？',
  '!': '！',
  ':': '：',
  ';': '；',
  '"': '“',
  "'": "‘",
  '~': '～',
  '\\': '、',
  '/': '／',
  '|': '｜',
  '@': '＠',
  '#': '＃',
  '$': '＄',
  '%': '％',
  '^': '＾',
  '&': '＆',
  '*': '＊',
  '+': '＋',
  '-': '－',
  '=': '＝',
  '_': '＿',
  '(': '（',
  ')': '）',
  '[': '【',
  ']': '】',
  '<': '《',
  '>': '》'
}

const FULL_TO_HALF: Record<string, string> = {
  '，': ',',
  '。': '.',
  '？': '?',
  '！': '!',
  '：': ':',
  '；': ';',
  '“': '"',
  '”': '"',
  '‘': "'",
  '’': "'",
  '～': '~',
  '、': '\\',
  '／': '/',
  '｜': '|',
  '＠': '@',
  '＃': '#',
  '＄': '$',
  '％': '%',
  '＾': '^',
  '＆': '&',
  '＊': '*',
  '＋': '+',
  '－': '-',
  '＝': '=',
  '＿': '_',
  '（': '(',
  '）': ')',
  '【': '[',
  '】': ']',
  '《': '<',
  '》': '>'
}

let useOpeningDoubleQuote: boolean = true
let useOpeningSingleQuote: boolean = true

export function adaptPunctuationForLanguage(text: string, isChinese: boolean): string {
  if (text.length !== 1) {
    return text
  }
  if (isChinese) {
    if (text === '"') {
      const quote = useOpeningDoubleQuote ? '“' : '”'
      useOpeningDoubleQuote = !useOpeningDoubleQuote
      return quote
    }
    if (text === "'") {
      const quote = useOpeningSingleQuote ? '‘' : '’'
      useOpeningSingleQuote = !useOpeningSingleQuote
      return quote
    }
    return HALF_TO_FULL[text] ?? text
  }
  return FULL_TO_HALF[text] ?? text
}


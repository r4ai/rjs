// Convert a content to a string.
// @see https://github.com/typst/typst/issues/2196
#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}

/// タイトルコンポーネント
///
/// == 使用例
///
/// ```typ
/// #show: report.with(
///   title-component: report-title,
/// )
/// ```
#let report-title(
  title: [タイトル],
  author: [著者],
  date: datetime.today(),
  font: "Noto Serif JP",
  gap: (32pt, 32pt),
) = {
  let leading = 0.8em
  align(center)[
    #heading(level: 1, numbering: none, outlined: false)[
      #set text(font: font, size: 16pt, weight: "regular")
      #set par(leading: leading)
      #title
    ]
    #block(above: gap.at(0))[
      #set text(font: font, size: 12pt, weight: "regular")
      #set par(leading: leading)
      #author
    ]
    #block(above: gap.at(1))[
      #set text(font: font, size: 12pt, weight: "regular")
      #set par(leading: leading)
      #date.display(
        "[year padding:none]年[month padding:none]月[day padding:none]日",
      )
    ]
  ]
}

/// 日本語文書用のテンプレート
///
/// == 使用例
///
/// ```typ
/// #show: report.with(
///   title: [
///     計算機科学基礎実験 \
///     第一回レポート \
///     Rustによるプログラミング演習
///   ],
///   author: [
///     IS科 \
///     Rai
///   ]
/// )
/// ```
///
/// - title (content): 文書のタイトル
///   - type: `content`
///   - default: `[タイトル]`
/// - author (content): 文書の著者
///   - type: `content`
///   - default: `[著者]`
/// - date (datetime): 文書の日付
///   - type: `datetime`
///   - default: `datetime.today()`
/// - title-type (str, none): タイトルの表示形式
///   - type: `"fullpage" | "inpage" | none`
///   - default: `"fullpage"`
/// - title-component (function): タイトルコンポーネントの関数
///   - type:
///     ```
///     (
///       title: content,
///       author: content,
///       date: datetime,
///       font: text.font,
///       gap: (length, length)
///     ) => content
///     ```
///   - default: `report-title`
/// - heading-font (str): 見出しのフォント
///   - type: `text.font`
///   - default: `"Noto Sans JP"`
/// - strong-font (str): 強調テキストのフォント
///   - type: `text.font`
///   - default: `"Noto Sans JP"`
/// - body-font (str): 本文のフォント
///   - type: `text.font`
///   - default: `"Noto Serif JP"`
/// - title-font (str): タイトルのフォント
///   - type: `text.font`
///   - default: `"Noto Serif JP"`
/// - mono-font (str): 等幅フォント
///   - type: `text.font`
///   - default: `"UDEV Gothic NFLG"`
/// - body (content): 文書の本文
///   - type: `content`
#let report(
  title: [タイトル],
  author: [著者],
  date: datetime.today(),
  title-type: "fullpage",
  title-component: report-title,
  heading-font: "Noto Sans JP",
  strong-font: "Noto Sans JP",
  body-font: "Noto Serif JP",
  title-font: "Noto Serif JP",
  mono-font: "UDEV Gothic NFLG",
  body,
) = {
  // Configure the pdf document properties.
  let title_str = to-string(title)
  let author_str = to-string(author)
  set document(
    title: if title_str == none { "" } else { title_str },
    author: if author_str == none { "" } else { author_str },
    date: date,
  )

  // Configure the page size and margins.
  set page(
    paper: "a4",
    margin: (
      top: 25mm,
      bottom: 30mm,
      left: 25mm,
      right: 25mm,
    ),
    numbering: "1",
  )

  // Configure text appearance
  set par(leading: 1em, justify: true)
  set text(font: body-font, lang: "ja", region: "jp", size: 10pt)
  set heading(numbering: "1.1.1.1.1.  ")
  set block(spacing: 2em, above: 2em)
  show heading: it => [
    #set block(above: 2.5em, below: 1em)
    #set text(font: heading-font, weight: "semibold")
    #it
  ]
  show strong: set text(font: strong-font)
  show raw: set text(font: mono-font)

  // Configure equation numbering and spacing
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): it => {
    set block(spacing: 1em)
    if it.numbering == none {
      return it
    }

    // Number equations only when they have labels
    if it.has("label") {
      it
    } else {
      math.equation(block: true, numbering: none)[#it.body]
      counter(math.equation).update(n => n - 1)
    }
  }
  show math.equation.where(block: false): it => {
    h(0.25em, weak: true)
    it
    h(0.25em, weak: true)
  }

  // Configure appearance of references
  show ref: it => {
    let elem = it.element
    if (elem == none) {
      return it
    }

    // equation
    if elem.func() == math.equation {
      return link(elem.location(), [
        式 $#numbering(elem.numbering, ..counter(math.equation).at(it.element.location()))$
      ])
    }

    it
  }

  // Configure lists
  show enum: it => [
    #set enum(indent: 1.5em, body-indent: 0.5em, numbering: "1.a.i.")
    #set block(spacing: 2em)
    #it
  ]
  show list: it => [
    #set list(indent: 1.5em, body-indent: 0.5em)
    #set block(spacing: 2em)
    #it
  ]

  // Configure figures
  show figure: set block(spacing: 2em, above: 2em, below: 2em)

  // Configure table
  show figure.where(kind: table): set figure.caption(position: top)

  // Configure bibliography
  set bibliography(title: "参考文献")

  // Display the title, author, and date.
  if title-type == "fullpage" {
    page(numbering: none)[
      #v(1fr)
      #title-component(
        title: title,
        author: author,
        date: date,
        font: title-font,
        gap: (48pt, 32pt),
      )
      #v(1fr)
    ]
    counter(page).update(1)
  } else if title-type == "inpage" {
    v(48pt)
    title-component(title: title, author: author, date: date, font: title-font)
    v(48pt)
  }

  // Display the content body.
  body
}

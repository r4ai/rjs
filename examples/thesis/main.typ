/// PDF: https://r4ai.github.io/rjs/thesis.pdf

// codly
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)
#show figure: set block(breakable: true)

// algorithmic
#import "@preview/algorithmic:1.0.7"
#import algorithmic: algorithm-figure, style-algorithm
#show: style-algorithm
#show figure.where(kind: "algorithm"): it => {
  show strong: set text(font: ("Noto Serif", "Noto Serif JP"))
  set text(font: ("Noto Serif", "Noto Serif JP"))
  it
}

// rjs
#import "utils.typ": wareki
#import "../../rjs.typ": report
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
      #set text(font: font, size: 14pt, weight: "regular")
      #set par(leading: leading)
      #author
    ]
    #block(above: gap.at(1))[
      #set text(font: font, size: 12pt, weight: "regular")
      #set par(leading: leading)
      #wareki(date)
    ]
  ]
}
#show: report.with(
  title: [すごい卒業論文],
  author: [
    すごい大学 すごい学部 すごい学科 \
    すごい研究室 \
    山田 太郎
  ],
  title-type: "fullpage",
  title-component: report-title,
)

// ドキュメント全体の設定
#set text(size: 12pt)
#set page(margin: (top: 60mm, bottom: 60mm, left: 30mm, right: 30mm))
#set par(first-line-indent: (
  all: true,
  amount: 1em,
))

// 見出しスタイル
#set heading(numbering: (..args) => {
  let numbers = args.pos()
  if numbers.len() == 1 {
    return numbering("題1章", ..numbers)
  } else {
    return numbering("1.1.1", ..numbers)
  }
})
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(below: 32pt, it)
}
#show heading.where(level: 2): it => {
  block(
    above: 32pt,
    below: 24pt,
    it,
  )
}
#show heading.where(level: 3): it => {
  block(
    above: 32pt,
    below: 24pt,
    it,
  )
}

// 目次
#show outline.entry.where(level: 1): set text(
  weight: "bold",
  font: "Noto Sans JP",
)
#outline(
  title: [
    目次
  ],
  indent: 2em,
  depth: 3,
)

= はじめに

#lorem(200)

= 準備

#lorem(50)

== 見出し2

- 箇条書き
- 箇条書き
  - ネストした箇条書き
    - ネストした箇条書き

+ 箇条書き
+ 箇条書き
  + ネストした箇条書き
    + ネストした箇条書き

#lorem(20)

$
  E = m c^2
$

#lorem(10)

=== 見出し3

#lorem(10)

==== 見出し4

#lorem(10)

= 理論

2分探索法（Binary Search）は、整列された配列から特定の値を効率的に検索するアルゴリズムである。アルゴリズムを @alg:binary_search に示す。

#algorithm-figure(
  "Binary Search",
  vstroke: .5pt + luma(200),
  supplement: "アルゴリズム",
  {
    import algorithmic: *

    Procedure(
      "Binary-Search",
      ("A", "n", "v"),
      {
        Comment[Initialize the search range]
        Assign[$l$][$1$]
        Assign[$r$][$n$]
        LineBreak
        While(
          $l <= r$,
          {
            Assign([mid], FnInline[floor][$(l + r) / 2$])
            IfElseChain(
              $A ["mid"] < v$,
              {
                Assign[$l$][$"mid" + 1$]
              },
              [$A ["mid"] > v$],
              {
                Assign[$r$][$"mid" - 1$]
              },
              Return[mid],
            )
          },
        )
        Return[*null*]
      },
    )
  },
) <alg:binary_search>

= 実装

@alg:binary_search をRustで実装したプログラムを @code:binary_search_rust に示す。

#figure(
  caption: "binary_search.rs",
)[
  ```rust
  fn binary_search(arr: &[i32], target: i32) -> Option<usize> {
      let mut left = 0;
      let mut right = arr.len();

      while left < right {
          let mid = left + (right - left) / 2;
          if arr[mid] == target {
              return Some(mid);
          } else if arr[mid] < target {
              left = mid + 1;
          } else {
              right = mid;
          }
      }
      None
  }
  ```
] <code:binary_search_rust>

= 実験

#lorem(100)

= 評価

#lorem(100)

= 関連研究

#lorem(100)

= 結論

LLVM @LLVMCompilerInfrastructure.
TACO @kjolstad2017tensor.

#lorem(100)

#show bibliography: set text(lang: "en")
#bibliography(style: "ieee", "ref.bib")

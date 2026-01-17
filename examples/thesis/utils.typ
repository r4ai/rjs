/// 与えられた datetime を和暦表記の文字列に変換する。
///
/// 既定フォーマット: "令和7年12月13日" のような表記。
///
/// Era boundaries (Gregorian):
/// - Meiji: 1868-10-23
/// - Taisho: 1912-07-30
/// - Showa: 1926-12-25
/// - Heisei: 1989-01-08
/// - Reiwa: 2019-05-01
///
/// - dt (datetime): 変換する日時
/// - gannen (bool): 1年を「元年」にするか
/// - style (str): 表示形式
///   - type: "kanji" | "initial"
///     - "kanji": 漢字表記（例: 令和7年12月13日）
///     - "initial": イニシャル表記（例: R7/12/13）
///   - default: "kanji"
/// - pad (str): initial のとき月日を 2 桁にするか
///   - type: "none" | "zero"
///     - "none": 1桁のまま（例: R7/1/5）
///     - "zero": 2桁にゼロ埋め（例: R7/01/05）
///   - default: "none"
/// - pre_meiji (str): 明治以前の日付の扱い
///   - type: "panic" | "gregorian"
///     - "panic": エラーにする
///     - "gregorian": 西暦表記にフォールバック（例: 西暦1860年1月5日）
///   - default: "panic"
///
/// -> str
#let wareki(
  dt,
  gannen: true,
  style: "kanji",
  pad: "none",
  pre_meiji: "panic",
) = {
  let y = dt.year()
  let m = dt.month()
  let d = dt.day()

  if y == none or m == none or d == none {
    panic(
      "wareki: dt must include year/month/day (got time-only or partial datetime).",
    )
  }

  // YYYYMMDD の整数にして大小比較を簡単にする
  let ord = y * 10000 + m * 100 + d

  // 上から順に当たったものを採用
  let eras = (
    (name: "令和", initial: "R", start_ord: 20190501, start_year: 2019),
    (name: "平成", initial: "H", start_ord: 19890108, start_year: 1989),
    (name: "昭和", initial: "S", start_ord: 19261225, start_year: 1926),
    (name: "大正", initial: "T", start_ord: 19120730, start_year: 1912),
    (name: "明治", initial: "M", start_ord: 18681023, start_year: 1868),
  )

  let era = eras.find(e => ord >= e.start_ord)

  if era == none {
    if pre_meiji == "panic" {
      panic("wareki: date is before Meiji (1868-10-23).")
    } else {
      // 西暦表記にフォールバック
      return "西暦" + str(y) + "年" + str(m) + "月" + str(d) + "日"
    }
  }

  let era_year = y - era.start_year + 1
  let era_year_str = if gannen and era_year == 1 { "元" } else { str(era_year) }

  // 2桁ゼロ埋め（必要なときだけ）
  let two = n => {
    let s = str(n)
    if s.len() == 1 { "0" + s } else { s } // .len() は str.len と同義
  }

  let mm = if pad == "zero" { two(m) } else { str(m) }
  let dd = if pad == "zero" { two(d) } else { str(d) }

  if style == "initial" {
    // 例: R7/12/13 あるいは R7/12/13（pad="zero" なら R7/12/13 の月日が 2 桁）
    return era.initial + era_year_str + "/" + mm + "/" + dd
  } else {
    // 例: 令和7年12月13日
    return era.name + era_year_str + "年" + str(m) + "月" + str(d) + "日"
  }
}

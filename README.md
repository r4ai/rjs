# rjs

日本語文書用の [Typst](https://typst.org/) テンプレートです。

自分用に作成したもので、主に大学のレポート作成での使用を想定しています。

> [!IMPORTANT]
> 例：
>
> - レポート
>   - PDF: [report.pdf](https://r4ai.github.io/rjs/report.pdf)
>   - Typst: [examples/report/main.typ](./examples/report/main.typ)
> - 論文
>   - PDF: [thesis.pdf](https://r4ai.github.io/rjs/thesis.pdf)
>   - Typst: [examples/thesis/main.typ](./examples/thesis/main.typ)

## インストール

### 自動インストール

次のコマンドを実行してください。

```sh
deno run --reload --allow-{env,net,read,write} https://raw.githubusercontent.com/r4ai/rjs/refs/heads/main/scripts/install.ts
```

使用方法は、[テンプレートの使用](#テンプレートの使用) を参照してください。

<details>

<summary>アンインストール方法</summary>

```sh
# Linux
rm -rf ~/.local/share/typst/packages/local/rjs

# MacOS
rm -rf ~/Library/Application Support/typst/packages/local/rjs

# Windows
rm $env:APPDATA\typst\packages\local\rjs
```

</details>

### 手動インストール

1. [`rjs.typ`](./rjs.typ) を手動でダウンロードしてください。

   ```sh
   wget https://raw.githubusercontent.com/r4ai/rjs/refs/heads/main/rjs.typ
   ```

2. ダウンロードした `rjs.typ` を、次のように `#import` してください。

   ```typ
   #import "./rjs.typ": report
   #show: report.with(
     title: [
       計算機科学基礎実験 \
       第一回レポート \
       Rustによるプログラミング演習
     ],
     author: [
       IS科 \
       Rai
     ]
   )
   ```

## 使い方

以下のコードを、レポートのファイルの先頭に追加してください。

```typ
#import "@local/rjs:0.1.0": report
#show: report.with(
  title: [
    計算機科学基礎実験 \
    第一回レポート \
    Rustによるプログラミング演習
  ],
  author: [
    IS科 \
    Rai
  ]
)
```

### タイトルページ

次のように、タイトルページの内容を指定できます。

```typ
#import "@local/rjs:0.1.0": report

#show: report.with(
  title: [
    計算機科学基礎実験 \
    第一回レポート \
    Rustによるプログラミング演習
  ],
  author: [
    情報科学科 \
    ○○ ○○
  ],
  title-type: "inpage",
  date: datetime(
    year: 2023,
    month: 12,
    day: 3,
  ),
)
```

それぞれのパラメータの説明を以下に示します。

- `title`: タイトルを指定します
  - type: `content`
  - default: `[タイトル]`
- `author`: 著者を指定します
  - type: `content`
  - default: `[著者]`
- `date`: 日付を指定します
  - type: `datetime`
  - default: `datetime.today()`
- `title-type`: タイトルの種類を指定します
  - type: `"fullpage" | "inpage" | none`
    - `"fullpage"`: 1 ページ目にタイトルページを挿入します
    - `"inpage"`: 1 ページ目の上部にタイトルを挿入します
    - `none`: タイトルを挿入しません
  - default: `"fullpage"`
- `title-component`:
  タイトルページのコンポーネントを指定します。コンポーネントは、以下の type
  を満たす関数です
  - type:
    ```
    (
      title: content,
      author: content,
      date: datetime,
      font: text.font,
      gap: (length, length)
    ) => content
    ```
  - default: `report-title`

### フォント

次のようにしてフォントを変更できます：

```typ
#import "@local/rjs:0.1.0": report

#show: report.with(
  heading-font: "Noto Sans JP",
  strong-font: "Noto Sans JP",
  title-font: "Noto Serif JP",
  body-font: "Noto Serif JP",
  mono-font: "UDEV Gothic NFLG",
)
```

それぞれのパラメータの説明を以下に示します。

- `heading-font`: 見出しのフォントを指定します
  - type: `string`
  - default: `"Noto Sans JP"`
- `strong-font`: 太字のフォントを指定します
  - type: `string`
  - default: `"Noto Sans JP"`
- `title-font`: タイトルのフォントを指定します
  - type: `string`
  - default: `"Noto Serif JP"`
- `body-font`: 本文のフォントを指定します
  - type: `string`
  - default: `"Noto Serif JP"`
- `mono-font`: 等幅のフォントを指定します
  - type: `string`
  - default: `"UDEV Gothic NFLG"`

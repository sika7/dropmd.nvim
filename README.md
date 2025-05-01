# dropmd.nvim

Neovim用のシンプルなプラグインで、画像や動画ファイルをドラッグ＆ドロップすると、自動でワークスペースに保存し、Markdown形式のリンクを挿入します。

## 🧩 主な機能

- ファイルをドラッグ＆ドロップで挿入
- GitルートやCWDに保存先を動的に設定可能
- リネーム形式を「パターン文字列」で簡単に指定可能
- Markdown, HTML形式のリンクを自動で生成（拡張子ごとに自動切替）

## 🔧 インストール

Lazy.nvim の場合：

```lua
{
  "sika7/dropmd.nvim",
  config = function()
    require("dropmd").setup({
      root_dir = function()
        return require("dropmd").get_workspace_root()
      end, -- workspace_root = vim.fn.getcwd or git_root
      assets_dir = function()
        -- vim.fn.expand("~/my-assets")
        return require("dropmd").get_workspace_root() .. "/assets" -- デフォルトはワークスペースのアセットを使う
      end,
      filetypes = { "markdown" },
      rename_pattern = "drop-%Y%m%d-%H%M%S.%e", -- 拡張子付きでリネーム
    })
  end,
}
```

## 📁 `rename_pattern` オプション

| プレースホルダ  | 説明                         |
| --------------- | ---------------------------- |
| `%Y%m%d-%H%M%S` | 日付と時刻（`os.date` 形式） |
| `%e`            | 拡張子（例: png, mp4）       |
| `%f`            | 元ファイル名（拡張子なし）   |

例:

- `"image-%Y%m%d-%H%M%S.%e"` → `image-20250501-171234.png`
- `"media/%f-%H%M.%e"` → `media/photo-1712.jpg`

## 💡 拡張子ごとの自動出力形式（デフォルト）

| 拡張子      | 出力                                  |
| ----------- | ------------------------------------- |
| .png, .jpg  | `![name](path)`                       |
| .mp4, .webm | `<video src="path" controls></video>` |
| .mp3, .wav  | `<audio src="path" controls></audio>` |
| .pdf        | `[name](path)`                        |
| その他      | `![name](path)`                       |

## 🔒 仕様と安全性

- ファイルタイプに応じた制限（markdownなど）を設定可能
- `DropPre` は独自 `augroup` を用いて他と干渉しにくい
- リネーム時に拡張子は元ファイルと一致するので安全

---

このプラグインは、Markdownでの執筆やメディア整理を支援するためのミニマルなツールです。

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
        -- workspace_root = vim.fn.getcwd or git_root
        -- ワークスペースのルートディレクトリ
        -- gitやvim.fn.getcwdでパスが出ない場合はここでカスタムして
        return require("dropmd").get_workspace_root()
      end,
      assets_dir = function()
        -- アセットを保存するディレクトリ

        -- ホームディレクトリを設定する例
        -- vim.fn.expand("~/my-assets")

        -- デフォルトはワークスペースのアセットを使う
        return require("dropmd").get_workspace_root() .. "/assets"
      end,
      path_formatter = function(abs_path, root_dir)
        local rel = abs_path:gsub("^" .. vim.pesc(root_dir), "")
        return "/" .. rel:gsub("^/", "")
      end, -- path_formatter でマークダウンにいれるパスを変更できる デフォルトはワークスペースを基準に絶対パス
      filetypes = { "markdown" },
      rename_pattern = "drop-%Y%m%d-%H%M%S.%e", -- 拡張子付きでリネーム
    })
  end,
}
```

ワークスペースごとに設定する例
[workspace-config.nvim](https://github.com/sika7/workspace-config.nvim)

```lua
-- .config/nvim/init.lua
require("lazy").setup({
  -- ワークスペースのlua設定ファイルを読むプラグイン
  'sika7/workspace-config.nvim',

  -- 画像をコピペでインサートできるようにするプラグイン
  "sika7/dropmd.nvim",
  -- ワークスペースで初期化するためconfigは設定しなくていい
})

-- your_project/.nvim/workspace.lua
require("dropmd").setup({
  assets_dir = function()
    -- デフォルトはワークスペースのアセットを使う
    return require("dropmd").get_workspace_root() .. "/images"
  end,
  filetypes = { "markdown" },
  rename_pattern = "img-%Y%m%d-%H%M%S.%e",       -- 拡張子付きでリネーム
})
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

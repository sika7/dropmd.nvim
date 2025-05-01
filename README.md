# dropmd.nvim

Neovim用のシンプルなプラグインで、画像や動画ファイルをドラッグ＆ドロップすると、自動でワークスペースに保存し、Markdown形式のリンクを挿入します。

## 🧩 主な機能

- ファイルをドラッグ＆ドロップで挿入
- GitルートやCWDに保存先を動的に設定可能
- リネーム・保存形式を自由にカスタマイズ
- Markdown, HTML形式のリンクを自動で生成（拡張子ごとに自動切替）

## 🔧 インストール

Lazy.nvim の場合：

```lua
{
  "sika7/dropmd.nvim",
  config = function()
    require("dropmd").setup({
      workspace_dir = function()
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        return (git_root ~= "") and (git_root .. "/assets") or (vim.fn.getcwd() .. "/assets")
      end,
      filetypes = { "markdown" }, -- 対象のfiletypeを指定
    })
  end,
}
```

## 💡 デフォルトの出力形式（拡張子別）

| 拡張子      | 出力形式                              |
| ----------- | ------------------------------------- |
| .png, .jpg  | `![ファイル名](パス)`                 |
| .mp4, .webm | `<video src="パス" controls></video>` |
| .mp3, .wav  | `<audio src="パス" controls></audio>` |
| .pdf        | `[ファイル名](パス)`                  |
| その他      | `![ファイル名](パス)`                 |

## ⚠️ 注意

- Neovim 0.9以上が必要です（`DropPre` イベント使用のため）
- 他の `DropPre` と併用する際は競合回避の設計をしていますが、完全な排他制御はできません

---

このプラグインは、Markdownでの執筆やメディア整理を支援するためのミニマルなツールです。

## 📄 ライセンス

MIT License


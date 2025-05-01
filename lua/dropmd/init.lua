local M = {}

-- デフォルト設定
M.opts = {
  workspace_dir = vim.fn.expand("~/my-assets"),
  rename_pattern = "asset-%Y%m%d-%H%M%S.%e", -- 新規追加
  rename_fn = nil, -- パターンがあれば動的に生成
  filetypes = { "markdown" },
  formatter_fn = nil,
}

-- デフォルト formatter
local function default_formatter(filename, path)
  local ext = vim.fn.fnamemodify(path, ":e")
  if ext == "mp4" or ext == "webm" then
    return string.format('<video src="%s" controls></video>', path)
  elseif ext == "mp3" or ext == "wav" then
    return string.format('<audio src="%s" controls></audio>', path)
  elseif ext == "pdf" then
    return string.format('[%s](%s)', filename, path)
  else
    return string.format('![%s](%s)', filename, path)
  end
end

-- rename_pattern から rename_fn を生成
local function pattern_to_fn(pattern)
  return function(orig_path)
    local ext = vim.fn.fnamemodify(orig_path, ":e")
    local base = vim.fn.fnamemodify(orig_path, ":t:r")
    local formatted = os.date(pattern:gsub("%%e", "___EXT___"):gsub("%%f", "___BASE___"))
    return formatted
      :gsub("___EXT___", ext)
      :gsub("___BASE___", base)
  end
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  -- rename_pattern があれば rename_fn を上書き生成
  if M.opts.rename_pattern and not M.opts.rename_fn then
    M.opts.rename_fn = pattern_to_fn(M.opts.rename_pattern)
  end

  if not M.opts.formatter_fn then
    M.opts.formatter_fn = default_formatter
  end

  vim.api.nvim_create_autocmd("DropPre", {
    group = vim.api.nvim_create_augroup("dropmd_plugin", { clear = false }),
    callback = function(args)
      -- filetype フィルタ：早期リターン
      if M.opts.filetypes then
        local current_ft = vim.bo.filetype
        local matched = false
        for _, ft in ipairs(M.opts.filetypes) do
          if current_ft == ft then
            matched = true
            break
          end
        end
        if not matched then
          return
        end
      end

      local src_path = args.file
      local filename = M.opts.rename_fn(src_path)

      local workspace = type(M.opts.workspace_dir) == "function"
        and M.opts.workspace_dir()
        or M.opts.workspace_dir

      vim.fn.mkdir(workspace, "p")
      local dst_path = workspace .. "/" .. filename
      vim.fn.copy(src_path, dst_path)

      local markdown = M.opts.formatter_fn(filename, dst_path)
      vim.api.nvim_put({ markdown }, 'c', true, true)
    end,
  })
end

return M
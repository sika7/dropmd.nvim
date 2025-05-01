local M = {}

local function get_workspace_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_root == "" then
    return vim.fn.getcwd()
  end
  return git_root
end

M.opts = {
  root_dir = function()
    return get_workspace_root()
  end,
  assets_dir = function()
    return get_workspace_root() .. "/assets"
  end,
  rename_pattern = "asset-%Y%m%d-%H%M%S.%e",
  rename_fn = nil,
  filetypes = { "markdown" },
  formatter_fn = nil,
}

-- Default formatter
local function default_formatter(filename, path, rel_path)
  local ext = vim.fn.fnamemodify(path, ":e")
  if ext == "mp4" or ext == "webm" then
    return string.format('<video src="%s" controls></video>', rel_path)
  elseif ext == "mp3" or ext == "wav" then
    return string.format('<audio src="%s" controls></audio>', rel_path)
  elseif ext == "pdf" then
    return string.format('[%s](%s)', filename, rel_path)
  else
    return string.format('![%s](%s)', filename, rel_path)
  end
end

-- Convert rename pattern to function
local function pattern_to_fn(pattern)
  return function(orig_path)
    local ext = vim.fn.fnamemodify(orig_path, ":e")
    local base = vim.fn.fnamemodify(orig_path, ":t:r")
    local formatted = os.date(pattern:gsub("%%e", "___EXT___"):gsub("%%f", "___BASE___"))
    return formatted:gsub("___EXT___", ext):gsub("___BASE___", base)
  end
end

-- Shared insert logic
local function handle_file_insert(path)
  local filename = M.opts.rename_fn(path)
  local assets_dir = type(M.opts.assets_dir) == "function"
      and M.opts.assets_dir()
      or M.opts.assets_dir

  vim.fn.mkdir(assets_dir, "p")
  local dst_path = assets_dir .. "/" .. filename
  -- Copy the file
  local ok = vim.loop.fs_copyfile(path, dst_path)
  if not ok then
    vim.notify("Failed to copy image", vim.log.levels.ERROR)
    return
  end

  local root_dir = M.opts.root_dir()

  local abs_path = vim.fn.fnamemodify(path, ":p")
  local rel_path = abs_path:gsub("^" .. vim.pesc(root_dir), "")
  if not rel_path:match("^/") then
    rel_path = "/" .. rel_path
  end

  local markdown = M.opts.formatter_fn(filename, dst_path, rel_path)
  vim.api.nvim_put({ markdown }, 'c', true, true)
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

  if M.opts.rename_pattern and not M.opts.rename_fn then
    M.opts.rename_fn = pattern_to_fn(M.opts.rename_pattern)
  end

  if not M.opts.formatter_fn then
    M.opts.formatter_fn = default_formatter
  end

  -- Try DropPre
  local ok = pcall(vim.api.nvim_create_autocmd, "DropPre", {
    group = vim.api.nvim_create_augroup("dropmd_plugin", { clear = false }),
    callback = function(args)
      if M.opts.filetypes then
        local current_ft = vim.bo.filetype
        for _, ft in ipairs(M.opts.filetypes) do
          if current_ft == ft then
            handle_file_insert(args.file)
            return
          end
        end
        return
      end
      handle_file_insert(args.file)
    end,
  })

  -- Fallback to vim.paste override if DropPre is not available
  if not ok then
    vim.notify("[dropmd.nvim] 'DropPre' not available, falling back to vim.paste()", vim.log.levels.WARN)

    local original_paste = vim.paste

    vim.paste = function(lines, phase)
      -- 条件に合わない場合は即 return
      if not (phase and type(lines) == "table" and #lines == 1) then
        return original_paste(lines, phase)
      end

      -- 現在のバッファのファイルタイプが設定値に含まれているかチェック
      if M.opts.filetypes and not vim.tbl_contains(M.opts.filetypes, vim.bo.filetype) then
        return original_paste(lines, phase)
      end

      -- ファイルが存在しファイルパスっぽいかチェック
      local raw_path = lines[1]
      local path = raw_path:gsub("%s+$", "") -- 行末の空白・改行などを削除
      if not (path:match("^/.+%..+$") and vim.fn.filereadable(path) == 1) then
        return original_paste(lines, phase)
      end

      -- 拡張子が設定されているパターンかチェック
      local ext = vim.fn.fnamemodify(path, ":e")
      if not (ext:match("png") or ext:match("jpe?g") or ext:match("gif")
            or ext:match("webm") or ext:match("mp4") or ext:match("pdf")) then
        return original_paste(lines, phase)
      end

      -- すべての条件を通過したら画像挿入
      handle_file_insert(path)
      return true
    end
  end
end

function M.get_workspace_root()
  return get_workspace_root()
end

return M

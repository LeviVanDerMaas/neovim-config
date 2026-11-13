vim.g.vimtex_compiler_latexmk = {
  aux_dir = "aux",
  out_dir = "out",
}
vim.g.vimtex_format_enabled = 1

-- :h vimtex-view-okular. inverse search for okular is setup as explained there
vim.g.vimtex_view_general_viewer = "okular"
vim.g.vimtex_view_general_options =
  [[--editor-cmd "nvim --headless -c \"VimtexInverseSearch %l '%f'\"" --unique file:@pdf\#src:@line@tex]]

-- We want vimtex to handle highlighting for us instead
require("plugins.treesitter").lang_features.latex = { highlighting = false }



local augroup = vim.api.nvim_create_augroup("plugins.vimtex", { clear = false })

vim.api.nvim_create_autocmd("User", {
  group = augroup,
  desc = "Warn if Vimtex cannot find the compiler backend executable",
  pattern = "VimtexEventInitPost",
  callback = function()
    local compiler_method = vim.g.vimtex_compiler_method
    if type(compiler_method) == "function" then compiler_method = compiler_method() end

    if vim.fn.executable(compiler_method) == 0 then
      vim.schedule(function()
        vim.notify(
          "Vimtex: Compiler executable '" .. compiler_method .. "' cannot be found!",
          vim.log.levels.WARN
        )
      end)
    end
  end
})

-- Bridge Vimtex's quickfix integration into modern Neovim diagnostics.
vim.g.vimtex_quickfix_enabled = 1
vim.g.vimtex_quickfix_mode = 0
local diag_namespace = vim.api.nvim_create_namespace("plugins.vimtex.diagnostics")
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  desc = "Set diagnostics for Vimtex based on its quickfix entries.",
  pattern = { "VimtexEventCompileSuccess", "VimtexEventCompileFailed" },
  nested = true, -- Make sure this can trigger DiagnosticChanged
  callback = function()
    local diagnotics = vim.diagnostic.fromqflist(vim.fn.getqflist())

    local by_buf = {}
    for _, d in ipairs(diagnotics) do
      if not by_buf[d.bufnr] then by_buf[d.bufnr] = {} end
      table.insert(by_buf[d.bufnr], d)
    end

    for bufnr, diags in pairs(by_buf) do
      vim.diagnostic.set(diag_namespace, bufnr, diags)
    end
  end
})
-- Integrate our custom diagnostics with the tiny-inline-diagnostic.nvim plugin
-- tiny-inline-diagnostic.nvim by default only activates on LspAttach.
-- This cam be overriden, but only on event-level, not pattern-level, so no User events.
-- Thus we fire it manually
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  desc = "Integrate tiny-inline-diagnostic.nvim with custom plugins.vimtex diagnostics.",
  pattern = "VimtexEventInitPost", -- runs in every new tex buffer :h vimtex#init
  callback = function()
    vim.api.nvim_exec_autocmds("LspAttach", { group = "TinyInlineDiagnosticAutocmds" })
  end
})


-- Integrate Vimtex compilation with fidget.nvim
local fidget_handle = nil
vim.api.nvim_create_autocmd("User", {
  desc = "Add a fidget.nvim progress spinner while compiling with VimTeX",
  pattern = { "VimtexEventCompileStarted", "VimtexEventCompiling" },
  group = augroup,
  callback = function()
    if fidget_handle then return end

    local compiler_method = vim.g.vimtex_compiler_method
    if type(compiler_method) == "function" then compiler_method = compiler_method() end
    fidget_handle = require("fidget.progress").handle.create({
      title = compiler_method,
      message = "Compiling...",
      lsp_client = { name = "VimTeX" }
    })
  end,
})
vim.api.nvim_create_autocmd("User", {
  desc = "Finish fidget.nvim progress spinner after compiling with VimTeX",
  pattern = { "VimtexEventCompileSuccess", "VimtexEventCompileFailed", "VimtexEventCompileStopped" },
  group = augroup,
  callback = function(ev)
    if fidget_handle then
      local mes = ev.match == "VimtexEventCompileFailed" and "✗ Compilation Error(s)!" or "✓ Done!"
      fidget_handle:report({ message = mes })
      fidget_handle:finish()
      fidget_handle = nil
    end
  end,
})

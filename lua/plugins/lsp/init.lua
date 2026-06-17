-- LSPs themselves must be provided externally, this dir is just to configure
-- and enable them. :h lsp-config for more info.
--
-- vim.lsp.config() sets custom configuration options; earlier on some options
-- for a given lsp may have been set by `lsp/*.lua` files on the runtimepath,
-- such as by the plugin nvim-lspconfig (we could technically add our own such files
-- too in ~/.config/nvim/lsp, but if any plugins set them later on the rtp then our
-- settings will be overriden by those of the plugins).
-- vim.lsp.enable() can then be used to have lsps autostart on configured filetypes.

-- To get project-specific lsp-configs, use an exrc file with vim.lsp.config
-- (don't worry, this will still update the config after calling vim.lsp.enable)

-- Load configs for lsps specified by the `LSPS` table from plugins.lsp.<table_key>
-- and specify whether they should be enabled by default.
local LSPS = {
  lua_ls = true,
  nixd = true,
  clangd = false -- Unlikely to function in any decent way without compile database
}
for lsp, enable in pairs(LSPS) do
  pcall(require, "plugins.lsp." .. lsp)
  vim.lsp.enable(lsp, enable)
end

-- Config to run whenever an lsp attaches to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("plugins.lsp", { clear = true }),
  callback = function (event)
    -- local client = vim.lsp.get_client_by_id(event.data.client_id)

    local tsb = require "telescope.builtin"
    local lsp_km = function (keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- Setup buffer keymaps
    lsp_km("gd", tsb.lsp_definitions, "[G]oto reference [d]efintion")
    lsp_km("gD", vim.lsp.buf.declaration, "[G]oto reference [d]eclaration")
    lsp_km("gri", tsb.lsp_implementations, "[G]oto [r]eference [i]mplementations")
    lsp_km("grr", tsb.lsp_references, "[G]oto [r]efe[r]ences")
    lsp_km("grc", tsb.lsp_incoming_calls, "[G]oto [r]eference [c]allers")
    lsp_km("grC", tsb.lsp_outgoing_calls, "[G]oto [r]eference-[c]alled")
    lsp_km("grt", tsb.lsp_type_definitions, "[G]oto [r]eference [t]ype")
    lsp_km("grT", function () vim.lsp.buf.typehierarchy("supertypes") end, "[G]oto [r]eference super[t]ype")
    lsp_km("gr<C-t>", function () vim.lsp.buf.typehierarchy("subtypes") end, "[G]oto [r]eference sub[t]ype")
    lsp_km("gO", tsb.lsp_document_symbols, "[G]oto d[o]cument symbols")
    -- Compared to lsp_workspace_symbols, this one is non-blocking and updates query dynamically
    lsp_km("g<C-O>", tsb.lsp_dynamic_workspace_symbols, "[G]oto [w]orkspace symbols")
    lsp_km("grn", vim.lsp.buf.rename, "[G]lobally [r]e[n]ame")
    lsp_km("gra", vim.lsp.buf.code_action, "[G]et/[r]un code [a]ctions")
    lsp_km("grf", vim.lsp.buf.format, "[G]o [r]un [f]ormatter", { "n", "v" })

    local function change_document_highlights()
      vim.lsp.buf.clear_references() -- Clear older ones
      vim.lsp.buf.document_highlight()
    end
    lsp_km("grh", change_document_highlights, "[G]et [r]eference [h]ighlights")
    lsp_km("grH", vim.lsp.buf.clear_references, "Clear [grh]")
  end
})

local o = vim.opt

-- Data
o.swapfile = false
o.undofile = true -- By default gets stored in XDG_STATE_HOME/nvim/undo

-- Control and I/O Behaviour
o.exrc = true
o.updatetime = 100 -- Affects CursorHold aucmd and swapfile write threshold.
o.completeopt = 'menuone,noselect,noinsert,preview'
o.mouse = 'a'
o.clipboard = 'unnamed,unnamedplus'

-- Tab & Indent Behaviour
o.autoindent = true
o.smartindent = true
o.expandtab = true
o.shiftwidth = 4
o.softtabstop = -1 -- Negative causes it to follow shiftwidth

-- Patterns & Searching
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- UI
o.termguicolors = true
o.number = true
o.relativenumber = true
o.list = true
o.fillchars = "eob: "
o.listchars = 'tab:▸ ,trail:·,nbsp:⍽,extends:❯,precedes:❮,'
o.wrap = false
o.breakindent = true
o.linebreak = true
o.signcolumn = 'yes'
o.colorcolumn = '+1'
o.scrolloff = 8
o.sidescrolloff = 9

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- opt.splitbelow = true
-- opt.splitright = true
opt.wrap = false
-- opt.scrolloff = 8
-- opt.sidescrolloff = 8

-- opt.undofile = true
-- opt.swapfile = false
-- opt.updatetime = 250
-- opt.timeoutlen = 300
--
opt.clipboard = "unnamedplus"
opt.mouse = "a"

opt.spell = true
opt.spelllang = { "en" }

vim.diagnostic.config({
    virtual_text = true,
})

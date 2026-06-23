local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.showmode = false
opt.cmdheight = 1
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 12
opt.splitbelow = true
opt.splitright = true
opt.wrap = false
opt.linebreak = true
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.timeoutlen = 300
opt.conceallevel = 2

vim.g.mapleader = " "

vim.o.background = "dark"

vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = "●",
    },
    severity_sort = true,
    update_in_insert = false,
})



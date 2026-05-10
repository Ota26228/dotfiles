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

vim.g.mapleader = " "
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = "●",
    },
    serverity_sort = true,
    update_in_insert = false,
})





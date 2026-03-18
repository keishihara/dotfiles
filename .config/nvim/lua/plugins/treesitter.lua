local languages = {
    "bash",
    "diff",
    "dockerfile",
    "gitignore",
    "json",
    "lua",
    "markdown",
    "python",
    "toml",
    "vim",
    "yaml",
}

local function enable_highlighting(buf)
    if vim.bo[buf].buftype ~= "" then
        return
    end

    pcall(vim.treesitter.start, buf)
end

return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter")
        local installed = treesitter.get_installed()
        local missing = vim.tbl_filter(function(lang)
            return not vim.list_contains(installed, lang)
        end, languages)

        if #missing > 0 then
            treesitter.install(missing)
        end

        local group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })

        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                enable_highlighting(args.buf)
            end,
        })

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                enable_highlighting(buf)
            end
        end
    end,
}

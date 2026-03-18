return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    opts = {
        filesystem = {
            filtered_items = {
                hide_dotfiles = false,
            },
        },
    },
    config = function(_, opts)
        require("neo-tree").setup(opts)
        vim.keymap.set("n", "<leader>b", ":Neotree toggle left<CR>", {})
        vim.keymap.set("n", "<leader>e", function()
            local cur = vim.api.nvim_get_current_win()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "neo-tree" then
                    if win == cur then
                        vim.cmd("wincmd l")
                    else
                        vim.api.nvim_set_current_win(win)
                    end
                    return
                end
            end
            vim.cmd("Neotree toggle left")
        end, {})
    end,
}

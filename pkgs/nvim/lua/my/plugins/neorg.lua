require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        --["core.norg.news"] = { check_news = false },
        ["core.concealer"] = {
            config = {
                icon_preset = "diamond",
            },
        },
        ["core.dirman"] = {
            config = {
                workspaces = {
                    work = "~/notes/work",
                    home = "~/notes/home",
                },
            },
        },
        ["core.completion"] = {
            config = {
                engine = "nvim-cmp",
            },
        },
        ["core.keybinds"] = {
            config = {
                default_keybinds = true,
            },
        },
    },
})

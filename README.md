# ts-tokeymap

Mapping keymap to syntax tree using nvim-treesitter

config: lazy

```lua
return {
    "lizard-Szilard/ts-tokeymap",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-refactor",
    },
    config = function()
        local one_key = require('ts-tokeymap')
        one_key.setup() -- call setup separate
        local cmd_key = {
            cmd_key = {
                ["function.call"] = {
                    "K nmap | lsp-config hover",
                    "gnd nmap | goto_definition ts-refactor",
                    "gnD nmap | list_definitions ts-refactor",
                    "gO nmap | list_definitions_toc ts-refactor",
                    "<a-*> |  goto_next_usage ts-refactor",
                    "<a-#> | goto_previous_usage ts-refactor",
                },
                ["variable.parameter"] = {
                    "grr nmap | smart rename"
                },
                ["variable"] = {
                    "grr nmap | smart rename"
                },
                ["comment"] = {
                    "//! outer doc entire module",
                    "/// inner doc invidual block code",
                    "The Rust Reference book",
                    "The Rustdoc"
                },
                ["attr.test"] = {
                    ":RustLsp testtables | ! rerun the last neotest-rustaceanvim",
                    ":RustTest  | :h ft_rust.txt"
                },
                ["local.scope"] = {
                    "gnn vmap | ts",
                    ":RustLsp moveItem up|down | rustaceanvim"
                }
            }
        }
        vim.keymap.set({ "n", "v" }, "<C-l>", function()
            one_key.one_key(cmd_key)
        end, { desc = "one_key" })
    end

}
```

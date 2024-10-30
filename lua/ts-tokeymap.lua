local v_api = vim.api
local v_ts_api = vim.treesitter
local ts_utils = require('nvim-treesitter.ts_utils')
local state_w = { ['w_handler'] = nil }

local function o_f_win()
    local opts = {
        ['relative'] = 'win',
        ['style'] = 'minimal',
        ['anchor'] = 'SW',
        ['width'] = 50,
        ['height'] = 5,
        ['row'] = 1,
        ['col'] = 150,
        ['focusable'] = true,
        ['border'] = 'rounded',
        ['title'] = 'Keympap',
    }

    return v_api.nvim_open_win(v_api.nvim_create_buf(false, true), false, opts) -- return window handler
end

-- @params collect_captures_name table
-- @params query_filename array type
-- @params bufnr current buffer
-- @return collect_captures_name
local function collect_captures(lang, query_filename, bufnr, collect_captures_name)
    if #query_filename ~= 0 then
        local query_from_files = v_ts_api.query.get(lang, query_filename[1])
        if query_from_files ~= nil then
            for id, node, metadata, mtach in query_from_files:iter_captures(ts_utils.get_node_at_cursor(0), bufnr) do
                local name = query_from_files.captures[id]
                if name ~= nil then
                    table.insert(collect_captures_name, name)
                end
            end
        end
        table.remove(query_filename, 1)
        collect_captures(lang, query_filename, bufnr, collect_captures_name)
    end
    return collect_captures_name
end

-- @params conf
--  cmd_key = {
--         ["@function.call.rust"] = {
--             "nmap K lsp-config hover",
--             "nmap R v-ts-refactoring"
--         }
--     }
-- @return table array {a, b, c}
local function user_command_key_ref(conf)
    local bufnr = v_api.nvim_get_current_buf()
    local tsq_cur_cur = {}

    collect_captures("rust", { "keymap", "locals" }, bufnr, tsq_cur_cur)

    -- equavalent to highlights.scm
    local left, right = unpack(vim.treesitter.get_captures_at_cursor(0))

    if (left ~= nil) == (right ~= nil) then
        if left == right then
            tsq_cur_cur[#tsq_cur_cur+1] = left or right
        elseif left ~= nil and right == nil then
            tsq_cur_cur[#tsq_cur_cur+1] = left
        elseif left == nil and right ~= nil then
            tsq_cur_cur[#tsq_cur_cur+1] = right
        elseif left == right then
            tsq_cur_cur[#tsq_cur_cur+1] = left
        else
            tsq_cur_cur[#tsq_cur_cur+1] = left
            tsq_cur_cur[#tsq_cur_cur+1] = right
        end
    end
    local ok = {}
    if conf ~= nil then
        for _, key in ipairs(tsq_cur_cur) do
            local v = rawget(conf, key) -- return an array containing string
            if v ~= nil then
                for _, y in ipairs(v) do
                    table.insert(ok, y)
                end
            end
        end
        return ok
    end
end

local M = {}

-- @params cmd_key
-- local cmd_key = {
--     cmd_key = {
--         ["function.call"] = {
--             "nmap K lsp-config hover",
--             "nmap R v-ts-refactoring"
--         }
--     }
-- }
function M.one_key(cmd_key)
    if state_w['w_handler'] == nil then state_w['w_handler'] = o_f_win() end -- If the window is not already open, `state_w` is nil.
    local uckref = user_command_key_ref(cmd_key.cmd_key)
    v_api.nvim_buf_set_lines(v_api.nvim_win_get_buf(state_w['w_handler']), 0, -1, true, uckref)
end

function M.setup()
    v_api.nvim_create_autocmd({ "QuitPre", "ExitPre" }, {
        callback = function()
            if state_w['w_handler'] ~= nil then
                if v_api.nvim_win_is_valid(state_w['w_handler']) then
                    v_api.nvim_win_close(state_w['w_handler'], true)
                    state_w['w_handler'] = nil
                end
            end
        end
    })
end

return M

local curl = require("plenary.curl")
local popup = require("plenary.popup")

local M = {}
local buf_nbr = nil

-- make split window	
local function make_window()
    buf_nbr = vim.api.nvim_create_buf(true, true)
    popup.create(buf_nbr, {
        padding = {
            pad_top = 10,
            pad_right = 10,
            pad_left = 10,
            pad_below = 10
        },
        minwidth = 100,
        minheight = 50,
        maxwidth = 200,
        maxheight = 100,
        border = {},
        title = "Ollama Chat",
        wrap = true
    })
end

local grab_buffer = function()
    if buf_nbr then
        local buffer = vim.api.nvim_buf_get_lines(buf_nbr, 0, vim.api.nvim_buf_line_count(buf_nbr), false)
        return table.concat(buffer, "\r\n")
    end
    return {}
end

local add_line_break = function(str)
    if buf_nbr then
        local last = vim.api.nvim_buf_get_lines(buf_nbr, vim.api.nvim_buf_line_count(buf_nbr) - 1,
            vim.api.nvim_buf_line_count(buf_nbr), false)
        if #last > 100 then return str.concat("\r\n") else return str end
    end
    return str
end

local function prompt(url)
    local prompt_text = grab_buffer()
    vim.api.nvim_put({ "", "" }, "l", true, true)
    curl.post({
        url = url,
        stream = function(_, chunk)
            if chunk then
                local res = vim.json.decode(chunk)
                if res.error then
                    print(res.error)
                end
                if not res.done then
                    vim.schedule(function()
                        vim.api.nvim_put({ add_line_break(res.response) }, "", true, true)
                    end)
                else
                    vim.schedule(function()
                        vim.api.nvim_put({ "____________________" }, "l", true, true)
                    end)
                end
            end
        end,
        body = vim.json.encode({
            model = "llama3:8b",
            prompt = prompt_text
        })
    })
end

local function main(url)
    make_window()
    vim.api.nvim_buf_set_keymap(0, "n", "<space><space>", "", {
        callback = (function()
            prompt(url)
        end)
    })
end

M.setup = function(opts)
    opts = opts or {} -- defaults to empty table
    local url = opts.url or "http://127.0.0.1:11434/api/generate"
    vim.api.
        nvim_create_user_command(
            "OllamaChat", (function()
                main(url)
            end), {})
end

return M

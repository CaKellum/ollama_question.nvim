local curl = require("plenary.curl")
local popup = require("plenary.popup")

-- make split window	
local function make_window()
	local buf = vim.api.nvim_create_buf(true, true)
	popup.create(buf, {
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
		title = "Ollama Chat"
	})
end

local grab_buffer = function ()
	local buffer = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
	return table.concat(buffer, "\n")
end

local function prompt()
	local prompt_text = grab_buffer()
	vim.api.nvim_put({"", ""}, "l", true, true)
	curl.post({
		url = "http://192.168.1.85:11434/api/generate",
		stream = function (_, chunk)
			if chunk then
				local res = vim.json.decode(chunk)
				if not res.done then
					vim.schedule(function ()
						vim.api.nvim_put({res.response}, "", true, true)
					end)
				else
					vim.schedule(function ()
						vim.api.nvim_put({"____________________"}, "l", true, true)
					end)
				end
			end
		end,
		body = vim.json.encode({
			model = "llama3.2:3b",
			prompt = prompt_text
		})
	})
end

local function main()
	make_window()
	vim.api.nvim_buf_set_keymap(0, "n","<space><space>y" , "", {callback = prompt})
end


vim.api.nvim_create_user_command("OllamaChat",main, {})

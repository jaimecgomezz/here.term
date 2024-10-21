local M = {}

local function notify(message, level)
	vim.notify(message, level, { title = "HereTerm" })
end

local function map(mode, combo, mapping, desc)
	if combo then
		vim.keymap.set(mode, combo, mapping, { silent = true, desc = desc })
	end
end

local function return_to_buffer(here_prevbuff, here_termbuff)
	-- Enter the buffer we were at prior to entering our terminal
	if vim.fn.buflisted(here_prevbuff) == 1 and here_prevbuff ~= here_termbuff then
		vim.cmd("buffer" .. here_prevbuff)
		return
	end

	-- If the buffer we were at prior to entering our terminal isn't listed
	-- anymore, attempt to enter any of the lastly edited buffers
	for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
		if vim.fn.buflisted(buffer) == 1 and buffer ~= here_termbuff then
			vim.cmd("silent buffer" .. buffer)
			return
		end
	end

	-- If there's no remaining buffers to return to, run the startup command
	vim.cmd(vim.g.here_startup_command)

	-- Notify in case an invalid startup command was provided
	if vim.g.here_startup_command_invalid and not vim.g.here_startup_command_invalid_notified then
		notify("Invalid startup command provided: " .. vim.g.here_startup_command_invalid, vim.log.levels.WARN)
		vim.g.here_startup_command_invalid_notified = true
	end
end

local function exit_terminal(here_prevbuff, curbuff, here_termbuff)
	-- Prevent creating/entering out terminal if within another terminal, like a
	-- REPL, Overseer console, Toggleterm, etc
	if curbuff ~= here_termbuff then
		return
	end

	return_to_buffer(here_prevbuff, here_termbuff)
end

local function enter_terminal(currbuff, here_termbuff)
	-- Switch to existing terminal buffer
	if vim.fn.bufexists(here_termbuff) == 1 then
		vim.cmd("silent buffer" .. here_termbuff)
		vim.cmd.startinsert()
	else
		-- Create a terminal buffer
		vim.cmd("silent terminal")

		vim.g.here_termbuff = vim.api.nvim_get_current_buf()
		vim.bo.buflisted = false
		vim.cmd.startinsert()
	end
end

M.toggle_terminal = function()
	local here_prevbuff = vim.g.here_prevbuff
	local here_termbuff = vim.g.here_termbuff
	local currbuff = vim.api.nvim_get_current_buf()

	if vim.bo.buftype == "terminal" then
		exit_terminal(here_prevbuff, currbuff, here_termbuff)
	else
		vim.g.here_prevbuff = currbuff
		enter_terminal(currbuff, here_termbuff)
	end
end

M.kill_terminal = function()
	-- Do nothing if there's no terminal event set
	if not vim.g.here_termbuff then
		return
	end

	-- Update the `here_prevbuff` to to current one if we're killing it behind
	-- the scenes in order to prevent switching to another buffer
	if vim.bo.filetype ~= "terminal" then
		vim.g.here_prevbuff = vim.api.nvim_get_current_buf()
	end

	-- Go to our previous buffer
	return_to_buffer(vim.g.here_prevbuff, vim.g.here_termbuff)

	-- Wipe terminal
	vim.cmd("silent! bdelete! " .. vim.g.here_termbuff)
	vim.g.here_termbuff = nil
end

M.setup = function(opts)
	opts = vim.tbl_extend("keep", opts or {}, {
		startup_command = "enew",
		mappings = {
			enable = true,
			toggle = "<C-;>",
			kill = "<C-S-;>",
		},
		extra_mappings = {
			enable = true,
			escape = "<C-x>",
			left = "<C-w>h",
			down = "<C-w>j",
			up = "<C-w>k",
			right = "<C-w>l",
		},
	})

	if vim.fn.exists(":" .. opts.startup_command) > 0 then
		vim.g.here_startup_command = opts.startup_command
	else
		vim.g.here_startup_command = "enew"
		vim.g.here_startup_command_invalid = tostring(opts.startup_command)
		vim.g.here_startup_command_invalid_notified = false
	end

	-- here.term mappings
	if opts.mappings.enable then
		map({ "n", "i", "t" }, opts.mappings.toggle, M.toggle_terminal, "Toggle terminal")
		map({ "n", "i", "t" }, opts.mappings.kill, M.kill_terminal, "Kill terminal")
	end

	if opts.extra_mappings.enable then
		-- Exit terminal
		map(
			"t",
			opts.extra_mappings.escape,
			vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true),
			"Escape terminal mode"
		)

		-- Move in/out terminal
		map("t", opts.extra_mappings.left, [[<C-\><C-n><C-W>h]], "Move to left window")
		map("t", opts.extra_mappings.down, [[<C-\><C-n><C-W>j]], "Move to window down")
		map("t", opts.extra_mappings.up, [[<C-\><C-n><C-W>k]], "Move to window up")
		map("t", opts.extra_mappings.right, [[<C-\><C-n><C-W>l]], "Move to window right")
	end
end

return M

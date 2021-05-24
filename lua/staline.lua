local cmd = vim.api.nvim_command

M = {}
local Tables = require('tables')

function M.setup(opts)
	if not opts then opts = {} end

	for k,v in pairs(opts) do
		for k1,v1 in pairs(opts[k]) do Tables[k][k1] = v1 end
	end

    vim.o.statusline = '%!v:lua.require\'staline\'.get_statusline()'
end

local function get_branch()
	local ok, _ = pcall(require, 'plenary')
	if not ok then return "" end

	local branch_name = require('plenary.job'):new({
		command = 'git',
		args = { 'branch', '--show-current' },
		on_stdout = function(j, return_val)
		return return_val
	  end,
	}):sync()[1]
	return branch_name and ' '..branch_name or ""
end

local function call_highlights(modeColor)
	local lightGrey = "#303030"
	cmd('hi Noice guibg='..modeColor..' guifg='..fg)
	cmd('hi Arrow guifg='..modeColor..' guibg='..lightGrey)
	cmd('hi MidArrow guifg='..lightGrey..' guibg='..bg)
	cmd('hi BranchName guifg='..modeColor..' guibg='..bg)
end

function M.tabline_init()
	vim.o.tabline = '%!v:lua.require\'staline\'.get_tabline()'
end

function M.get_tabline()
	local nice = ""
	
	for i in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(i) == true then 
			local filename = vim.api.nvim_buf_get_name(i):match(".*%/(.+)") or "[No Name]"
			if filename:match("Vim.Buffer") then filename = "" end

			if vim.api.nvim_get_current_buf() == i then
				nice = nice.."%#Noice# "..filename.." "
			else
				nice = nice.." %#Tabline# "..filename.." "
			end
		end
	end

	return nice.."%#TablineFill#"
end

function M.get_statusline()

	for k, _ in pairs(Tables.defaults) do
		_G[k] = Tables.defaults[k]
	end

	local mode = vim.api.nvim_get_mode()['mode']
	local modeIcon	= Tables.mode_icons[mode] or " "
	local modeColor = Tables.mode_colors[mode] or "#e27d60"

	local extension = vim.fn.expand('%:e')
	local fullpath = vim.fn.expand('%:p') or ""
	local f_name = full_path and fullpath or fullpath:match("^.+/(.+)$") or ""
	local f_icon, icon_highlight  = require'nvim-web-devicons'.get_icon(filename, extension, {default = true})

	local right_side, left_side = "%=", "%="
	local edited = vim.bo.modified and "  " or " "

	if filename_position == "right" then right_side = ""
	elseif filename_position == "left" then left_side = ""
	elseif filename_position == "none" then f_name, f_icon = "", ""
	elseif filename_position == "center" then
	else f_name, f_icon = Tables.defaults.filename_position, "" end

	local s = '%#Noice#  '..modeIcon..' %#Arrow#'..leftSeparator
	..'%#MidArrow#'..leftSeparator.." %#BranchName#"..get_branch()..

	left_side.." "..f_icon.."%#BranchName# "..f_name..edited.. "%#MidArrow#"..right_side

	..rightSeparator..'%#Arrow#'..rightSeparator..'%#Noice#  '..line_column..cool_symbol ..' '

	call_highlights(modeColor)
	return s
end

return M


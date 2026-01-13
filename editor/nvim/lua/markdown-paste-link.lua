-- Paste URL over visual selection to create markdown link
-- Mimics GitHub's behavior of converting selected text + pasted URL into [text](url)

local M = {}

function M.paste_as_markdown_link()
  -- Exit visual mode to set '< and '> marks, then get positions
  vim.cmd("normal! ")
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_row = start_pos[2] - 1 -- Convert to 0-indexed
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3] -- end_col is exclusive in nvim_buf_get_text

  -- Get the selected text directly from buffer (no register needed)
  local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
  local selected_text = table.concat(lines, "\n")

  -- Get URL from system clipboard (untouched by our operations)
  local url = vim.fn.getreg("+")

  -- Trim whitespace from both
  selected_text = selected_text:gsub("^%s+", ""):gsub("%s+$", "")
  url = url:gsub("^%s+", ""):gsub("%s+$", "")

  -- Create markdown link
  local markdown_link = string.format("[%s](%s)", selected_text, url)

  -- Replace the selection directly in buffer (no register manipulation)
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { markdown_link })
end

function M.setup()
  -- Create the command for markdown files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      -- Create a buffer-local command
      vim.api.nvim_buf_create_user_command(0, "MarkdownPasteLink", function()
        M.paste_as_markdown_link()
      end, {
        range = true,
        desc = "Paste URL as markdown link over selection",
      })
    end,
  })
end

return M

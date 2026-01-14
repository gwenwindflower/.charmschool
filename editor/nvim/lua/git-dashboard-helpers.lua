local M = {}

M.detect_git_platform = function(git_root)
  -- Check if we're in a git repo
  if not git_root then
    return { name = nil, repo_url = nil }
  end

  -- Get the remote URL using git
  local ok, remote_output = pcall(vim.fn.system, { "git", "-C", git_root, "remote", "get-url", "origin" })
  if not ok or vim.v.shell_error ~= 0 or not remote_output or remote_output == "" then
    return { platform = nil, repo_url = nil }
  end

  local remote = vim.trim(remote_output)

  -- Detect platform by checking the normalized URL against known patterns
  local platform = nil
  if remote:match("github%.com") then
    platform = "github"
  elseif remote:match("gitlab%.com") then
    platform = "gitlab"
  elseif remote:match("bitbucket%.org") then
    platform = "bitbucket"
  end

  return { name = platform, repo_url = remote }
end

-- Platform-specific icons (using Nerd Font icons)
M.git_platform_icons = {
  github = " ",
  gitlab = " ",
  bitbucket = " ",
}

-- Platform display names
M.git_platform_names = {
  github = "GitHub",
  gitlab = "GitLab",
  bitbucket = "Bitbucket",
}

return M

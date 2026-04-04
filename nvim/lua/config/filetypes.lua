vim.filetype.add({
    extension = {
        yml = function(path, bufnr)
            if path:match("playbooks") or path:match("roles") or path:match("tasks") then
                return "yaml.ansible"
            end

            -- Check file content for Ansible keywords
            local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
            if content:match("^%-%s?hosts:") or content:match("^%-%s?name:") then
                return "yaml.ansible"
            end

            return "yaml"
        end,
    },
    pattern = {
        -- Force specific filenames
        [".*/playbooks/.*%.yml"]    = "yaml.ansible",
        [".*/roles/.*%.yml"]        = "yaml.ansible",
        ["ansible.yml"]             = "yaml.ansible",
        [".*%prod.*%conf"]          = "nginx",
        [".*nginx.*%.conf"]         = "nginx",
    },
})

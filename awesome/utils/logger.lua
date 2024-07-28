local naughty = require("naughty")

local serpent
local serpent_loaded, serpent_error = pcall(function()
    serpent = require("lib.serpent.src.serpent")
end)

if not serpent_loaded then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Error",
        text = "Failed to load serpent library: " .. serpent_error
    })
    -- Define a dummy log_to_file function to prevent further errors
    return {
        log_to_file = function() end
    }
end

local function to_table(value)
    local t = type(value)
    if t == "userdata" or t == "cdata" then
        local meta = getmetatable(value)
        if meta and meta.__tostring then
            return tostring(value)
        else
            local tbl = {}
            for k, v in pairs(value) do
                tbl[k] = to_table(v)
            end
            return tbl
        end
    elseif t == "table" then
        local tbl = {}
        for k, v in pairs(value) do
            tbl[k] = to_table(v)
        end
        return tbl
    else
        return value
    end
end

local function log_to_file(data)
    local date = os.date("%Y-%m-%d")
    local log_file_path = os.getenv("HOME") .. "/.config/awesome/logs/debug_" .. date .. ".log"
    local log_file = io.open(log_file_path, "a")
    local converted_data = to_table(data)
    local serialized_data = serpent.block(converted_data, { comment = false, numformat = "%.2g", indent = "  " })
    local time = os.date("[%H:%M:%S]")
    local log_entry = time .. ': ' .. serialized_data .. "\n"
    log_file:write(log_entry)
    log_file:close()
end

return {
    log_to_file = log_to_file
}

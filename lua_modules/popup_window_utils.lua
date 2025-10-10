-- lua_modules/popup_window_utils.lua

local M = {}

-- Center text in popup window (approximate, not pixel-perfect)
function M.auto_center(text, char_length_mode)
    local cent_length = #text
    local ic
    if char_length_mode ~= 2 then
        ic = math.floor(53 - (cent_length * 0.80) - 4)
    else
        ic = cent_length
    end
    local result = string.rep("&nbsp;", ic)
    if not char_length_mode then
        return result .. " " .. text
    elseif char_length_mode == 2 then
        return result
    else
        return "There are " .. ic .. " characters in this phrase, use this argument for Option 2 in Argument 2"
    end
end

-- Break line for popup window
function M.break_line()
    return "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_________________________________<br>"
end

-- Indent for popup window
function M.indent()
    return "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
end

-- Create a hyperlink
function M.hyperlink(url, text)
    return "<a href=\"" .. url .. "\">" .. text .. "</a>"
end

-- Color tag for popup window (partial color map, add more as needed)
M.colors = {
    Red = "#FF0000",
    Turquoise = "#00FFFF",
    ["Light Blue"] = "#0000FF",
    Yellow = "#FFFF00",
    Pink = "#FF00FF",
    Black = "#000000",
    White = "#FFFFFF",
    ["Light Grey"] = "#C0C0C0",
    ["Dark Grey"] = "#808080",
    Orange = "#FF8040",
    Brown = "#804000",
    -- ... add more as needed ...
}

function M.color(color_name)
    local hex = M.colors[color_name]
    if not hex then
        return "<a href=\"http://www.computerhope.com/htmcolor.htm\">You have not inserted a color name, you can find them at this link</a>"
    else
        return "<c \"" .. hex .. "\">"
    end
end

return M
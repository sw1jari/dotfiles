-- writes the current track to $XDG_RUNTIME_DIR/music-now for the dwm status bar
local dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local out = dir .. "/music-now"

local function write()
    local title = mp.get_property("media-title") or ""
    local artist = mp.get_property("metadata/by-key/artist")
    local pos = mp.get_property_number("playlist-pos-1", 1)
    local count = mp.get_property_number("playlist-count", 1)
    local icon = mp.get_property_native("pause") and "⏸" or "♪"

    local line = icon .. " "
    if artist and artist ~= "" and not title:find(artist, 1, true) then
        line = line .. artist .. " - "
    end
    line = line .. title
    if count > 1 then
        line = line .. string.format(" [%d/%d]", pos, count)
    end

    local f = io.open(out, "w")
    if f then
        f:write(line, "\n")
        f:close()
    end
end

mp.register_event("file-loaded", write)
mp.observe_property("pause", "native", write)
mp.observe_property("metadata", "native", write)
mp.register_event("shutdown", function() os.remove(out) end)

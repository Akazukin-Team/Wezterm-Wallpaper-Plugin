local wezterm = require 'wezterm'
local M = {}

-- Config structure with sensible defaults
local WallpaperConfig = {
    paths = {},
    interval = 30,
    max_depth = 1,
    opacity = 1,
    brightness = 0.125,
    -- Exclude WebP as it's not supported yet (pending PR)
    -- https://github.com/wezterm/wezterm/pull/7694
    extensions = {'.png', '.jpg', '.jpeg', '.bmp', '.gif'}
}
WallpaperConfig.__index = WallpaperConfig

-- Generate default config
function M.create_config()
    local self = setmetatable({}, WallpaperConfig)
    return self
end

local function append_table(dst, src)
    for _, v in ipairs(src) do
        table.insert(dst, v)
    end
end

-- Check if the path is a directory
-- path: path to check that is a directory
local function is_directory(path)
    local ok, res = pcall(wezterm.read_dir, path)
    return ok and type(res) == 'table'
end

-- Check if the file is an image by its extension
-- path: path to check that is an image
local function is_image(path)
    local lower_path = path:lower()
    for _, ext in ipairs(WallpaperConfig.extensions) do
        if lower_path:sub(-#ext) == ext then
            return true
        end
    end
    return false
end

-- Scans a directory for children
-- path: directory to scan to collect files
local function get_files(path)
    local ok, res = pcall(wezterm.read_dir, path)
    if ok and type(res) == 'table' then
        return res
    end
    wezterm.log_error('Failed to read directory: ' .. path)
    return {}
end

local function collect_files(dir, depth)
    local filtered_files = {}
    local files = get_files(dir)

    for _, path in ipairs(files) do
        if is_directory(path) then
            if depth > 0 then
                local sub_files = collect_files(path, depth - 1)
                append_table(filtered_files, sub_files)
            end
        else
            table.insert(filtered_files, path)
        end
    end
    return filtered_files
end

-- Recursively scans a directory to collect image paths
-- dir: directory to scan
-- depth: Maximum search depth (0 for the directory itself only)
local function collect_images(dir, depth)
    local files = collect_files(dir, depth)
    local imgs = {}
    for _, path in ipairs(files) do
        if is_image(path) then
            table.insert(imgs, path)
        end
    end
    return imgs
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- cache images per provided path to avoid heavy work every interval
local cached_images = {}
local function collect_and_cache_images(paths, max_depth)
    local images = {}
    for path, _ in pairs(cached_images) do
        if not has_value(images, path) then
            cached_images[path] = nil
        end
    end

    for _, path in ipairs(paths) do
        -- Only collect images if the path is not cached yet
        if not cached_images[path] then
            if is_directory(path) then
                cached_images[path] = collect_images(path, max_depth)
            elseif is_image(path) then
                cached_images[path] = path
            end
        end
        if cached_images[path] then
            append_table(images, cached_images[path])
        end
    end
    return images
end

local last_image = nil
local function update_background(window, config)
    wezterm.log_info('Checking ' .. #config.paths .. ' paths for new background...')
    local images = collect_and_cache_images(config.paths, config.max_depth)
    wezterm.log_info('Found ' .. #images .. ' images.')

    if #images > 0 then
        math.randomseed(os.time() + os.clock() * 1000)
        local random_image = images[math.random(#images)]
        -- Only change background when the image changed
        if random_image ~= last_image then
            window:set_config_overrides({
                background = {{
                    source = {
                        File = random_image
                    },
                    opacity = config.opacity,
                    hsb = {
                        brightness = config.brightness
                    }
                }}
            })
            wezterm.log_info('Background changed to: ' .. random_image)
            last_image = random_image
        end
    end
end

local cur_cfg = nil
local last_update = 0
-- Register periodic updater
wezterm.on('update-status', function(window, pane)
    local now = os.time()
    if cur_cfg and now - last_update >= cur_cfg.interval then
        last_update = now
        update_background(window, cur_cfg)
    end
end)

-- Update the background with scheduled timer
---@field config WallpaperConfig
function M.setup(config)
    cur_cfg = config
    last_update = 0
end

return M

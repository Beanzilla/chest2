
-- Settings!
chest2.settings = {}

local settings = chest2.settings

settings.pages = minetest.settings:get("chest2.max_pages")

if settings.pages == nil then
    settings.pages = 3
    minetest.settings:set("chest2.max_pages", 3)
end

settings.craft_chest = minetest.settings:get_bool("chest2.craft_chest")

if settings.craft_chest == nil then
    settings.craft_chest = false
    minetest.settings:set_bool("chest2.craft_chest", false)
end

settings.craft_remote = minetest.settings:get_bool("chest2.craft_remote")

if settings.craft_remote == nil then
    settings.craft_remote = false
    minetest.settings:set_bool("chest2.craft_remote", false)
end

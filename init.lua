
--[[
    Chest2
    A multi page chest node.

    Also comes with easy gui for adding users or removing users
    from and to the chest node.

    Additional in 2022:

    - Make a remote which will allow accessing a chest from anywhere
]]

-- Public API (Also used by some internals)
chest2 = {}

chest2.modpath = minetest.get_modpath("chest2")
chest2.VERSION = "1.0.1"
chest2.store = minetest.get_mod_storage()

if minetest.registered_nodes["default:stone"] then
    chest2.GAMEMODE = "MTG"
elseif minetest.registered_nodes["mcl_deepslate:deepslate"] then
    chest2.GAMEMODE = "MCL5"
elseif minetest.registered_nodes["mcl_core:stone"] then
    chest2.GAMEMODE = "MCL2"
else
    chest2.GAMEMODE = "???"
end

dofile(chest2.modpath.."/tool_belt.lua") -- Utility functions
dofile(chest2.modpath.."/settings.lua") -- Settings
dofile(chest2.modpath.."/internal.lua") -- Internal Chest2 storage

dofile(chest2.modpath.."/register.lua") -- The Chest2
dofile(chest2.modpath.."/crafting.lua") -- Crafting

chest2.tools.log("Version:  "..chest2.VERSION)
chest2.tools.log("Gamemode: "..chest2.GAMEMODE)

local fake = chest2.get_chest("0 1 2")
fake.owner = "singleplayer"
fake.display_name = "Fake"
fake.inv:add_item("c1", ItemStack("default:cobble 1"))
fake.inv:add_item("c2", ItemStack("default:steel_ingot 2"))
fake.inv:add_item("c3", ItemStack("default:steelblock 3"))
chest2.set_chest("0 1 2", fake)
chest2.tools.log("Fake done!")

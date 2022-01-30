
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

chest2.S = minetest.get_translator("chest2")
chest2.modpath = minetest.get_modpath("chest2")
chest2.VERSION = "1.0.1"

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

dofile(chest2.modpath.."/register.lua") -- The Chest2
dofile(chest2.modpath.."/crafting.lua") -- Crafting

chest2.tools.log("Version:  "..chest2.VERSION)
chest2.tools.log("Gamemode: "..chest2.GAMEMODE)


local empty = ""
local gold_block = ""
local diamond_block = ""

if chest2.GAMEMODE == "MTG" then
    gold_block = "default:goldblock"
    diamond_block = "default:diamondblock"
elseif chest2.GAMEMODE == "MCL2" or chest2.GAMEMODE == "MCL5" then
    gold_block = "mcl_core:goldblock"
    diamond_block = "mcl_core:diamondblock"
end

if chest2.settings.craft_chest == true then
    minetest.register_craft({
        output = "chest2:chest 1",
        recipe = {
            {diamond_block, gold_block, diamond_block},
            {gold_block, empty, gold_block},
            {diamond_block, gold_block, diamond_block}
        }
    })
end

if chest2.settings.craft_remote == true then
    minetest.register_craft({
        output = "chest2:remote_off 1",
        recipe = {
            {empty, gold_block, empty},
            {gold_block, diamond_block, gold_block},
            {gold_block, diamond_block, gold_block}
        }
    })
end

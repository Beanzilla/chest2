
chest2.get_chest = function (pos)
    if type(pos) ~= "string" then
        pos = chest2.tools.pos2str(pos)
    end
    local c2 = chest2.store:get_string(pos) or nil
    if c2 == nil or c2 == "" then
        c2 = {}
        c2.pos = pos
        c2.owner=""
        c2.mode=0
        c2.names = {}
        c2.display_name = "Chest2"
        c2.max_pages = chest2.settings.pages
        c2.inv = minetest.create_detached_inventory(c2.pos)
        for pg=1, c2.max_pages, 1 do
            c2.inv:set_size("c"..tostring(pg), 60)
        end
        chest2.set_chest(c2.pos, c2)
        return c2
    else
        c2 = minetest.deserialize(c2) or {}
        if c2.inv then
            if chest2.settings.debug_mod == true then
                chest2.tools.log("Decompressing inventory...")
            end

            local inv = minetest.create_detached_inventory(c2.pos)
            local pg = 0
            -- Form the individual pages
            for page, tab in pairs(c2.inv) do
                inv:set_size(page, 60)
                pg = pg + 1
                if chest2.settings.debug_mod == true then
                    chest2.tools.log("Making page "..tostring(page).." ("..tostring(pg)..")")
                end
            end
            -- Convert form table of table to table of ItemStack
            for page, tab in pairs(c2.inv) do
                for idx, stack in ipairs(tab) do
                    --table.insert(inv_tab[page], idx, ItemStack(stack))
                    inv:add_item(page, ItemStack(stack))
                    if chest2.settings.debug_mod == true then
                        chest2.tools.log("Created item from '"..minetest.serialize(stack).."' ("..tostring(idx)..")")
                    end
                end
            end
            if chest2.settings.debug_mod == true then
                chest2.tools.log("Decompressed inventory")
            end
            c2.inv = inv
        end
        return c2
    end
end

chest2.set_chest = function (pos, data)
    if data.inv ~= nil then
        if chest2.settings.debug_mod == true then
            chest2.tools.log("Compressing inventory...")
        end
        local inv = data.inv:get_lists()
        local inv_tab = {}
        local max_pgs = 0
        -- Form the individual pages
        for pg, tab in pairs(inv) do
            inv_tab[pg] = {}
            max_pgs = max_pgs + 1
            if chest2.settings.debug_mod == true then
                chest2.tools.log("Making page "..pg.." ("..tostring(max_pgs)..")")
            end
        end
        -- Convert form table of ItemStacks to table of table
        for page, tab in pairs(inv) do
            for idx, stack in ipairs(tab) do
                table.insert(inv_tab[page], stack:to_table())
                -- Only outputs if the stack isn't empty
                if chest2.settings.debug_mod == true and stack:to_string() ~= "" then
                    chest2.tools.log("Created table from '"..stack:to_string().."' ("..tostring(idx)..")")
                end
            end
        end
        if chest2.settings.debug_mod == true then
            chest2.tools.log("Compressed inventory")
            chest2.tools.log(minetest.serialize(inv_tab))
        end
        data.inv = inv_tab
    end
    chest2.store:set_string(pos, minetest.serialize(data))
end

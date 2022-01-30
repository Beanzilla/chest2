
chest2.remotes = {}
local function get_context(name)
    local context = chest2.remotes[name] or {}
    chest2.remotes[name] = context
    return context
end

minetest.register_on_leaveplayer(function(player)
    chest2.remotes[player:get_player_name()] = nil
end)

chest2.showform = function(pos,player)
	local meta = minetest.get_meta(pos)
	local uname = player:get_player_name()
	if meta:get_string("owner")~=uname and not minetest.check_player_privs(uname, {protection_bypass=true}) then
        local users = chest2.tools.split(meta:get_string("names"), "\n")
        local found = false
        for x=1, #users, 1 do
            if users[x] == player then
                found = true
                break
            end
        end
        if found ~= true then
            chest2.tools.log("Chest2:chest blocked '"..uname.."' from accessing chest at "..minetest.pos_to_string(pos))
            return
        end
    end
	--local inv = meta:get_inventory()
    local inv = minetest.get_inventory({ type="node", pos=pos })
	local spos=pos.x .. "," .. pos.y .. "," .. pos.z
	local title = meta:get_string("title")
    local names = meta:get_string("names")
    local page = meta:get_int("page")
    local op = meta:get_int("open")
    local open = ""
	local mclform = rawget(_G, "mcl_formspec") or nil

	local gui=""

    gui=gui.."size[16,10]"

    if op==0 then
        open="Only U"
    elseif op==1 then
        open="Members"
    else
        open="Public"
    end

	if title=="" then
		title="Chest2"
	end

	gui=gui .. ""

    .."button[12,1; 1.9,1;save;Save]"
    .."button[12,2; 1.9,1;open;" .. open .."]"
    .."label[12, 3;Members List]"
    .."label[12, 3.4;(Inventory Access)]"
    .."textarea[12.2,4;4,5;names;;" .. names  .."]"

    .."button[-0.2,7;1,1;prev;<]"
    .."button[0.95,7;1,1;next;>]"
    .."label[0.65,7.2;".. minetest.formspec_escape(tostring(page)) .. "]"

    --chest2.tools.log("main"..tostring(page).." ("..tostring(inv:get_size("main"..tostring(page)))..", "..minetest.serialize(inv:get_location())..")")

	if chest2.GAMEMODE == "MCL2" or chest2.GAMEMODE == "MCL5" or chest2.GAMEMODE == "MCL" then
		gui=gui..""
        .."list[nodemeta:" .. spos .. ";main"..tostring(page)..";0,0;12,5;]"
        --.."list[context;main"..tostring(page)..";0,0;12,5]"
		..mclform.get_itemslot_bg(0, 0, 12, 5)
		.."list[current_player;main;2,6;9,3;]"
		..mclform.get_itemslot_bg(2, 6, 9, 3)
	else
        gui=gui..""
        .."list[nodemeta:" .. spos .. ";main"..tostring(page)..";0,0;12,5;]"
        --.."list[context;main"..tostring(page)..";0,0;12,5]"
		.."list[current_player;main;2,6;8,4;]"
	end
	gui=gui .. ""
    .."listring[nodemeta:" .. spos .. ";main"..tostring(page).."]"
	--.."listring[current_player;main"..tostring(page).."]"

	meta:set_string("formspec", gui)
    return true
end

minetest.register_node("chest2:chest", {
	description = "Chest2",
	tiles = {
        "chest2_plate.png", -- top
        "chest2_plate.png", -- bottom
        "chest2_side1.png", -- right
        "chest2_side0.png", -- left
        "chest2_plate.png", -- back
        "chest2_front.png", -- front
    },
	groups = {choppy = 2, oddly_breakable_by_hand = 1,tubedevice = 1, tubedevice_receiver = 1,mesecon=2, handy=1,axey=1},
	paramtype2 = "facedir",
	sunlight_propagates = true,
	light_source = 3,
	tube = {insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
            local added = stack
            for x=1, chest2.settings.pages, 1 do
                if inv:room_for_item("main"..tostring(x)) then
                    added = inv:add_item("main"..tostring(x), stack)
                    break
                end
            end
			return added
		end,
    can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
            local valid = false
            for x=1, chest2.settings.pages, 1 do
                if inv:room_for_item("main"..tostring(x), stack) then
                    valid = true
                    break
                end
            end
			return valid
		end,
    --input_inventory = "main", -- Invalid, won't work since we use paging
    connect_sides = {left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1}},
    after_place_node = function(pos, placer)
		local meta=minetest.get_meta(pos)
		local name=placer:get_player_name()
		meta:set_string("owner",name)
		meta:set_string("infotext", "Chest2 (" .. name .. ")")
        chest2.showform(pos, placer) -- Actually this makes the formspec meta field
	end,
    on_construct = function(pos)
		local meta=minetest.get_meta(pos)
        meta:set_int("page", 1)
        meta:set_int("max_page", chest2.settings.pages)
        meta:set_string("names", "")
        meta:set_int("open", 0)
		--meta:get_inventory():set_size("main", 60)
        local inv = meta:get_inventory()
		for x=1, meta:get_int("max_page"), 1 do
            inv:set_size("main"..tostring(x), 60)
            chest2.tools.log("Inventory: main"..tostring(x).." with 60")
        end
	end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if (minetest.get_meta(pos):get_string("owner")==player:get_player_name() or minetest.check_player_privs(player:get_player_name(), {protection_bypass=true})) then
		    return stack:get_count()
		end
        local meta = minetest.get_meta(pos)
        if meta:get_int("open") == 1 then
            local users = chest2.tools.split(meta:get_string("names"), "\n")
            for x=1, #users, 1 do
                if users[x] == player then
                    return stack:get_count()
                end
            end
        elseif meta:get_int("open") == 2 then
            return stack:get_count()
        end
        chest2.tools.log("chest2:chest blocked player '"..player:get_player_name().."' from putting "..stack:get_name().." x "..tostring(stack:get_count()))
		return 0
	end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.get_meta(pos):get_string("owner")==player:get_player_name() or minetest.check_player_privs(player:get_player_name(), {protection_bypass=true}) then
		    return stack:get_count()
		end
        if meta:get_int("open") == 1 then
            local users = chest2.tools.split(meta:get_string("names"), "\n")
            for x=1, #users, 1 do
                if users[x] == player then
                    return stack:get_count()
                end
            end
        elseif meta:get_int("open") == 2 then
            return stack:get_count()
        end
        chest2.tools.log("chest2:chest blocked player '"..player:get_player_name().."' from taking "..stack:get_name().." x "..tostring(stack:get_count()))
		return 0
	end,
    can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		local p=player:get_player_name()
        local empty = true
        for x=1, meta:get_int("max_page"), 1 do
            if not inv:is_empty("main"..tostring(x)) then
                empty = false
                break
            end
        end
		if (meta:get_string("owner")==p or minetest.check_player_privs(p, {protection_bypass=true})) and empty or meta:get_string("owner")=="" then
			return true
		end
	end,
    on_receive_fields = function(pos, formname, fields, sender)
        --chest2.tools.log("'"..formname.."'")
        local meta = minetest.get_meta(pos)

        if fields.next then
            --chest2.tools.log("Next Page")
            local page = meta:get_int("page")
            page=page+1
            if page > meta:get_int("max_page") then page = 1 end
            meta:set_int("page", page)
            chest2.showform(pos, sender)
        end
        if fields.prev then
            --chest2.tools.log("Previous Page")
            local page = meta:get_int("page")
            page=page-1
            if page < 1 then page = meta:get_int("max_page") end
            meta:set_int("page", page)
            chest2.showform(pos, sender)
        end

        if sender:get_player_name() ~= meta:get_string("owner") then
            return
        end

        if fields.save then
            --chest2.tools.log("Save Names")
            meta:set_string("names", fields.names)
            chest2.showform(pos, sender)
        end

        if fields.open then
            --chest2.tools.log("Open Access")
            local open=meta:get_int("open")
            open=open+1
            if open>2 then open=0 end
            meta:set_int("open",open)
            chest2.showform(pos, sender)
        end
    end,
})

chest2.connect_remote = function (itemstack, user, pointed_thing)
    if pointed_thing ~= nil then
        if pointed_thing.under ~= nil then
            local node = minetest.get_node_or_nil(pointed_thing.under)
            if node.name == "chest2:chest" then
                local connected = ItemStack("chest2:remote_on")
                local con_meta = connected:get_meta()
                con_meta:set_string("connection", chest2.tools.pos2str(pointed_thing.under))
                local meta_dat = get_context(user:get_player_name())
                meta_dat.pos = pointed_thing.under
                minetest.chat_send_player(user:get_player_name(), "Connected to "..minetest.pos_to_string(pointed_thing.under))
                return connected
            end
        end
    end
end

minetest.register_craftitem("chest2:remote_off", {
    short_description = "Remote (Disconnected)",
    description = "Remote (Disconnected)\nPunch a chest to connect",
    inventory_image = "chest2_remote_off.png",
    stack_max = 1,
    on_use = chest2.connect_remote,
    on_place = chest2.connect_remote,
    on_secondary_use = chest2.connect_remote,
})

chest2.use_remote = function (itemstack, user, pointed_thing)
    local meta = itemstack:get_meta()
    local pointed_chest = false
    -- Perform reconnect or attempt to access node
    if pointed_thing ~= nil then -- Perform reconnect method
        if pointed_thing.under ~= nil then
            local node = minetest.get_node_or_nil(pointed_thing.under)
            if node.name == "chest2:chest" then
                local con_meta = itemstack:get_meta()
                con_meta:set_string("connection", chest2.tools.pos2str(pointed_thing.under))
                minetest.chat_send_player(user:get_player_name(), "Connected to "..minetest.pos_to_string(pointed_thing.under))
                local meta_dat = get_context(user:get_player_name())
                meta_dat.pos = pointed_thing.under
                pointed_chest = true
                return itemstack
            end
        end
    end
    if not pointed_chest then
        -- Check connection
        if meta:get_string("connection") ~= "" or meta:get_string("connection") ~= nil then
            local pos = chest2.tools.str2pos(meta:get_string("connection"))
            local valid = false
            if pos ~= nil then
                -- Ensure the connection is valid
                if chest2.vm ~= nil then
                    chest2.vm:read_from_map(pos, pos)
                    local node = minetest.get_node_or_nil(pos)
                    if node ~= nil then
                        if node.name == "chest2:chest" then
                            valid = true
                        end
                    end
                else
                    chest2.vm = minetest.get_voxel_manip()
                    chest2.vm:read_from_map(pos, pos)
                    local node = minetest.get_node_or_nil(pos)
                    if node ~= nil then
                        if node.name == "chest2:chest" then
                            valid = true
                        end
                    end
                end
                -- If the connection is valid then attempt to show the formspec for that location
                if valid == true then
                    local rc = chest2.showform(pos, user)
                    if rc == true then
                        local nmeta = minetest.get_meta(pos)
                        local meta_dat = get_context(user:get_player_name())
                        meta_dat.pos = pos
                        minetest.show_formspec(user:get_player_name(), "chest2:remote_form", nmeta:get_string("formspec"))
                    else
                        minetest.chat_send_player(user:get_player_name(), "Connection "..minetest.pos_to_string(pos).." reported access denied")
                    end
                else
                    -- Reset the item back to off
                    local dis = ItemStack("chest2:remote_off")
                    minetest.chat_send_player(user:get_player_name(), "Disconnected from "..minetest.pos_to_string(pos))
                    local meta_dat = get_context(user:get_player_name())
                    meta_dat.pos = nil
                    return dis
                end
            else
                -- Reset the item back to off
                local dis = ItemStack("chest2:remote_off")
                minetest.chat_send_player(user:get_player_name(), "Network Error Disconnected")
                local meta_dat = get_context(user:get_player_name())
                meta_dat.pos = nil
                return dis
            end
        end
    end
end

minetest.register_craftitem("chest2:remote_on", {
    short_description = "Remote (Connected)",
    description = "Remote (Connected)\nPunch anywhere to open\nPunch a chest to reconnect",
    inventory_image = "chest2_remote_on.png",
    stack_max = 1,
    on_use = chest2.use_remote,
    on_place = chest2.use_remote,
    on_secondary_use = chest2.use_remote
})

minetest.register_on_player_receive_fields(function (player, formname, fields)
    if formname ~= "chest2:remote_form" then
        return
    end
    local meta_dat = get_context(player:get_player_name())
    if meta_dat == nil or meta_dat.pos == nil then
        return
    end
    local meta = minetest.get_meta(meta_dat.pos)

    if fields.next then
        --chest2.tools.log("Next Page")
        local page = meta:get_int("page")
        page=page+1
        if page > meta:get_int("max_page") then page = 1 end
        meta:set_int("page", page)
        chest2.showform(meta_dat.pos, player)
        minetest.show_formspec(player:get_player_name(), "chest2:remote_form", meta:get_string("formspec"))
    end
    if fields.prev then
        --chest2.tools.log("Previous Page")
        local page = meta:get_int("page")
        page=page-1
        if page < 1 then page = meta:get_int("max_page") end
        meta:set_int("page", page)
        chest2.showform(meta_dat.pos, player)
        minetest.show_formspec(player:get_player_name(), "chest2:remote_form", meta:get_string("formspec"))
    end

    if player:get_player_name() ~= meta:get_string("owner") then
        return
    end

    if fields.save then
        --chest2.tools.log("Save Names")
        meta:set_string("names", fields.names)
        chest2.showform(meta_dat.pos, player)
        minetest.show_formspec(player:get_player_name(), "chest2:remote_form", meta:get_string("formspec"))
    end

    if fields.open then
        --chest2.tools.log("Open Access")
        local open=meta:get_int("open")
        open=open+1
        if open>2 then open=0 end
        meta:set_int("open",open)
        chest2.showform(meta_dat.pos, player)
        minetest.show_formspec(player:get_player_name(), "chest2:remote_form", meta:get_string("formspec"))
    end
end)

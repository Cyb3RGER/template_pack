-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, location_table in pairs(LOCATION_MAPPING) do
        local location_code = location_table[1]
        if location_code then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", location_code))
            end
            local obj = Tracker:FindObjectForCode(location_code)
            if obj then
                if location_code:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", location_code))
            end
        end
    end
    -- reset items
    for _, item_table in pairs(ITEM_MAPPING) do
        local item_code = item_table[1]
        local item_type = item_table[2]
        if item_code and item_type then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", item_code, item_type))
            end
            local obj = Tracker:FindObjectForCode(item_code)
            if obj then
                if item_type == "toggle" then
                    obj.Active = false
                elseif item_type == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif item_type == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", item_type, item_code))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", item_code))
            end
        end
    end
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    -- manually run snes interface functions after onClear in case we are already ingame
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
    end
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local item_table = ITEM_MAPPING[item_id]
    if not item_table then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    local item_code = item_table[1]
    local item_type = item_table[2]
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", item_code, item_type))
    end
    if not item_code then
        return
    end
    local obj = Tracker:FindObjectForCode(item_code)
    if obj then
        if item_type == "toggle" then
            obj.Active = true
        elseif item_type == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif item_type == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", item_type, item_code))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", item_code))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[item_code] then
            LOCAL_ITEMS[item_code] = LOCAL_ITEMS[item_code] + 1
        else
            LOCAL_ITEMS[item_code] = 1
        end
    else
        if GLOBAL_ITEMS[item_code] then
            GLOBAL_ITEMS[item_code] = GLOBAL_ITEMS[item_code] + 1
        else
            GLOBAL_ITEMS[item_code] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local location_table = LOCATION_MAPPING[location_id]
    if not location_table and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    local location_code = location_table[1]
    if not location_code then
        return
    end
    local obj = Tracker:FindObjectForCode(location_code)
    if obj then
        if location_code:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", location_code))
    end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
    -- not implemented yet :(
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)

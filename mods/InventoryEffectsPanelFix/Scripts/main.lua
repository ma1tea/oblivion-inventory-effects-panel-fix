-- Inventory Effects Panel Fix 1.0.0
-- UE4SS Lua mod for The Elder Scrolls IV: Oblivion Remastered.
--
-- Fixes the item effects panel (potions, ingredients, enchanted items) not
-- appearing on the first hover after the inventory is opened.
--
-- Cause: VInventoryMenuViewModel lives for the whole game session, while the
-- VInventoryMenu widget is recreated on every open. The viewmodel keeps
-- bIsListViewHovered = true from the previous open, so the new widget's
-- SetIsListViewHovered(true) changes nothing, no field notification is sent,
-- and the details panel never switches to the effects page.
--
-- Fix: when a VInventoryMenu is created, reset a stale true to false, so the
-- game's own next "true" is a real change.
--
-- The mod registers no hooks and no key binds, and runs no code on hover.

local VERBOSE = false   -- true = log every inventory open to UE4SS.log

local TAG = "[InventoryEffectsPanelFix]"

local function log(msg)
    print(TAG .. " " .. msg .. "\n")
end

local function is_valid(obj)
    if obj == nil then return false end
    local ok, valid = pcall(function() return obj:IsValid() end)
    return ok and valid == true
end

-- GetFullName() is safe on a null object in UE4SS 3.0.1 (returns nil);
-- GetClass()/GetFName()/GetOuter() are not, so they are never used here.
local function full_name(obj)
    local ok, name = pcall(function() return obj:GetFullName() end)
    if ok and name then return name end
    return "<unnamed>"
end

local function reset_stale_list_hover()
    -- Also returns subclasses (VContainerMenuViewModel), which have the same flag.
    local ok, all = pcall(FindAllOf, "VInventoryMenuViewModel")
    if not ok or type(all) ~= "table" then
        if VERBOSE then log("no VInventoryMenuViewModel found") end
        return
    end

    for _, vm in ipairs(all) do
        if is_valid(vm) then
            local name = full_name(vm)
            if not name:find("Default__", 1, true) then
                local ok_read, hovered = pcall(function() return vm.bIsListViewHovered end)
                if ok_read and hovered == true then
                    local ok_set, err = pcall(function() vm:SetIsListViewHovered(false) end)
                    if not ok_set then
                        log("SetIsListViewHovered failed on " .. name .. ": " .. tostring(err))
                    elseif VERBOSE then
                        log("reset stale hover flag on " .. name)
                    end
                elseif VERBOSE then
                    log("hover flag is " .. tostring(hovered) .. " on " .. name)
                end
            end
        end
    end
end

local ok_notify, err_notify = pcall(function()
    NotifyOnNewObject("/Script/Altar.VInventoryMenu", function()
        -- The widget is still being constructed here; do the work on the next
        -- game-thread tick instead of inside the constructor.
        ExecuteInGameThread(reset_stale_list_hover)
    end)
end)

if ok_notify then
    log("1.0.0 loaded")
else
    log("failed to start: " .. tostring(err_notify))
end

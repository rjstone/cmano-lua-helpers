--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- cmano_builders.lua
-- See https://github.com/rjstone/cmano-lua-helpers for the latest version.
--
-- This is a collection of Lua functions for scenario editing in Command: Modern Air/Naval Operations
-- They are supposed to be macros to automate some time consuming aspects of scenario editing, like adding lots of units,
-- supplying a base with magazines, etc. They're not really intended to be added to things like Actions for events that run
-- during gameplay.
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

--[[ ---------------------------------------------------------------------------------------------------------------------------

How to use this file:

Place the file in the [CMANO Game Folder]/Lua directory (* see note) and you will be able to load it in the *Lua console* like
this:

    ScenEdit_RunScript("cmano_builders.lua")

Once you do that, you can invoke the "macro" functions by just typing the name of the function you want with the arguments you
want into the Lua console and clicking Run.

This may seem like too much trouble to some poeple, and it is for just adding a few units (which can easily be done manually). But
for adding large numbers of units such as an entire Carrier Battle Group or an airbase with all of its magazines, runways,
taxiways, hangars, facilities, and magazines, this can save you 100s of clicks on GUI controls and lots of time.

* Warning: in Build 998.9 and probably before, if you are using the Steam version of the game launched from Steam, or you've
  launched it from autorun.exe, then Lua scripts run from ScenEdit_RunScript() must go in  the [CMANO Game
  Folder]/GameMenu_CMANO/Lua directory instead because that's where the "current directory" used by Lua is.

--------------------------------------------------------------------------------------------------------------------------- ]]--



--------------------------------------------------------------------------------------------------------------------------------
-- Side Builder Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Create a side for every string in the provided list.
-- Could save a little bit of time in some cases if you have lots of sides.
-- Example:
--      CreateSides({"Me", "Everyone Else"})
function AddSides(sideslist)
    for i, v in ipairs(sideslist) do
        print("Creating side: " .. v)
        ScenEdit_AddSide({side=v})
    end
end

-- Remove sides for every string in the provided list.
-- Good for cleaning things up if you added lots of sides you no longer need.
-- Example:
--      RemoveSides({"Me", "Everyone Else"})
function RemoveSides(sideslist)
    for i, v in ipairs(sideslist) do
        print("Removing side: " .. v)
        ScenEdit_RemoveSide({side=v})
    end
end



--------------------------------------------------------------------------------------------------------------------------------
-- Side Builder Functions
--------------------------------------------------------------------------------------------------------------------------------

-- Print out all units for a side sorted by where they are based. Allows you to verify whether units are missing a base
-- and otherwise check the OOB.
-- Provided by michaelm75au
function PrintOOB(sidename)
    -- get all units on a side
    -- extract the base they are assigned to
    -- report by base
    local s = VP_GetSide({name=sidename})
    local function split(str, pat)
        local t = {}
        local fpat = "(.-)" .. pat
        local last_end = 1
        local s, e, cap = str:find(fpat, 1)
        while s do
            if s ~= 1 or cap ~= "" then
                table.insert(t,cap)
            end
            last_end = e+1
            s, e, cap = str:find(fpat, last_end)
        end
        if last_end <= #str then
            cap = str:sub(last_end)
            table.insert(t, cap)
        end
        return t
    end
    local function sortName(a,b)
        return(ScenEdit_GetUnit({guid=a}).name<ScenEdit_GetUnit({guid=b}).name)
    end
    local function orderedPairs(t,f)
        local array = {}
        for n in pairs(t) do array[#array +1] = n end
        table.sort(array,f)
        local index = 0
        return function ()
            index = index + 1
            return array[index],t[array[index]]
        end
    end
    -- main logic
    local base = {}
    for k,v in pairs(s.units)
    do
        local unit = ScenEdit_GetUnit({guid=v.guid})
        if unit.base ~= nil then
            local b = unit.base
            if b.group ~= nil then
                -- has a parent group; use it rather than the group members
                if base[b.group.guid] == nil and b.group.guid ~= v.guid then
                    base[b.group.guid] = v.guid
                elseif b.group.guid ~= v.guid then
                    base[b.group.guid] = base[b.group.guid] .. ',' .. v.guid
                end
            elseif base[b.guid] == nil and b.guid ~= v.guid then
                base[b.guid] = v.guid
            elseif b.guid ~= v.guid then
                base[b.guid] = base[b.guid] .. ',' .. v.guid
            end
        elseif unit.group ~= nil then
            local b = unit.group
            if base[b.guid] == nil and b.guid ~= v.guid then
                base[b.guid] = v.guid
            elseif b.guid ~= v.guid then
                base[b.guid] = base[b.guid] .. ',' .. v.guid
            end
        else
            -- units not based somewhere
            if base['xindependent'] == nil then
                base['xindependent'] = v.guid
            else
                base['xindependent'] = base['xindependent'] .. ',' .. v.guid
            end
        end
    end
    local k,v
    for k,v in orderedPairs(base)
    do
        print('\n')
        if k == 'xindependent' then
            print('Un-based units');
        else
            print('Base: ' .. ScenEdit_GetUnit({guid=k}).name);
        end
        local k1,v1
        local t = split(v,',')
        if t ~= nil then
            -- group like names together
            table.sort(t, sortName)
            for k1,v1 in pairs(t)
            do
                if v1 == k then next(t) end
                local unit = ScenEdit_GetUnit({guid=v1})
                if unit.condition ~= nil then
                    print(string.format(" %s (%s)",unit.name, unit.condition));
                else
                    print(string.format(" %s ",unit.name));
                end
            end
        end
    end
end

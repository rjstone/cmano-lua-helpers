--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- cmano_helpers.lua
-- See https://github.com/rjstone/cmano-lua-helpers for the latest version.
--
-- This is a collection of Lua helper/convenience/utility functions for Command: Modern Air/Naval Operations
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

--[[ ---------------------------------------------------------------------------------------------------------------------------

How to use this file:

There are two ways to use this.

#1 - If you only need one or two functions in only one script chunk then you could simply copy the
function from here and paste it into the script. But unless it is ONLY used in that ONE place, this will quickly
become unmanagable! This is strongly discouraged.

#2 - The best thing to do is copy and paste this entire file into an Lua Script "Action". That way it can easily
be evaluated on scenario load, making the functions available everywhere. Here's a quick way to do that.

1) Load up the Lua console and execute this code snippet in it ONCE to create the initialization event:

local event = ScenEdit_SetEvent('Lua Helper Init', {mode='add', IsRepeatable=true})
ScenEdit_SetTrigger({mode='add',type='ScenLoaded',name='Scenario Loaded'})
ScenEdit_SetEventTrigger(event.guid, {mode='add', name='Scenario Loaded'})
ScenEdit_SetAction({mode='add',type='LuaScript',name='Load Lua Helpers',
ScriptText='-- REPLACE THIS with the contents of cmano_helpers.lua'})
ScenEdit_SetEventAction(event.guid, {mode='add', name='Load Lua Helpers'})

2) Now, open up Editor->Event Editor->Actions, edit the "Load Lua Helpers" action, copy the whole
contents of this file to the clipboard (load in notepad.exe or a better text editor, Ctrl-A, Ctrl-C),
and paste it into the "Load Lua Helpers" script editor (click text area, right-click Select All, Ctrl-V).

3) Save the scenario, then reload the scenario from the file.

4) After you do this, every Lua script that runs in the scenario should be able to use every function
in this file.

You only need to do this process once for every new scenario. If you need to update the library of functions
for your scenario, just edit the "Load Lua Helpers" Action and copy/paste the new file, make one-off edits,
or whatever you need to do. Then save the scenario and load it from the file again.

Tips:

If you are working on your own "library" and aren't quite done yet, there's a temporary way to load these
functons from a file on disk. Consider this "developer mode" because you can edit the file with a text
editor and still use it in scripts and the Lua console during testing.

Place the file in the [CMANO Game Folder]/Lua directory (* see note) and you will be able to load it in
the Lua console or the "Load Lua Helpers" Action like this:

ScenEdit_RunScript ("cmano_helpers.lua") -- or whatever the filename is

Once your code is finalized, just copy/paste the whole contents of your lua file into the "Load Lua Helpers"
Action (replacing the above line) so you don't have to worry about bundling an external file.

* Warning: in Build 998.9 and probably before, if you are using the Steam version of the game launched
from Steam, or you've launched it from autorun.exe, then Lua scripts run from ScenEdit_RunScript() must
go in  the [CMANO Game Folder]/GameMenu_CMANO/Lua directory instead.

--------------------------------------------------------------------------------------------------------------------------- ]]--



--------------------------------------------------------------------------------------------------------------------------------
-- Table Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Count the number of items in a table regardless of table type.
-- For indexed arrays you can just use the # operator like #myarray but this doesn't work for
-- associative arrays (the ones with keys).
function GetTableCount(tab)
    local count = 0
    for k,v in ipairs(tab) do
        count = count + 1
    end
    return count
end


-- Takes an array of tables like {{a=1, b=2}, {a=1, b=2}, ...etc...} and lets you apply a function to every
-- table item.  For example, to update all units with the same value.
-- Example usage:
--      -- Update all reference points in the table 'rpoints' to set locked = true.
--         ApplyToTableItems(rpoints, function(item) item.locked = true end)

function ApplyToTableItems(tab, func)
    for i, v in ipairs(tab) do
        func(v)
    end
end



--------------------------------------------------------------------------------------------------------------------------------
-- Random/Math Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Improved random reseed
-- by NimrodX
-- Always call this in every single script chunk (editor window) before you use math.random().
-- You can then call math.random() many times in that script and it will be fast but the PRNG should also
-- be reasonably good because it was seeded with some "real" randomness.
-- Must be called in every single script that uses math.random()!
-- Not approved for use in cryptographic or other security uses.
--
function ImprovedRandomseed(quality)
    if quality == nil then quality=10 end
    -- os.time() removes dependency on how long the software has been running currently
    -- os.clock() provides miliseconds, unlike os.time()
    -- we "chain" this with previous math.random() output to retain any accumulated entropy
    -- and "stir" a little by repeating more than once, though not much because the execution time
    -- probably doesn't vary much between calls and spending too much time will be a waste unless we want
    -- to spend several seconds doing this.
    math.randomseed(os.time() + math.random(90071992547)) -- preserve some previous entropy if there was any
    for i = 1, quality do
        -- Retain some previous PRNG state while adding a little jitter entropy, but not much.
        -- Jitter entropy comes from thread preemption, interrupt handing, and stuff like that in the OS that is
        -- somewhat random. This means you might not get much if any on a powerful and calm system.
        -- If we had a higher precision clock with ns instead of just ms then that would be more helpful.
        math.randomseed(((os.clock() * 1000) % 1000) + math.random(900719925470000))
    end
end


-- Get Random Numbers
-- Written Kevin Kinscherf 12-29-2016
-- Rewritten and min/max functionality added by NimrodX
-- This is for generating a single decent quality random number.
-- Return value is an integer.
-- Warning! This is SLOW so should not be used to generate lots of random numbers in a loop!
-- If you need more than one or two "really good" random numbers in a given script, just call ImprovedRandomseed()
-- at the top of every single script that uses math.random()
-- Usage examples:
--        local r = ImprovedRandom()        -- r is now 0 or 1
--        local j = ImprovedRandom(5)       -- j is now 0 <= r <= 5
--        local k = ImprovedRandom(1,3)     -- k is now 1 <= r <= 3
--
function ImprovedRandom(...)
    local args = { ... }
    local min = 0
    local max = 1
    if #args == 1 then
        max = args[1];
    elseif #args == 2 then
        min, max = args[1], args[2]
    elseif #args > 2 then
        error("too many arguments to improved_random()")
    end
    ImprovedRandomseed(1000)
    return math.random(min, max)
end



--------------------------------------------------------------------------------------------------------------------------------
-- Reference Point Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Create a circle of reference points around a location on the world map.
-- Use Ctrl-X while pointing at map to get a location and paste it inside { } to make the location argument.
-- Written by Baloogan
-- Modified draw_circle by Yautay
-- Modified by Wayne Stiles (2016-11-14)
-- Improved by NimrodX
-- Usage example:
--      -- Draw a 30nmi radius circle for side "US" around Atlanta with 12 points labeled ATL-1 through ATL-12 like a clock.
--      DrawRPCircle("US", {latitude='33.761939187143', longitude='-84.3825536773889'}, 30, 12, "ATL-", 1)
--      -- Same thing but start numbering the points at 10 so you get ATL-10 through ATL-21.
--      DrawRPCircle("US", {latitude='33.761939187143', longitude='-84.3825536773889'}, 30, 12, "ATL-", 10)
--      -- A 'firstindex' of nil or not specified means don't number label the reference points. So they all have the same name.
--      DrawRPCircle("US", {latitude='33.761939187143', longitude='-84.3825536773889'}, 30, 12, "ATL", nil)
--      -- Last three arguments are optional and have default values if not specified.
--      DrawRPCircle("US", {latitude='33.761939187143', longitude='-84.3825536773889'}, 30)
--      -- DrawRPCircle() returns a list of ReferencePoint wrappers so you can modify them if desired (lock, unhighlight, etc).
--      -- Example:
--      local rps = DrawRPCircle("US", {latitude='33.761939187143', longitude='-84.3825536773889'}, 5, 12, "ATL-")
--      ApplyToTableItems(rps, function(rp) rp.locked=true; rp.highlighted=false; end)
--
function DrawRPCircle(sidename, location, radius, numpts, nameprefix, firstindex)
    if numpts == nil then numpts = 12 end
    local nonumber = false
    if firstindex == nil then
        nonumber = true
        firstindex = 0
    end
    if nameprefix == nil then
        if nonumber then
            nameprefix =  "C"
        else
            nameprefix = ""
        end
    end
    local clat, clon =  location.latitude, location.longitude
    local r = radius / 60
    local lastindex = firstindex + numpts - 1
    local th, rlat, rlon, rp
    local rpname = nameprefix
    local area = {}
    for i = firstindex, lastindex do
        th = 2 * math.pi * i / numpts
        rlat = clat + r * math.cos(th)
        rlon = clon + r * math.sin(th) / math.cos(math.rad(clat))
        if nonumber == false then
            rpname = nameprefix .. i
        end
        rp = ScenEdit_AddReferencePoint({
            side = sidename,
            lat = rlat,
            lon = rlon,
            name = rpname,
            highlighted = true})
            table.insert(area, rp)
    end
end


-- Draw circle around unit, specifying a unit by name rather than location coordinates
-- Usage example:
--      -- Draw 5nmi radius circle around "US" unit named "My Ship" with 12 points labeled B-1 to B-12
--      local rpoints = DrawRPCircleAroundUnit("US", "My Ship", 5, 12, "B-", 1)
--      -- Set all to locked, unhighlighted, and rotating relative to myShip
--      ApplyToTableItems(rpoints, function(rp) rp.locked=true; rp.highlighted=false; rp.relativeto=myShip; rp.bearingtype=1; end)
--
function DrawRPCircleAroundUnit(sidename, unit_name, radius, numpts, nameprefix, firstindex)
    local unit = ScenEdit_GetUnit({side=sidename, name=unit_name})
    return DrawRPCircle(sidename, {latitude=unit.latitude, longitude=unit.longitude}, radius, numpts, nameprefix, firstindex)
end


-- Get all reference points for a side with a given prefix and a given range of numbers after the prefix.
-- Example usage:
--      -- Get all reference points for "US" named B-1 through B-12.
--      local rpoints = GetReferencePointsByPrefix("US", "B-", 1, 12)
--      -- Unlock and highlight all of them.
--      ApplyToTableItems(rpoints, function(rp) rp.locked=false; rp.highlighted=true; end)
function GetReferencePointsByPrefix(sidename, prefix, firstindex, lastindex)
    local area = {}
    for i = firstindex, lastindex do
        table.insert(area, prefix .. i)
    end
    return ScenEdit_GetReferencePoints({ side=sidename, area=area})
end


-- Delete all reference points for a side with a given prefix and a given range of numbers after the prefix.
-- Example usage:
--         -- Delete all reference points for "US" named B-1 through B-12.
--        local success = DeleteReferencePointsByPrefix("US", "B-", 1, 12)
function DeleteReferencePointsByPrefix(sidename, prefix, firstindex, lastindex)
    local area = {}
    for i = firstindex, lastindex do
        table.insert(area, prefix .. i)
    end
    return ScenEdit_DeleteReferencePoint({ side=sidename, area=area})
end



--------------------------------------------------------------------------------------------------------------------------------
-- Generic Count Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Create a counter in global scenario storage where it can get saved.
function SetCount(countKey,countValue)
    ScenEdit_SetKeyValue(countKey,tostring(countValue))
end


-- Get counter value from global scenario storage and create with value 0 it if it doesn't exist.
function GetCount(countKey)
    local currentCount = tonumber(ScenEdit_GetKeyValue(countKey))
    if currentCount == nil then
        currentCount = 0
        ScenEdit_SetKeyValue(countKey,tostring(currentCount))
    end
    return currentCount
end


-- Increment a counter stored in global scenario storage with the given key.
-- Create it and set it to 1 if it doesn't already exist.
function IncrementCount(countKey)
    local currentCount = tonumber(ScenEdit_GetKeyValue(countKey))
    if currentCount == nil then
        currentCount = 1
    else
        currentCount = currentCount + 1
    end
    ScenEdit_SetKeyValue(countKey,tostring(currentCount))
    return currentCount
end



--------------------------------------------------------------------------------------------------------------------------------
-- Mission Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Assign Units to Mission by name prefix
-- Written by Kevin Kinscherf (2016-12-9)
-- "Functionized" by NimrodX
-- Usage example:
--      AssignUnitsToMission("Redcock #", 1, 6, "Strike") -- Assigns "Redcock #1" through "Redcock #6" to mission named "Strike"
--      AssignUnitsToMission("Redcock #", 7, 10, "Decoy") -- Assigns "Redcock #7" through "Redcock #10" to mission named "Decoy"
--
function AssignUnitsToMission(nameprefix, startcount, endcount, missioname)
    for i = startcount, endcount do
        ScenEdit_AssignUnitToMission(nameprefix .. i,  missionname)
    end
end


-- Set mission to start n minutes from current game time "now"
function SetMissionStartTime(sideName,missionName,minutesFromNow)
    local currentTime = ScenEdit_CurrentTime()
    local currentMission = ScenEdit_GetMission(sideName,missionName)
    currentTime = currentTime + 5 * 60 * 60 + minutesFromNow * 60
    currentMission.isactive = false
    currentMission.starttime = os.date("%m/%d/%Y %I:%M %p", currentTime)
end


-- Set a mission active by side,name.
function ActivateMission(sideName,missionName)
    local currentMission = ScenEdit_GetMission(sideName,missionName)
    currentMission.isactive = true
end


-- Set mission inactive by side,name.
function DeactivateMission(sideName,missionName)
    local currentMission = ScenEdit_GetMission(sideName,missionName)
    currentMission.isactive = false
end



--------------------------------------------------------------------------------------------------------------------------------
-- Group Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


function SetGroupSide(currentSide,groupName,newSide)
    -- Getting Values
    local airportUnit= ScenEdit_GetUnit({side=currentSide, unitname=groupName})

    -- Check
    if airportUnit then
        local groupUnit = airportUnit.group
        -- Loop Through Contacts And Switch Side
        for k, v in pairs(groupUnit.unitlist) do
            ScenEdit_SetUnitSide({side=currentSide, name=v, newside=newSide})
        end
    end
end


function RemoveGroupAndGetUnits(currentSide,groupName)
    -- Getting Values
    local currentUnit = ScenEdit_GetUnit({side=currentSide, unitname=groupName})
    local unitList = currentUnit.group.unitlist
    currentUnit.course = {}
    ScenEdit_DeleteUnit({side=currentSide, unitname=groupName})
    -- Return
    return unitList
end


function SetGroupPosition(currentSide,groupName,latitude,longitude)
    -- Getting Values
    local currentUnit = ScenEdit_GetUnit({side=currentSide, unitname=groupName})

    -- Check
    if currentUnit then
        local groupUnit = currentUnit.group
        -- Loop Through Contacts And Switch Side
        for k, v in pairs(groupUnit.unitlist) do
            ScenEdit_SetUnit({side=currentSide, name=v, lat = latitude, lon = longitude})
        end
    end
end



--------------------------------------------------------------------------------------------------------------------------------
-- Event Helper Functions
--------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------
-- Contact Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Set the event's current contact posture to hostile, etc.
-- This will only work in an action script for an event that has a UnitC() (detected contact) value!
-- For example an event triggered by a "Unit is Detected" trigger.
-- Valid posture values are single letter strings as follows:
--        'F' = Friendly
--        'H' = Hostile
--        'N' = Neutral
--        'U' = Unfriendly
-- These are the same codes used by ScenEdit_SetSidePosture()
--
function SetContactPosture(posture)
    if posture == nil then posture = 'H' end
    local contact = ScenEdit_UnitC()
    if contact == nil then
        error([[SetContactPosture(): no UnitC() exists. Are you using this with a "Unit is Detected" trigger?]])
    end
    -- No matter what it is, now it will be considered...
    contact.posture = posture
end




--------------------------------------------------------------------------------------------------------------------------------
-- Posture Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- See Contact Helper Functions above for posture codes
function SetSidePostures(sideOne,sideTwo,postureOne,postureTwo)
    ScenEdit_SetSidePosture(sideOne, sideTwo, postureOne)
    ScenEdit_SetSidePosture(sideTwo, sideOne, postureTwo)
end


-- Set two sides to have the same postures between each other
-- See Contact Helper Functions above for posture codes
function SetMutualSidePosture(sideOne, sideTwo, posture)
    ScenEdit_SetSidePosture(sideOne, sideTwo, posture)
    ScenEdit_SetSidePosture(sideTwo, sideOne, posture)
end


-- Even easier convenience functions with more obvious sementics
function SetSidesFriendly(sideOne, sideTwo)
    ScenEdit_SetSidePosture(sideOne, sideTwo, 'F')
end

function SetSidesHostile(sideOne, sideTwo)
    ScenEdit_SetSidePosture(sideOne, sideTwo, 'H')
end

function SetSidesNeutral(sideOne, sideTwo)
    ScenEdit_SetSidePosture(sideOne, sideTwo, 'N')
end

function SetSidesUnfriendly(sideOne, sideTwo)
    ScenEdit_SetSidePosture(sideOne, sideTwo, 'U')
end


--------------------------------------------------------------------------------------------------------------------------------
-- Score Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


function AddScoreToSide(side,score,reason)
    local currentScore = ScenEdit_GetScore(side)
    currentScore = currentScore + score
    ScenEdit_SetScore(side,currentScore,reason)
end


function RewardPointsOnceAndMessage(rewardKey,rewardPoints,rewardReason,side,message)
    -- Get Reward Count
    local rewardCount = IncrementCount(rewardKey)
    local currentScore = ScenEdit_GetScore(side)

    -- Reward Count
    if rewardCount == 1 then
        currentScore  = currentScore + rewardPoints
        ScenEdit_SetScore (side, currentScore, rewardReason)
        ScenEdit_SpecialMessage(side,message)
    end
end



--------------------------------------------------------------------------------------------------------------------------------
-- Fuel Helper Functions
--------------------------------------------------------------------------------------------------------------------------------


-- Refuel Unit if Low
-- This will change the onboard fuel for an aircraft depending upon some condition.
-- If the fuel level goes below 'minfuel' it will be reset to the maximum allowed for the aircraft.
-- To check this level constantly there must be a trigger condition such as one based on time that checks
-- every 15 minutes. So call this in the action for that repeatable event.
-- Example usage:
--      RefuelUnitIfLow("Civilian", "Jumbo Jet", 22000) -- refuel to max if fuel gets below 22,000
-- Defaults to airplane fuel but a different fuel type can be set as the 4th argument.
-- You could also just copy this and rewrite it to handle any other conditions you need.
--
function RefuelUnitIfLow(side, name, minfuel, fueltype)
    if fueltype == nil then fueltype = 2001 end
    local u = ScenEdit_GetUnit({side=side, name=name})
    local newfuel = u.fuel
    if newfuel[fueltype].current < minfuel then
        newfuel[fueltype].current = newfuel[fueltype].max
        u.fuel = newfuel
    end
end

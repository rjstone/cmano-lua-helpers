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

# cmano-lua-helpers for Command: Modern Air/Naval Operations
Convenience and utility functions for creating scenarios and their Lua scripts in the game
[Command: Modern Air/Naval Operations](http://www.warfaresims.com/?page_id=1101)
by Matrix/Slitherine/WarfareSims. This long name is abbreviated as "CMANO" by players.

There are two main files in this repo:

* **Helper** functions (`cmano_helpers.lua`) - These are intended to be added to the scenario and defined when the scenario
loads. These fuctions are actually used in scenario Action and Condition Lua scripts used in Events.
* **Builder** functions (`cmano_builders.lua`, not available yet) - These are *NOT intended to be included* as code in a scenario but
rather executed manually from the Lua Console as macros to aid in scenario creation. They are useful for automating parts of
scenario creation while editing but not intended to be executed inside scenario Actions.

More details below.

# Helper Functions: `cmano_helpers.lua`

These are convenience functions written by various people (sometimes even me) to aid with writing the little Lua scripts
used in CMANO.

For full info on how to include the functions in your scenario see the comments at the top of the file, but here's the
short version:

* Create a new scenario or load an existing one that you want to add the library to.

* Load up the Lua console and execute this code snippet in it ONCE to create the initialization event:

```lua
local event = ScenEdit_SetEvent('Lua Helper Init', {mode='add', IsRepeatable=true})
ScenEdit_SetTrigger({mode='add',type='ScenLoaded',name='Scenario Loaded'})
ScenEdit_SetEventTrigger(event.guid, {mode='add', name='Scenario Loaded'})
ScenEdit_SetAction({mode='add',type='LuaScript',name='Load Lua Helpers',
    ScriptText='-- REPLACE THIS with the contents of cmano_helpers.lua'})
ScenEdit_SetEventAction(event.guid, {mode='add', name='Load Lua Helpers'})
```

* As you might guess, doing the above can also be done manually in the GUI but executing the code above in the Lua
  console will save you time and lots of clicking.

* Now, open up **Editor->Event Editor->Actions**, edit the "Load Lua Helpers" action, copy the whole
	contents of the file `cmano_helpers.lua` to the clipboard (load in notepad.exe or a better text editor, Ctrl-A, Ctrl-C),
  and paste it into the "Load Lua Helpers" script editor (click text area, right-click Select All, Ctrl-V).
		
* Save the scenario, then reload the scenario from the file.
		
* After you do this, every Lua script that runs in the scenario should be able to use every function
  in this file.

You only need to do this process once for every new scenario. If you need to update the library of functions
for your scenario, just edit the "Load Lua Helpers" Action and copy/paste the new file, make one-off edits,
or whatever you need to do. Then save the scenario and load it from the file again.

# Builder Functions: `cmano_builders.lua`

Not added or documented yet. Stay tuned etc....

# Contributing to the Library

Anyone can contribute if they have something useful to add! Let me know and I'll add you to the repository so you can just push
your own updates. **But, this is on one condition!** You must adhere to the following very simple and short code style
"guide" so we can try to keep this as clean looking as possible.

### Indenting

* Indents are 4 spaces (per level)
* Use "soft" tabs (indents of four space characters) not "hard" tabs (tab characters). In other words, convert all tab
characters to spaces when you save. Various text editors will help you manage your tabs as spaces like this.

### Spacing

* Two lines between function definitions
* Three lines between "sections"

### Coments

* Just try to maintain the look of the section dividers etc.

### Function Names

* Capitalize every word.
* No spaces between words.
* This naming style is called Camel Case with initial capital letters.
* Example: `ThisIsMyCoolFunction()`

### Variable and Argument Names 

* Always start with a lower case letter, but other than that camel case etc doesn't matter.
* Use descriptive argument names especially like `DrawRPCircle(sidename, location, radius, numpts, nameprefix, firstindex)`
  and NOT `DrawRPCircle(s, x, a2, r1, b, c)` since nobody will understand that.
* Do not start variable names or argument names with a capital letter!

# cmano-lua-helpers for Command: Modern Air/Naval Operations
Convenience and utility functions for creating scenarios and their Lua scripts in the game
[Command: Modern Air/Naval Operations](http://www.warfaresims.com/?page_id=1101)
by Matrix/Slitherine/WarfareSims. This long name is abbreviated as "CMANO" by players.

There are two main files in this repo:

* **Helper** functions (`cmano_helpers.lua`) - These are intended to be added to
  the scenario and defined when the scenario loads. These fuctions are actually
  used in scenario Action and Condition Lua scripts used in Events.

* **Builder** functions (`cmano_builders.lua`) - Warning! Very incomplete right now. These are *NOT intended to be included* as code in a scenario but rather executed manually from the Lua Console as macros to aid in scenario creation. They are useful for automating parts of scenario creation while editing but not intended to be executed inside scenario Actions.

More details below.

# Helper Functions: `cmano_helpers.lua`

These are convenience functions written by various people (sometimes even me) to
aid with writing the little Lua scripts used in CMANO.

For the most current full info on how to include the functions in your scenario
see the comments at the top of the file, but here's the "short" version:

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

* As you might guess, doing the above can also be done manually in the GUI but
executing the code above in the Lua console will save you time and lots of
clicking.

* Now, open up **Editor->Event Editor->Actions**, edit the "Load Lua Helpers"
action, copy the whole contents of the file `cmano_helpers.lua` to the clipboard
(load in notepad.exe or a better text editor, Ctrl-A, Ctrl-C), and paste it into
the "Load Lua Helpers" script editor (click text area, right-click Select All,
Ctrl-V).

* Save the scenario, then reload the scenario from the file.

* After you do this, every Lua script that runs in the scenario should be able
to use every function in this file.

You only need to do this process once for every new scenario. If you need to
update the library of functions for your scenario, just use **Editor->Event
Editor->Actions** again and edit the "Load Lua Helpers" Action, copy/paste the
new file, make one-off edits, or whatever you need to do. Then save the scenario
and load it from the file again to reload the code.

# Builder Functions: `cmano_builders.lua`

Place the `cmano_builders.lua` file in the `[CMANO Game Folder]/Lua` directory (*
see note) and you will be able to load it in the **Lua console** like this:

```lua
ScenEdit_RunScript("cmano_builders.lua")
```

Once you do that, you can invoke the "macro" functions by just typing the name
of the function you want with the arguments you want into the Lua console and
clicking Run. Read through the file to find out what functions are available,
and see the usage examples.

This may seem like too much trouble to some people, and it is for just adding a
few units (which can easily be done manually). But for adding or modifying large
numbers of units such as an entire Carrier Battle Group or an airbase with all
of its magazines, runways, taxiways, hangars, facilities, and magazines, this
can save you 100s of clicks on GUI controls and lots of time.

Anyone using this should definitely see **blh42's [.INST file
library](http://www.matrixgames.com/forums/tm.asp?m=3547843)** ([google
drive](https://drive.google.com/drive/folders/0B2ZVdo4JnhUBVUMtUV9pS2xrcTg))
with lots of easy imports of large numbers of units.

It's possible that in some scenarios you *might* want to use some of the builder
functions to add and remove units during gameplay. If so, just add the
`cmano_builders.lua` to a Scenario Loaded event action as described above for
Helper Functions. My recommendation would be that you create a separate Action
called "Load Lua Builders" so you can update the code separately rather than
trying to paste multiple files into the same Lua Script Action.

* Warning: in Build 998.9 and probably before, if you are using the Steam
version of the game launched from Steam, or you've launched it from
autorun.exe, then Lua scripts run from `ScenEdit_RunScript()` must go in  the
`[CMANO Game Folder]/GameMenu_CMANO/Lua` directory instead because that's
where the "current directory" used by Lua is when launched in this way.

# Contributing to the Library

Anyone can contribute if they have something useful to add! Let me know and I'll add you to the repository so you can just push
your own updates. **But, this is on one condition!** You must adhere to the following very simple and short code style
"guide" so we can try to keep this as clean looking as possible.

**If you don't want to deal with github...** Just go to https://gist.github.com/ then paste your code snippet there and message
me somehow (discord, etc), or use some other way of sneding me your code
and I'll add it (possibly after editing it to match style).

### Indenting

* Indents are 4 spaces (per level)
* Use "soft" tabs (indents of four space characters) not "hard" tabs (tab
characters). In other words, convert all tab characters to spaces when you save.
Various text editors will help you manage your tabs as spaces like this.

### Line Spacing

* **Single optional blank line spacing** inside functions anywhere you feel like visually separating parts of the
  function. For example before and after loops. This is totally optional and up to you, just avoid using two or more blank
  lines in a row to space things out. In other words, avoid double spacing inside functions.
* **Double blank line spacing** between function definitions, unless the functions are a very closely related group like
  `SetSidesFriendly()`, `SetSidesHostile()`, etc. In this cases just space them apart with a single blank line.
* **Triple blank line spacing** between "sections"

### Coments

* Just try to maintain the look and the spacing of the section dividers etc.

### Function Names

* Start with capital letter.
* Capitalize every word.
* No spaces between words.
* This naming style is called Camel Case with initial capital letters and mimics the convention of the CMANO Lua API, but without the
  `ScenEdit_` prefix, etc.
* Example: `ThisIsMyCoolFunction()`

### Variable and Argument Names

* **Always start with a lower case letter**, but other than that camel case etc doesn't matter.
* Use descriptive argument names especially like `DrawRPCircle(sidename, location, radius, numpts, nameprefix, firstindex)`
  and NOT `DrawRPCircle(s, x, a2, r1, b, c)` since nobody will understand that without digging into the code.
* Do not start variable names or argument names with a capital letter! In short, just always start with a lower case letter.
* Good examples: `foobar`, `foo_bar`, or `fooBar`
* Bad examples: `FooBar`, `Foobar`

# Other Resources

* **blh42's [.INST file library](http://www.matrixgames.com/forums/tm.asp?m=3547843)** ([google drive](https://drive.google.com/drive/folders/0B2ZVdo4JnhUBVUMtUV9pS2xrcTg))
* [Command Lua Documentation](https://commandlua.github.io/) -  https://commandlua.github.io/
* [Official CMANO Lua Forum](http://www.matrixgames.com/forums/tt.asp?forumid=1681)
* [Official CMANO Forum](http://www.matrixgames.com/forums/tt.asp?forumid=1154)
* [Unofficial CMANO Discord Server](https://discord.gg/dyQDesj)
* [CMANO at WarefareSims](http://www.warfaresims.com/?page_id=1101)
* [CMANO Page on Steam](https://store.steampowered.com/app/321410)

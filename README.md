# GcViewerV3

A lightweight but powerful GC inspection tool for Roblox exploit environments.

GcViewerV3 helps you scan, filter, and inspect functions tracked by the garbage collector (`getgc()`), so you can find remotes, inspect closures, and reverse-engineer behaviour more quickly.

## Utilities

This project includes a set of utility modules inside the `Utility` folder to support advanced GC inspection and manipulation:

- `FindFunction.lua` — Core module to find and filter Lua functions in the GC by constants, upvalues, protos, scripts, and more.  
- `Build.lua` — Utility for building or compiling certain data structures or filtered results (custom logic depends on your implementation).  
- `Data2Code@Amity.lua` — Converts serialized data back into Lua code (serialization/deserialization helper).  
- `Idm.lua` — Module managing metadata for tracked functions or scripts.  
- `serialize_table.lua` — Helper to serialize Lua tables into string representations (for dumping or saving data).

These utilities work together to enable powerful GC exploration and manipulation, and can be used standalone or integrated into your tooling.

You can require them individually as needed:

```lua
local FindFunc = require(path.to.Utility.FindFunction)
local SerializeTable = require(path.to.Utility.serialize_table)
```
and so on

Feel free to explore their code to understand their functionality or adapt them for your specific use case.
<br/>

## What it does
- Find functions by constants, upvalues, protos, script, return values or debug info.
- Dump a function's internals (constants, upvalues, protos, script ref and debug info).
- Efficiently scan Lua closures in memory with custom filters.
- Designed to be dropped into your tooling or used as a base for a GUI viewer.
<br/>

## Requirements
An executor that exposes:
- getgc, islclosure, isexecutorclosure (or remove those checks).
- debug.getconstants, debug.getupvalues, debug.getprotos, debug.info (or equivalents).
- Optional: getscriptfromfunction, getscriptfromthread for script linking.
<br/>

## Installation
- Save the Utility folder in your project and require modules, or load remotely:
```lua
local FindFunc = require(path.to.Utility.FindFunction)
-- or
local FindFunc = loadstring(game:HttpGet("https://your.raw.githubusercontent.com/.../FindFunction.lua"))()
```
<br/>

## Examples
- Find functions that reference "FireServer" as a constant:
```lua
local results = FindFunc:FindFunctionsByConstants(3, { [1] = "FireServer" })
for i, fn in ipairs(results) do
    print("Match", i, fn)
end
```
- Match functions by upvalues (second upvalue is a table):
```lua
local funcs = FindFunc:FindFunctionsByUpvalues(2, { [2] = "typeof:table" })
```
- Find functions originating from a specific script (requires getscriptfromfunction):
```lua
local scriptRef = workspace.MyScript
local owned = FindFunc:FindFunctionsByScript(scriptRef)
```
- Dump closure info for a function:
```lua
local fn = someFuncFromGetgc
local info = FindFunc:GetClosureInfo(fn)
print(info.debug and info.debug.name, info.script)
```
- Custom search predicate:
```lua
local matches = FindFunc:GetAllMatching(function(f)
    local consts = debug.getconstants(f) or {}
    for _, v in ipairs(consts) do
        if v == "Kick" then return true end
    end
    return false
end)
```
<br/>

## API overview
- FindFunc:FindFunctionsByConstants(count, expected) — find functions by constant values (supports "typeof:TYPE" entries).
- FindFunc:FindFunctionsByUpvalues(count, expected) — match upvalues by type or value.
- FindFunc:FindFunctionsByProtoCount(count) — find functions with a specific number of protos.
- FindFunc:FindFunctionsByScript(script) — functions created by a script object (executor-dependent).
- FindFunc:FindFunctionsByReturn(value) — calls the function safely (pcall) and checks its return.
- FindFunc:FindFunctionsByNameChunkLine(str) — match by function name or source chunk.
- FindFunc:GetAllMatching(fn) — generic filter across GC closures.
- FindFunc:GetClosureInfo(fn) — returns constants, upvalues, protos, script ref and debug info.
- FindFunc:DumpFunctionInfo(fn) — prints a compact summary for quick inspection.
- FindFunc.getscriptfromfunction(fn) / FindFunc.getscriptfromthread(thread) — executor-safe helpers.
<br/>

## Tips
- Use "typeof:TYPE" when matching types (for example "typeof:table").
- Combine checks (constants + upvalues + proto count) for more reliable matching.
- Be cautious when calling unknown functions; FindFunc:CheckReturns uses pcall but functions may still have side effects.
- Remove or adapt islclosure / isexecutorclosure checks if your executor lacks them.
<br/>

## Troubleshooting
- If nothing is returned, make sure your executor exposes getgc and the required debug functions.
- If script lookup is unsupported, that executor does not provide script mapping. This is normal for some environments.
- DumpFunctionInfo may show n/a for some fields if the executor's debug API is limited.
<br/>

## Ideas for future work
- Simple GUI to browse matched functions (Rayfield / SynapseLib / Orion).
- RemoteFinder utility to auto-detect remotes by return type or constants.
- Snapshotting and diffing GC state between runs.
- Auto-tagging and grouping of similar closures.
<br/>

## Contributing
- Feel free to open PRs. Keep additions optional and compatible across executors. Small, focused changes (new matchers, UI adapters) are easiest to support.

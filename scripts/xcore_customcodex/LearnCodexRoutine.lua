-- Written by Xan the Dragon // Eti the Spirit [RBX 18406183]
-- Code to learn codex entries.
require("/scripts/xcore_customcodex/LoggingOverride.lua") -- Very nice script!
local HasLoggingOverride = false
local print, warn, error, assertwarn, assert, tostring;

local REMINDER_DONT_REPORT_INSIGNIFICANT_ERRORS = "\n\t >>>> THIS ERROR MESSAGE IS FOR LOGGING PURPOSES ONLY. THIS IS ***NOT*** A FATAL ERROR.\n\t >>>> If you wish to report it anyway, go to Xan the Dragon#1760 as this is his script.\n"

local function GetLoggingOverridesIfNecessary()
	if HasLoggingOverride then return end
	print, warn, new_error, assertwarn, assert, tostring = CreateLoggingOverride("[Codex Learning Routine]")
	
	-- Hacky, but it ensures every error message has this without the need to paste it after every message.
	error = function (...)
		new_error(..., REMINDER_DONT_REPORT_INSIGNIFICANT_ERRORS)
	end
	
	HasLoggingOverride = true
end

-- Does the table contain the learned codex data?
local function TableAlreadyContains(tbl, entry)
	for _, value in pairs(tbl) do
		if value[1] == entry[1] and value[2] == entry[2] then
			return true
		end
	end
	return false
end

-- Attempt to learn this codex. 
-- Returns 0 if the call was successful and we learned the codex entry, 1 if the call was successful but we already knew the entry, and 2 if something errored out.
function LearnCodex(itemName)
	GetLoggingOverridesIfNecessary()
	
	-- First sanity check: Item name OK?
	if type(itemName) ~= "string" then
		error("Something called LearnCodex with an item name that wasn't a string. Aborting the learning procedure. (itemName is nil? " .. tostring(itemName == nil):upper() .. ").")
		return 2
	end
	if not itemName == nil or #itemName <= 6 then
		error("Something called LearnCodex with an item name that was either nil or had a length less than or equal to 6 (and by extension, it would be impossible for its name to end in -codex and still have content beforehand as a result). Aborting the learning procedure. The item name is: " .. tostring(itemName))
		return 2
	end
	if itemName:sub(-6) ~= "-codex" then
		error("Player attempted to learn codex, but held item name did not end in -codex! Aborting the learning procedure. The item name is: " .. tostring(itemName))
		return 2
	end
	------------------------------------
	
	-- Second sanity check: Item exists?
	local data = root.itemConfig(itemName) -- Kind of counterintuitive but oh well.
	if data == nil or data.directory == nil then
		error("Player attempted to learn a codex from the item [" .. tostring(itemName) .. "], but root.itemConfig() returned nil data on this item! Aborting the learning procedure.")
		return 2
	end
	
	-- Update item name to strip it of -codex since we no longer want that suffix.
	local itemName = itemName:sub(1, -7)
	
	local foundCodexFile = pcall(root.assetJson, data.directory .. itemName .. ".codex")
	if not foundCodexFile then
		error("An item's ID ended in -codex, but it was not located as a codex in the game data files -- this item is violating naming conventions! Aborting the learning procedure. (Attempted to locate the file [" .. data.directory .. itemName .. ".codex], which doesn't exist.")
		return 2
	end
	------------------------------------
	
	-- This is for sanity checking. The interface itself will actually remove null codex entries from player data persistence.
	local codexCache = {tostring(itemName), tostring(data.directory)}
	
	-- Get player's known codex entries.
	local existingKnownEntries = player.getProperty("xcodex.knownCodexEntries") or {}
	
	-- If our internal cache here says we don't know it then we need to learn it.
	if not TableAlreadyContains(existingKnownEntries, codexCache) then
		table.insert(existingKnownEntries, codexCache)
		player.setProperty("xcodex.knownCodexEntries", existingKnownEntries)
		if sb then sb.logInfo("Player has learned codex " .. table.concat(codexCache, ", ") .. ".") end
		return 0
	else
		if sb then sb.logInfo("Player attempted to learn codex " .. table.concat(codexCache, ", ") .. " but they already know it, so we don't need to learn it again.") end
		return 1
	end
end
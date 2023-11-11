--[[
 * ReaScript Name: List of Instruments and Effects
 * Author: Michal MaXyM Bartak
 * Licence: GPL v3
 * REAPER: 7.0
 * Extensions: None
 * Version: 1.0
--]]



local function IsInstrument(track, fx_id)
-- RETURNS TRUE IF FX at fx_id is an instrument

  if track == nil then return end
  local ok, rv = reaper.TrackFX_GetNamedConfigParm(track, fx_id, 'fx_type')
  return ok and rv:find('.*i$') and true or false
end

local function PadColumn(content, len)
  local s
  s = content
  s = s .. string.rep(" ", len-string.len(s))

  return s
end

function spairs(t, order)
    -- sort array function
    -- found on page: https://stackoverflow.com/a/15706820

    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


local function PrintTableMarkup(table)
  local msg = ""
  local maxnamewidth = 0
  local quantitywidth = 10

  for instrument, quantity in pairs(table) do
      maxnamewidth = math.max(maxnamewidth, string.len(instrument))
  end

  msg = msg .. "|" .. PadColumn("Plugin Name", maxnamewidth)
  msg = msg .. "|" .. PadColumn("Quantity", quantitywidth) .. "|\n"
  msg = msg .. "|" .. PadColumn( string.rep("-", maxnamewidth), maxnamewidth)
  msg = msg .. "|" .. PadColumn( string.rep("-", quantitywidth), quantitywidth) .. "|\n"

  for instrument, quantity in spairs(table) do

      msg = msg .. "|" .. PadColumn(instrument, maxnamewidth)
      msg = msg .. "|" .. PadColumn(quantity, quantitywidth) .. "|\n"
  end

  return msg
end

local function PrintTable(table)
  local msg = ""

  for instrument, quantity in pairs(table) do
      msg = msg .. instrument .. " - Quantity: " .. quantity .. "\n"
  end

  return msg
end


-- Get the active project
local project = reaper.EnumProjects(-1, "")
-- Initialize tables to store instrument and effect names and their quantities
instrumentList = {}
effectList     = {}
offlineList    = {}
monitorinList  = {}
MONITORINGIDX  = 0x1000000 -- needed to distinguish monitoring plugins chain


local function AssignToCategory(track, fxIndex)

    -- Get FX name
    local _, fxName = reaper.TrackFX_GetFXName(track, fxIndex, "")

    -- Get the enabled state of the plugin
    local isEnabled = reaper.TrackFX_GetEnabled(track, fxIndex)

    -- Get the offline state of the plugin
    local isOffline = reaper.TrackFX_GetOffline(track, fxIndex)

    -- If the plugin is enabled, check if it's an instrument or effect
    if isEnabled and not isOffline then

        if fxIndex >= MONITORINGIDX then
            monitorinList[fxName] = (monitorinList[fxName] or 0) + 1
        elseif  IsInstrument(track, fxIndex) then
            instrumentList[fxName] = (instrumentList[fxName] or 0) + 1
        else
            effectList[fxName] = (effectList[fxName] or 0) + 1
        end
    else
       offlineList[fxName] = (offlineList[fxName] or 0) + 1
    end

end


-- Iterate through all tracks in the project
for i = 0, reaper.CountTracks(project) - 1 do
    local track = reaper.GetTrack(project, i)

    -- Iterate through all FX on the track
    for fxIndex = 0, reaper.TrackFX_GetCount(track) - 1 do
         AssignToCategory(track, fxIndex)
    end
end


-- Get master track plugins
local numMasterFX = reaper.TrackFX_GetCount(reaper.GetMasterTrack())

 -- Iterate through all FX on master track
for fxIndex = 0, numMasterFX - 1 do
    AssignToCategory(reaper.GetMasterTrack(), fxIndex)
end

-- Get monitoring FXs
local numinputFX = reaper.TrackFX_GetRecCount(reaper.GetMasterTrack())
for fxIndex = 0, numinputFX - 1 do
    AssignToCategory(reaper.GetMasterTrack(), fxIndex+MONITORINGIDX)
end


-- Display the lists
local msg = "**Instruments:**\n"
msg = msg .. PrintTableMarkup(instrumentList)

msg = msg .. "\n**Effects:**\n"
msg = msg .. PrintTableMarkup(effectList)

msg = msg .. "\n**Monitoring plugins:**\n"
msg = msg .. PrintTableMarkup(monitorinList)

msg = msg .. "\n**Offline/inactive plugins:**\n"
msg = msg .. PrintTableMarkup(offlineList)

reaper.ShowConsoleMsg(msg)

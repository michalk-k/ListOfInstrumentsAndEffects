
-- Reaper Plugin: List of plugins found in current project with number of their instances, grouped into Intruments, Effects and offline/muted ones
-- Version: 1.0
-- Author: Michal Bartak


-- RETURNS TRUE IF FX at fx_id is an instrument
local function IsInstrument(track, fx_id)
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

  for instrument, quantity in pairs(table) do

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
local instrumentList = {}
local effectList = {}
local offlineList = {}


-- Iterate through all tracks in the project
for i = 0, reaper.CountTracks(project) - 1 do
    local track = reaper.GetTrack(project, i)

    -- Iterate through all FX on the track
    for fxIndex = 0, reaper.TrackFX_GetCount(track) - 1 do

        -- Get FX name
        local _, fxName = reaper.TrackFX_GetFXName(track, fxIndex, "")

        -- Get the enabled state of the plugin
        local isEnabled = reaper.TrackFX_GetEnabled(track, fxIndex)

        -- Get the offline state of the plugin
        local isOffline = reaper.TrackFX_GetOffline(track, fxIndex)

        -- If the plugin is enabled, check if it's an instrument or effect
        if isEnabled and not isOffline then

            if  IsInstrument(track, fxIndex) then
                instrumentList[fxName] = (instrumentList[fxName] or 0) + 1
            else
                effectList[fxName] = (effectList[fxName] or 0) + 1
            end
        else
           offlineList[fxName] = (offlineList[fxName] or 0) + 1
        end
    end
end


-- Display the lists
local msg = "**Instruments:**\n"
msg = msg .. PrintTableMarkup(instrumentList)

msg = msg .. "\n**Effects:**\n"
msg = msg .. PrintTableMarkup(effectList)

msg = msg .. "\n**Offline/inactive plugins:**\n"
msg = msg .. PrintTableMarkup(offlineList)


reaper.ShowConsoleMsg(msg)

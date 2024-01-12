-- @description List of Instruments and Effects
-- @author Michal MaXyM Bartak
-- @version 2.0
-- @licence GPL v3
-- @about
--   # About
--   This is a Lua script, which lists all Reaper plugins used in an active project, grouping them into categories.
--
--   It's written and tested in Reaper7.x. Might work in previous versions too.
-- @changelog
--   v2.0 Added GUI with export to various formats
--   v1.0 Initial version


-- PART - Script generated by Lokasenna's GUI Builder
local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end

loadfile(lib_path .. "Core.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - TextEditor.lua")()
GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Frame.lua")()
GUI.req("Classes/Class - Label.lua")()
GUI.req("Classes/Class - Options.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end


GUI.name = "List of Instruments and Effects"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 512, 480
GUI.anchor, GUI.corner = "mouse", "C"

-- End of Lokasenna's GUI Builder PART



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
  local found = false

  for instrument, quantity in pairs(table) do
      maxnamewidth = math.max(maxnamewidth, string.len(instrument))
      found = true
  end

  if not found then
    return "N/A\n"
  end

  msg = msg .. "|" .. PadColumn("Plugin Name", maxnamewidth)
  msg = msg .. "|" .. PadColumn("Instances", quantitywidth) .. "|\n"
  msg = msg .. "|" .. PadColumn( string.rep("-", maxnamewidth), maxnamewidth)
  msg = msg .. "|" .. PadColumn( string.rep("-", quantitywidth -1) .. ":", quantitywidth) .. "|\n"

  for instrument, quantity in spairs(table, function(t,a,b) return a < b end) do

      msg = msg .. "|" .. PadColumn(instrument, maxnamewidth)
      msg = msg .. "|" .. PadColumn(quantity, quantitywidth) .. "|\n"
  end

  return msg
end

local function PrintTable(intable)
  local msg = ""
  local found = false

  for instrument, quantity in spairs(intable, function(t,a,b) return a < b end) do
      msg = msg .. PadColumn(quantity .. "x ", 5) .. instrument .. "\n"
      found = true
  end

  if found then
    return msg
  else
    return "N/A\n"
  end
end


-- Get the active project
local project = reaper.EnumProjects(-1, "")
-- Initialize tables to store instrument and effect names and their quantities
MONITORINGIDX  = 0x1000000 -- needed to distinguish monitoring plugins chain

local function initArrays()
  instrumentList = {}
  effectList     = {}
  offlineList    = {}
  monitorinList  = {}
end

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

local function GenerateData()

  initArrays()
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

end

local function GetDataMarkdown()
  GenerateData();
  -- Display the lists
  local msg = "**Instruments:**\n"
  msg = msg .. PrintTableMarkup(instrumentList)

  msg = msg .. "\n**Effects:**\n"
  msg = msg .. PrintTableMarkup(effectList)

  msg = msg .. "\n**Monitoring plugins:**\n"
  msg = msg .. PrintTableMarkup(monitorinList)

  msg = msg .. "\n**Offline/inactive plugins:**\n"
  msg = msg .. PrintTableMarkup(offlineList)

  return msg
end

local function GetDataPlain()
  GenerateData();
  -- Display the lists
  local msg = "Instruments:\n"
  msg = msg .. PrintTable(instrumentList)

  msg = msg .. "\nEffects:\n"
  msg = msg .. PrintTable(effectList)

  msg = msg .. "\nMonitoring plugins:\n"
  msg = msg .. PrintTable(monitorinList)

  msg = msg .. "\nOffline/inactive plugins:\n"
  msg = msg .. PrintTable(offlineList)

  return msg
end

local function GetDataBBplain()
  GenerateData();
  -- Display the lists
  local msg = "[b]Instruments:[/b]\n"
  msg = msg .. PrintTable(instrumentList)

  msg = msg .. "\n[b]Effects:[/b]\n"
  msg = msg .. PrintTable(effectList)

  msg = msg .. "\n[b]Monitoring plugins:[/b]\n"
  msg = msg .. PrintTable(monitorinList)

  msg = msg .. "\n[b]Offline/inactive plugins:[/b]\n"
  msg = msg .. PrintTable(offlineList)

  return msg
end

local function GetDataBBcode()
  GenerateData();
  -- Display the lists
  local msg = "[CODE]\n"
  msg = msg .. "Instruments:\n"
  msg = msg .. PrintTable(instrumentList)

  msg = msg .. "\nEffects:\n"
  msg = msg .. PrintTable(effectList)

  msg = msg .. "\nMonitoring plugins:\n"
  msg = msg .. PrintTable(monitorinList)

  msg = msg .. "\nOffline/inactive plugins:\n"
  msg = msg .. PrintTable(offlineList)
  msg = msg .. "[/CODE]"

  return msg
end


function get_report(opt, forceout)
  local txt
  local arr


  if opt == "plaintext" then
      txt = GetDataPlain()
  elseif opt == "markdown" then
      txt = GetDataMarkdown()
  elseif opt == "bbplain" then
      txt = GetDataBBplain()
  elseif opt == "bbcode" then
      txt = GetDataBBcode()
  end

  reaper.CF_SetClipboard(txt);

  if GUI.Val("Checklist1") or forceout then
    GUI.Val("TextEditor1", txt);
  else
    GUI.Val("TextEditor1", GetDataPlain());
  end
end

function get_report_plaintext()
  get_report("plaintext")
end

function get_report_markdown()
  get_report("markdown")
end

function get_report_bbplain()
  get_report("bbplain")
end

function get_report_bbcode()
  get_report("bbcode")
end


GUI.New("Label1", "Label", {
    z = 11,
    x = 34,
    y = 48,
    caption = "Copy to Clipboard",
    font = 4,
    color = "txt",
    bg = "wnd_bg",
    shadow = false
})

GUI.New("Frame1", "Frame", {
    z = 12,
    x = 24,
    y = 55,
    w = 460,
    h = 53,
    shadow = false,
    fill = false,
    color = "elm_frame",
    bg = "wnd_bg",
    round = 4,
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 4,
    font = 4,
    col_txt = ""
})

GUI.New("Button1", "Button", {
    z = 11,
    x = 34,
    y = 70,
    w = 70,
    h = 24,
    caption = "Plain Text",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = get_report_plaintext
})

GUI.New("Button2", "Button", {
    z = 11,
    x = 125,
    y = 70,
    w = 70,
    h = 24,
    caption = "Markdown",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = get_report_markdown
    })

GUI.New("Button3", "Button", {
    z = 11,
    x = 214,
    y = 70,
    w = 70,
    h = 24,
    caption = "BB Plain",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = get_report_bbplain

    })

GUI.New("Button4", "Button", {
    z = 11,
    x = 303,
    y = 70,
    w = 70,
    h = 24,
    caption = "BB Code",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = get_report_bbcode
    })

GUI.New("TextEditor1", "TextEditor", {
    z = 11,
    x = 24,
    y = 128,
    w = 460,
    h = 320,
    caption = "",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    col_fill = "elm_fill",
    cap_bg = "wnd_bg",
    bg = "elm_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})

GUI.New("Checklist1", "Checklist", {
    z = 11,
    x = 380,
    y = 68,
    w = 96,
    h = 36,
    caption = "",
    optarray = {"Debug"},
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    shadow = true,
    swap = true,
    opt_size = 20,
    frame = false
})

GUI.Init()
GUI.Main()
get_report("plaintext", true)
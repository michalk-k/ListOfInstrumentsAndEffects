# ListOfInstrumentsAndEffects
This script lists all used Reaper plugins, grouping them into categories.
It generates output in a `markdown` compatible format.

The motivation comes from KVR OSC (KVRaudio One Synth Challange) competition, which requires providing such statistics (though, it doesn't require `markdown` format)

## Output example:
An example of the raw output:
```
**Instruments:**
|Plugin Name                |Quantity  |
|---------------------------|----------|
|VST3i: Wavetable (SocaLabs)|31        |

**Effects:**
|Plugin Name                                   |Quantity  |
|----------------------------------------------|----------|
|VST3: ValhallaSupermassive (Valhalla DSP, LLC)|11        |
|JS: ReEQ - Parametric Graphic Equalizer       |18        |
|VST: ReaComp (Cockos)                         |5         |
|VST: ReaLimit (Cockos)                        |3         |
|VST: OrilRiver (Denis Tihanov)                |1         |
|VST: ReaDelay (Cockos)                        |2         |

**Offline/inactive plugins:**
|Plugin Name                      |Quantity  |
|---------------------------------|----------|
|VST3i: Stochas (Surge Synth Team)|4         |
|VST: ReaLimit (Cockos)           |1         |
|VST: ReaComp (Cockos)            |1         |
```
The output is rendered by markdown parsers into this:

**Instruments:**
|Plugin Name                |Quantity  |
|---------------------------|----------|
|VST3i: Wavetable (SocaLabs)|31        |

**Effects:**
|Plugin Name                                   |Quantity  |
|----------------------------------------------|----------|
|VST3: ValhallaSupermassive (Valhalla DSP, LLC)|11        |
|JS: ReEQ - Parametric Graphic Equalizer       |18        |
|VST: ReaComp (Cockos)                         |5         |
|VST: ReaLimit (Cockos)                        |3         |
|VST: OrilRiver (Denis Tihanov)                |1         |
|VST: ReaDelay (Cockos)                        |2         |

**Offline/inactive plugins:**
|Plugin Name                      |Quantity  |
|---------------------------------|----------|
|VST3i: Stochas (Surge Synth Team)|4         |
|VST: ReaLimit (Cockos)           |1         |
|VST: ReaComp (Cockos)            |1         |

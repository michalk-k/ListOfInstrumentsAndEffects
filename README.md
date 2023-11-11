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
|JS: ReEQ - Parametric Graphic Equalizer       |19        |
|VST3: ValhallaSupermassive (Valhalla DSP, LLC)|11        |
|VST: FerricTDSmkII (Variety Of Sound)         |1         |
|VST: OrilRiver (Denis Tihanov)                |1         |
|VST: ReaComp (Cockos)                         |5         |
|VST: ReaDelay (Cockos)                        |2         |
|VST: ReaLimit (Cockos)                        |4         |

**Monitoring plugins:**
|Plugin Name                                    |Quantity  |
|-----------------------------------------------|----------|
|JS: Goniometer                                 |1         |
|JS: Oscilloscope Meter (Cockos)                |1         |
|JS: ReSpectrum                                 |1         |
|VST3: Youlean Loudness Meter 2 (Youlean) (10ch)|1         |
|VST: SPAN (Voxengo) (8ch)                      |1         |

**Offline/inactive plugins:**
|Plugin Name                      |Quantity  |
|---------------------------------|----------|
|VST3i: Stochas (Surge Synth Team)|4         |
|VST: ReaComp (Cockos)            |1         |
|VST: ReaLimit (Cockos)           |1         |
```
The output is rendered by markdown parsers into this:

**Instruments:**
|Plugin Name                |Quantity  |
|---------------------------|----------|
|VST3i: Wavetable (SocaLabs)|31        |

**Effects:**
|Plugin Name                                   |Quantity  |
|----------------------------------------------|----------|
|JS: ReEQ - Parametric Graphic Equalizer       |19        |
|VST3: ValhallaSupermassive (Valhalla DSP, LLC)|11        |
|VST: FerricTDSmkII (Variety Of Sound)         |1         |
|VST: OrilRiver (Denis Tihanov)                |1         |
|VST: ReaComp (Cockos)                         |5         |
|VST: ReaDelay (Cockos)                        |2         |
|VST: ReaLimit (Cockos)                        |4         |

**Monitoring plugins:**
|Plugin Name                                    |Quantity  |
|-----------------------------------------------|----------|
|JS: Goniometer                                 |1         |
|JS: Oscilloscope Meter (Cockos)                |1         |
|JS: ReSpectrum                                 |1         |
|VST3: Youlean Loudness Meter 2 (Youlean) (10ch)|1         |
|VST: SPAN (Voxengo) (8ch)                      |1         |

**Offline/inactive plugins:**
|Plugin Name                      |Quantity  |
|---------------------------------|----------|
|VST3i: Stochas (Surge Synth Team)|4         |
|VST: ReaComp (Cockos)            |1         |
|VST: ReaLimit (Cockos)           |1         |

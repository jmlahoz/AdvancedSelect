# Move cursor to Xpct of selection
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2022-07-01

# LICENSE
# (C) 2022 José María Lahoz-Bengoechea
# This file is part of the plugin_AdvancedSelect.
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation
# either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# For more details, you can find the GNU General Public License here:
# http://www.gnu.org/licenses/gpl-3.0.en.html
# This file runs on Praat, a software developed by Paul Boersma
# and David Weenink at University of Amsterdam.

# This script moves the cursor to a point within a selection that is located at the X% of the total duration.
# This is an Editor script.

include auxiliary.praat

form Move cursor to X% of selection...
real pct 
endform

if pct < 0 or pct > 100
exit pct must be a number between 0 and 100
endif

ini = Get start of selection
end = Get end of selection

if ini = end
@getinfo: 0
if data_type$ = "Sound"
exit You must select a portion of the sound
endif
endeditor
@selobj: 0, 1
int = Get interval at time... 1 ini
ini = Get start time of interval... 1 int
end = Get end time of interval... 1 int
@restorews
editor
endif

dur = end - ini

t = ini + dur*pct/100

Move cursor to... t
endeditor

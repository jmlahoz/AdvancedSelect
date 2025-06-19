# Select interval by number
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2025-06-19

# LICENSE
# (C) 2025 José María Lahoz-Bengoechea
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

# This script selects an interval of the tier and number specified by the user.
# This is an Editor script.

include auxiliary.praat

@getinfo: 0

endeditor

@selobj: 0, 1

ntier = Get number of tiers
for itier from 1 to ntier
tier'itier'$ = Get tier name... 'itier'
tier'itier'$ = replace$(tier'itier'$,"/","",0)
endfor

call findtierbyname ortho 0 1
orthoTID = findtierbyname.return

if orthoTID > 0
initial_selection = orthoTID
else
initial_selection = 1
endif

beginPause: "Select interval by number..."
optionMenu: "Tier", initial_selection
for itier from 1 to ntier
tiername$ = tier'itier'$
option: "'tiername$'"
endfor
natural: "Interval number", ""
endPause: "OK",1

call findtierbyname 'tier$' 1 1
tierID = findtierbyname.return

ini = Get start time of interval... 'tierID' 'interval_number'
end = Get end time of interval... 'tierID' 'interval_number'
@restorews

editor
Select... ini end
Zoom to selection
Zoom out


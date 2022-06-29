# Save selected sound and TextGrid
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2021-10-07

# LICENSE
# (C) 2021 José María Lahoz-Bengoechea
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

# This script will save the selected portion of a sound together with the corresponding portion of the TextGrid, all at once.
# This is an Editor script.

include auxiliary.praat

# Info to switch between objects window and editor window
@getinfo: 0
endeditor


# Ask user folder and filename
name$ = chooseWriteFile$: "Save selected sound and TextGrid (no extension required)", ""
if name$ = ""
exit You must choose a directory and a file name to save the Sound and TextGrid pair.
else
if right$(name$,4) = ".wav"
name$ = name$ - ".wav"
elsif right$(name$,9) = ".TextGrid"
name$ = name$ - ".TextGrid"
endif
endif

# Back to editor window
editor

socopy = Extract selected sound (time from 0)
tgcopy = Extract selected TextGrid (time from 0)

endeditor

select socopy
Save as WAV file... 'name$'.wav
Remove

select tgcopy
Save as text file... 'name$'.TextGrid
Remove

# Restore original workspace
@restorews

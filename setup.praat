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

if praatVersion >= 6215
select_menu$ = "Time"
else
select_menu$ = "Select"
endif

Add action command... Sound 0 "" 0 "" 0 "Play list one by one" "Play" 0 Play list one by one.praat
Add menu command... "SoundEditor" "'select_menu$'" "Move cursor to maximum" "Move cursor to..." 0 Move cursor to maximum.praat
Add menu command... "TextGridEditor" "'select_menu$'" "Move cursor to maximum" "Move cursor to..." 0 Move cursor to maximum.praat
Add menu command... "SoundEditor" "'select_menu$'" "Move cursor to minimum" "Move cursor to maximum" 0 Move cursor to minimum.praat
Add menu command... "TextGridEditor" "'select_menu$'" "Move cursor to minimum" "Move cursor to maximum" 0 Move cursor to minimum.praat
Add menu command... "SoundEditor" "'select_menu$'" "Move cursor to (min:sec)..." "" 0 Move cursor to (min-sec).praat
Add menu command... "TextGridEditor" "'select_menu$'" "Move cursor to (min:sec)..." "" 0 Move cursor to (min-sec).praat
Add menu command... "TextGridEditor" "'select_menu$'" "Move cursor to X% of selection..." "" 0 Move cursor to Xpct of selection.praat
Add menu command... "TextGridEditor" "'select_menu$'" "Select interval by number..." "" 0 Select interval by number.praat
Add menu command... "TextGridEditor" "File" "Save selected sound and TextGrid..." "Save selected sound as FLAC file..." 0 Save selected sound and TextGrid.praat

# Play list one by one
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

# This script allows to navigate (and play) a list of selected sound objects.
# The user can go back in the list, repeat a sound, or move forward.


pause Select items for playlist...
n = numberOfSelected ("Sound")
for j from 1 to n
sound'j' = selected("Sound",j)
endfor
for i from 1 to n
currentsound = sound'i'
clicked = 2
select 'currentsound'
repeat
Play
beginPause ("Pause")
clicked = endPause("Previous","Repeat","Next",3)
until clicked != 2
if clicked = 1
i = i-2
endif
endfor

# Auxiliary functions for Praat
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2022-07-01

# LICENSE
# (C) 2022 José María Lahoz-Bengoechea
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


# This file is a repository of functions that are invoked from other Praat scripts
# developed by José María Lahoz-Bengoechea.
# The procedure (or function) findtierbyname was originally written by Jean Philippe Goldman.


# Suggested citation:
# Lahoz-Bengoechea, José María (2022). Auxiliary functions for Praat (1.0) [Computer software].


##{ getws
# This gets an image of current workspace (namely, which objects are selected in the Praat objects list).
# It works in combination with restorews.
procedure getws
nobj = numberOfSelected()
for iobj from 1 to nobj
object'iobj' = selected(iobj)
endfor
endproc
##}


##{ restorews
# This restores the workspace previously stored by getws.
# It is useful for scripts that create auxiliary objects to achieve their goal and are later removed.
procedure restorews
nocheck select 'object1'
if nobj > 1
for iobj from 2 to nobj
object = object'iobj'
plus 'object'
endfor
endif
endproc
##}


##{ findtierbyname
# This gets the tier number for a tier of a specific name.
# You may force the exit if such tier does not exist by setting .v1 to value 1 (instead of 0).
# You may force the exit if such tier is not an interval tier by setting .v2 to value 1 (instead of 0).
procedure findtierbyname .name$ .v1 .v2
  .n = Get number of tiers
  .return = 0
  for .i to .n
    .tmp$ = Get tier name... '.i'
	.tmp$ = replace$(.tmp$,"/","",0)
    if .tmp$ == .name$
      .return = .i
    endif
  endfor
  if  (.return == 0) and (.v1 > 0)
    exit Tier ''.name$'' not found in TextGrid. Exiting...
  endif
  if  (.return > 0) and (.v2 > 0)
    .i = Is interval tier... '.return'
    if .i == 0
      exit Tier number '.return' named '.name$' is not an interval tier. Exiting...
    endif
  endif

endproc
##}


##{ parsex
# This sets a reasonable pitch floor and ceiling, as well as formant ceiling,
# depending on speaker's sex and voice register.
procedure parsex .sex .phon_mode
if .sex = 1
sex$ = "Male"
if .phon_mode = 1
phon_mode$ = "Modal"
pitch_floor = 75
pitch_ceiling = 300
formant_ceiling = 5000
elsif .phon_mode = 2
phon_mode$ = "Creak"
pitch_floor = 40
pitch_ceiling = 150
formant_ceiling = 5000
elsif .phon_mode = 3
phon_mode$ = "Falsetto"
pitch_floor = 100
pitch_ceiling = 600
formant_ceiling = 5500
endif

elsif .sex = 2
sex$ = "Female"
if .phon_mode = 1
phon_mode$ = "Modal"
pitch_floor = 100
pitch_ceiling = 400
formant_ceiling = 5500
elsif .phon_mode = 2
phon_mode$ = "Creaky"
pitch_floor = 50
pitch_ceiling = 200
formant_ceiling = 5000
elsif .phon_mode = 3
phon_mode$ = "Falsetto"
pitch_floor = 200
pitch_ceiling = 600
formant_ceiling = 6000
endif
endif

endproc
##}


##{ getinfo
# This runs from an editor script.
# It gets its data type (Sound / TextGrid) and name.
# It calls getws to get a copy of the workspace in the objects list.
# It assigns the TextGrid id number to the variable tg.
# It assigns the Sound id number to the variable so.
# If it runs from a TextGrid editor, there is no univocal method to find its corresponding Sound,
# so it is advised to set .makeSoundCopy to value 1 (instead of 0).
# In that case, socopy is the variable to be used to select that object.
procedure getinfo .makeSoundCopy
editorinfo$ = Editor info
data_type$ = extractLine$ (editorinfo$, "Data type: ")
data_name$ = extractLine$ (editorinfo$, "Data name: ")

endeditor
@getws
editor 'data_type$' 'data_name$'

if data_type$ = "Sound"
so = extractNumber (editorinfo$, "Editor name: ")
socopy = 0
if .makeSoundCopy = 1
.ini = Get start of selection
.end = Get end of selection
editor_start = extractNumber(editorinfo$,"Editor start: ")
editor_end = extractNumber(editorinfo$,"Editor end: ")
Select... 'editor_start' 'editor_end'
socopy = Extract selected sound (preserve times)
Select... '.ini' '.end'
endif
elsif data_type$ = "TextGrid"
tg = extractNumber (editorinfo$, "Editor name: ")
socopy = 0
if .makeSoundCopy = 1
.ini = Get start of selection
.end = Get end of selection
editor_start = extractNumber(editorinfo$,"Editor start: ")
editor_end = extractNumber(editorinfo$,"Editor end: ")
Select... 'editor_start' 'editor_end'
socopy = Extract selected sound (preserve times)
Select... '.ini' '.end'
elsif .makeSoundCopy = 0
endeditor
@checkunique
.nthisname = checkunique.return
select Sound 'data_name$'
if .nthisname = 1
so = selected("Sound")
elsif .nthisname > 1
pause There is no unique Sound object named 'data_name$'. Please select the right one.
so = selected("Sound")
endif
editor 'data_type$' 'data_name$'
endif
endif
endproc
##}


##{ selobj
# This works in combination with getinfo.
# You may specify a value of 0 or 1 for .selectSound and .selectTextGrid
# (eg. 1, 0 selects the Sound; 0, 1 selects the TextGrid; 1, 1 selects both).
procedure selobj .selectSound .selectTextGrid
if data_type$ = "Sound"
select so
elsif data_type$ = "TextGrid"
if .selectSound = 1
if socopy = 0
select so
else
select socopy
endif
if .selectTextGrid = 1
plus tg
endif
elsif .selectSound = 0 and .selectTextGrid = 1
select tg
endif

endif
endproc
##}


##{ getshow
# This gets which analyses are currently shown in an Editor window.
# It works in combination with restoreshow.
# It may be useful for scripts where you have to force the visibility of a specific analysis to do further operations
# but then you want to leave everything as is.
procedure getshow
editorinfo$ = Editor info
pitch_show = extractNumber (info$, "Pitch show: ")
intensity_show = extractNumber (info$, "Intensity show: ")
formant_show = extractNumber (info$, "Formant show: ")
pulses_show = extractNumber (info$, "Pulses show: ")
endproc
##}


##{ restoreshow
# This works in combination with getshow, and restores (in-)visibility of the different analyses in the Editor window.
procedure restoreshow
Show analyses... 1 'pitch_show' 'intensity_show' 'formant_show' 'pulses_show' 10
endproc
##}


##{ checkunique
# This returns the number of Sound objects whose name matches the data name of an Editor script.
# It works in combination with getinfo.
procedure checkunique
select all
.nso = numberOfSelected("Sound")
.return = 0
for .iso from 1 to .nso
.iname$ = selected$("Sound",.iso)
if .iname$ = data_name$
.return = .return + 1
endif
endfor
endproc
##}


##{ toaltfn
# This requires the selection of a Sound object.
# It creates a Formant object with standard parameters,
# plus an additional (alternative) Formant object with parameters that favor a neater distinction between formants
# and may be used in case unlikely formant values are obtained with the standard.
procedure toaltfn
.so = selected("Sound")
noprogress To Formant (burg)... 0 5 5500 0.015 50 ; 4th argument standard is 0.025 but 0.015 yields better temporal resolution
fn = selected("Formant")
select .so
noprogress To Formant (burg)... 0 4 3800 0.015 50
altfn = selected("Formant")
endproc
##}


##{ resetfnflags
# This works in combination with fn_check.
# It establishes two variables (default value = 0),
# which will be updated to 1 in case an alternative formant calculation is needed for a formant
# (then, the alternative is also used for all subsequent formants).
procedure resetfnflags
altfnflag = 0 ; Value set to 1 by fn_check when alternative formant analysis is required (if necessary to calculate one formant, it is applied to all formants)
nasalflag = 0 ; Value set to 1 by fn_check when there is a nasal formant around 1000 Hz, so calculated F3 really is oral F2, calculated F4 is oral F3, etc.
endproc
##}


##{ fn_check
# This evaluates the plausibility of formant values for a specific formant (F1-F3)
# and possibly also for a specific segment identity.
# In the case of unlikely values, it recalculates formants with alternative parameters
# (this works in combination with toaltfn and resetfnflags).
# In a nasal context, it skips a nasal formant that possibly pervades a vowel,
# so that only true (oral) vowel formants are returned.
procedure fn_check .fvalue .n .t .segmentid$ .nasalctxt$ .f2$
# .fvalue is the previously calculated formant value, which you want to check
# .n is the formant number
# .t is the timepoint
# .segmentid$ is the label of the segment, eg. "i" or "\jc\TV"
# .nasalctxt$ specifies {"yes" or "1" vs. "no" or "0"} this is a vowel next to a nasal consonant
# (if omitted, defaults to "no")
# .f2$ (F2 value in Hertz) is needed if you want to check the F3 value (otherwise, it can be omitted)

if .f2$ = ""
.f2 = 0
else
.f2 = number(.f2$)
endif

if .nasalctxt$ = "" or .nasalctxt$ = "0" or .nasalctxt$ = "no"
.nasalctxt = 0
elsif .nasalctxt$ = "1" or .nasalctxt$ = "yes"
.nasalctxt = 1
else
.nasalctxt = 0
.f2 = number(.nasalctxt$)
endif

if .segmentid$ = ""
.segmentid$ = "0"
endif

if .n = 1
if .fvalue > 1000
select altfn
altfnflag = 1
.resultfn = Get value at time... .n .t hertz Linear
.resultbn = Get bandwidth at time... .n .t hertz Linear
select fn
else
.resultfn = .fvalue
.resultbn = Get bandwidth at time... .n .t hertz Linear
endif
endif

if .n = 2
if altfnflag = 1 or (.fvalue > 2500 and .segmentid$!="i" and .segmentid$!="\jc\Tv" and .segmentid$!="ʝ̞")
select altfn
altfnflag = 1
.resultfn = Get value at time... .n .t hertz Linear
.resultbn = Get bandwidth at time... .n .t hertz Linear
select fn
elsif .fvalue < 1000 and .segmentid$!="o" and .segmentid$!="u" and .segmentid$!="m" and .segmentid$!="\bf\Tv" and .segmentid$!="β̞"
select altfn
altfnflag = 1
.resultfn = Get value at time... .n .t hertz Linear
.resultbn = Get bandwidth at time... .n .t hertz Linear
if .resultfn < 1100 and index("aei",.segmentid$)!=0 and .nasalctxt = 1
nasalflag = 1
.resultfn = Get value at time... .n+1 .t hertz Linear
.resultbn = Get bandwidth at time... .n+1 .t hertz Linear
endif
select fn
else
.resultfn = .fvalue
.resultbn = Get bandwidth at time... .n .t hertz Linear
endif
endif

if .n = 3

if nasalflag = 1
select altfn
.resultfn = Get value at time... .n+1 .t hertz Linear
.resultbn = Get bandwidth at time... .n+1 .t hertz Linear
select fn
elsif altfnflag = 1 or (.fvalue > 3500 and .segmentid$!="i")
altfnflag = 1
select altfn
.resultfn = Get value at time... .n .t hertz Linear
.resultbn = Get bandwidth at time... .n .t hertz Linear
select fn
else
.resultfn = .fvalue
.resultbn = Get bandwidth at time... .n .t hertz Linear
endif

if .resultfn = undefined
select fn
if nasalflag = 1
.fnasal = Get value at time... .n-1 .t hertz Linear
if .fnasal < 1100
.f3 = Get value at time... .n+1 .t hertz Linear
.b3 = Get bandwidth at time... .n+1 .t hertz Linear
else
.f3 = Get value at time... .n .t hertz Linear
.b3 = Get bandwidth at time... .n .t hertz Linear
endif
else
.f3 = Get value at time... .n .t hertz Linear
.b3 = Get bandwidth at time... .n .t hertz Linear
endif

if .f3 > .f2
.resultfn = .f3
.resultbn = .b3
endif
endif

endif

endproc
##}


##{ get_number_of_indices
# This gets either the number of intervals or of points of a TextGrid tier, depending on the tier type.
procedure get_number_of_indices .tier .isint
if .isint = 0
.return = Get number of points... .tier
endif
if .isint = 1
.return = Get number of intervals... .tier
endif
endproc
##}


##{ get_time_of_index
# This gets either the start time of an interval or the time of a point in a TextGrid tier, depending on the tier type.
procedure get_time_of_index .tier .isint .id
if .isint = 0
.return = Get time of point... .tier .id
endif
if .isint = 1
.return = Get start time of interval... .tier .id
endif
endproc
##}


##{ get_current_index
# This gets either the interval at a certain time or the low point from that time, depending on the tier type.
# It differs from get_low_index in that, when time coincides with an interval boundary, this returns the higher interval.
procedure get_current_index .tier .isint .t
if .isint = 0
.return = 0
.return = Get low index from time... .tier .t
endif
if .isint = 1
.return = Get interval at time... .tier .t
endif
endproc
##}


##{ get_low_index
# This gets either the low interval at a certain time or the low point from that time, depending on the tier type.
# It differs from get_current_index in that, when time coincides with an interval boundary, this returns the lower interval.
procedure get_low_index .tier .isint .t
if .isint = 0
.return = 0
.return = Get low index from time... .tier .t
endif
if .isint = 1
.return = Get low interval at time... .tier .t
endif
endproc
##}


##{ get_high_index
# This gets either the high interval at a certain time or the high point from that time, depending on the tier type.
procedure get_high_index .tier .isint .t
if .isint = 0
.return = 0
.return = Get high index from time... .tier .t
endif
if .isint = 1
.return = Get high interval at time... .tier .t
endif
endproc
##}


##{ get_label_of_index
# This gets the label of either an interval or a point, depending on the tier type.
procedure get_label_of_index .tier .isint .id
if .isint = 0
.return$ = Get label of point... .tier .id
endif
if .isint = 1
.return$ = Get label of interval... .tier .id
endif
endproc
##}


##{ insert_index
# This inserts either an interval boundary or a point, depending on the tier type.
procedure insert_index .tier .isint .t
if .isint = 0
nocheck Insert point... .tier .t
endif
if .isint = 1
nocheck Insert boundary... .tier .t
endif
endproc
##}


##{ set_index_text
# This sets the text of either an interval or a point, depending on the tier type.
procedure set_index_text .tier .isint .id .lab$
if .isint = 0
nocheck Set point text... .tier .id '.lab$'
endif
if .isint = 1
nocheck Set interval text... .tier .id '.lab$'
endif
endproc
##}


##{ countCharacter
# This returns the total number of occurrences of a string within another string.
procedure countCharacter .ch$ .str$
.ch_length = length(.ch$)
.count = 0
for .i from 1 to length(.str$)-.ch_length+1
if mid$(.str$,.i,.ch_length) = .ch$
.count = .count + 1
endif
endfor
endproc
##}


##{ getadtart
# This returns the Amplitude Decay Time (ADT) and Amplitude Rise Time (ART),
# and their relative measures (proportional to segment duration).
# Quené, H. (1992). Durational cues for word segmentation in Dutch. Journal of Phonetics, 20, 331-350.
procedure getadtart .ini .end
.tmax = Get time of maximum... .ini .end Sinc70
.adt = .end - .tmax
.art = .tmax - .ini
.dur = .end - .ini
.radt = .adt / .dur
.rart = .art / .dur
endproc
##}


##{ spectralmoments
# This returns the spectral moments (CoG, SD, skewness, and kurtosis).
procedure spectralmoments .ini .end
@getws
.nobj = numberOfSelected()
.nso = numberOfSelected("Sound")
if .nso != 1 or .nobj > 1
exit You must select just one sound.
endif
.part = Extract part... .ini .end rectangular 1 no
noprogress To Spectrum... yes
.fft = selected("Spectrum")
.cog = Get centre of gravity... 2
.stdev = Get standard deviation... 2
.skewness = Get skewness... 2
.kurtosis = Get kurtosis... 2

select .part
plus .fft
Remove
@restorews
endproc
##}


##{ spectral_analysis
# This returns different measures of spectral slope (e.g. H1-H2, H2-H4, H4-H2K, H2K-H5K, H1-A1, and their corrected versions),
# as well as formant amplitudes (A1-A3),
# and spectral measures of nasality (involving P0 and P1).
procedure spectral_analysis .t .f0 .f1 .b1 .f2 .b2 .f3 .b3
select pulses
.npulses = Get number of points
.curpulse = Get low index... .t
.inipulse = .curpulse - 3
.endpulse = .curpulse + 4
if .inipulse > 0 and .endpulse <= .npulses
.ini = Get time from index... .inipulse
.end = Get time from index... .endpulse
else
.h1h2 = 0
.h2h4 = 0
.h4h2k = 0
.h2kh5k = 0
.h1a1 = 0
.h1h2c = 0
.h2h4c = 0
.h4h2kc = 0
.h2kh5kc = 0
.h1a1c = 0
.a1 = 0
.a2 = 0
.a3 = 0
.p0prom = 0
.p1prom = 0
.p0 = 0
.p1 = 1
.a1p0 = 0
.a1p0c = 0
.a1p1 = 0
.a1p1c = 0
.a3p0 = 0
goto missing_data
endif

select pitch
.local_min_pitch = Get minimum... .ini .end Hertz Parabolic
if .local_min_pitch = undefined
select pulses
.tmpperiod = 0
for .ipulse from .inipulse to .endpulse-1
select pulses
.tpt1 = Get time from index... .ipulse
.tpt2 = Get time from index... .ipulse+1
.durperiod = .tpt2 - .tpt1
if .durperiod > .tmpperiod
.tmpperiod = .durperiod
endif
endfor
.local_min_pitch = 1/.tmpperiod
endif

# Extract 7-cycle window to get corresponding spectrum (LTAS).
select so
noprogress Extract part... .ini .end Hamming 1 yes
.sound4ltas = selected("Sound")

noprogress To Spectrum... yes
.fft = selected("Spectrum")

noprogress To Ltas (1-to-1)
.ltas = selected("Ltas")

.fh1 = Get frequency of maximum... (1*.f0)-(.f0/2) (1*.f0)+(.f0/2) None
.fh2 = Get frequency of maximum... (2*.f0)-(.f0/2) (2*.f0)+(.f0/2) None
.fh3 = Get frequency of maximum... (3*.f0)-(.f0/2) (3*.f0)+(.f0/2) None
.fh4 = Get frequency of maximum... (4*.f0)-(.f0/2) (4*.f0)+(.f0/2) None
.fh2k = Get frequency of maximum... 2000-(.f0/2) 2000+(.f0/2) None
.fh5k = Get frequency of maximum... 5000-(.f0/2) 5000+(.f0/2) None

.h1 = Get value at frequency... .fh1 Nearest
.h2 = Get value at frequency... .fh2 Nearest
.h3 = Get value at frequency... .fh3 Nearest
.h4 = Get value at frequency... .fh4 Nearest
.h2k = Get value at frequency... .fh2k Nearest
.h5k = Get value at frequency... .fh5k Nearest

.ff1 = Get frequency of maximum... .f1-.f0 .f1+.f0 None
.ff2 = Get frequency of maximum... .f2-.f0 .f2+.f0 None
.ff3 = Get frequency of maximum... .f3-.f0 .f3+.f0 None

.a1 = Get value at frequency... .ff1 Nearest
.a2 = Get value at frequency... .ff2 Nearest
.a3 = Get value at frequency... .ff3 Nearest

# Calculate spectral measures of nasality.
# Carignan, C. (2021). A practical method of estimating the time-varying degree of vowel nasalization from acoustic features. The Journal of the Acoustical Society of America, 149(2), 911-922.
.p0 = max(.h1,.h2)
if .p0 = .h1
.fp0 = .fh1
elsif .p0 = .h2
if .fh2 > 350
.p0 = .h1
.fp0 = .fh1
else
.fp0 = .fh2
endif
endif

.fp1 = Get frequency of maximum... 850 1050 None
.p1 = Get value at frequency... .fp1 Nearest

# Chen, M. Y. (1997). Acoustic correlates of English and French nasalized vowels. The Journal of the Acoustical Society of America, 102(4), 2360-2370.
.coupl_p0f1 = ((((0.5 * .b1) ^ 2) + (.f1) ^ 2) / (((((0.5 * .b1) ^ 2) + ((.f1 - .fp0) ^ 2)) * (((0.5 * .b1) ^ 2) + ((.f1 + .fp0) ^ 2))) ^ 0.5))
.coupl_p0f2 = ((((0.5 * .b2) ^ 2) + (.f2) ^ 2) / (((((0.5 * .b2) ^ 2) + ((.f2 - .fp0) ^ 2)) * (((0.5 * .b2) ^ 2) + ((.f2 + .fp0) ^ 2))) ^ 0.5))
# Chen, M. Y. (1995). Acoustic parameters of nasalized vowels in hearing-impaired and normal-hearing speakers. The Journal of the Acoustical Society of America, 98(5), 2443-2453.
.coupl_p1f1 = ((((0.5 * .b1) ^ 2) + (.f1) ^ 2) / (((((0.5 * .b1) ^ 2) + ((.fp1 - .f1) ^ 2)) * (((0.5 * .b1) ^ 2) + ((.f1 + .fp1) ^ 2))) ^ 0.5))
.coupl_p1f2 = ((((0.5 * .b2) ^ 2) + (.f2) ^ 2) / (((((0.5 * .b2) ^ 2) + ((.fp1 - .f2) ^ 2)) * (((0.5 * .b2) ^ 2) + ((.f2 + .fp1) ^ 2))) ^ 0.5))

.p0c = .p0 - .coupl_p0f1 - .coupl_p0f2
.p1c = .p1 - .coupl_p1f1 - .coupl_p1f2

.a1p0 = .a1 - .p0
.a1p0c = .a1 - .p0c
.a1p1 = .a1 - .p1
.a1p1c = .a1 - .p1c
.a3p0 = .a3 - .p0

.hp0 = round(.fp0/.fh1)
.hp1 = round(.fp1/.fh1)

if .hp0 = 1
.p0prom = .h1 - .h2
elsif .hp0 = 2
.p0prom = .h2 - ((.h1 + .h3)/2)
endif

.hp1_prev = .hp1 - 1
.hp1_next = .hp1 + 1
.fhp1_prev = Get frequency of maximum... (.hp1_prev*.f0)-(.f0/2) (.hp1_prev*.f0)+(.f0/2) None
.fhp1_next = Get frequency of maximum... (.hp1_next*.f0)-(.f0/2) (.hp1_next*.f0)+(.f0/2) None
.h_prev = Get value at frequency... .fhp1_prev Nearest
.h_next = Get value at frequency... .fhp1_next Nearest
.p1prom = .p1 - ((.h_prev + .h_next)/2)


# Calculate corrected measures of harmonic amplitudes.
# Iseli, M., & Alwan, A. (2004). An improved correction formula for the estimation of harmonic magnitudes and its application to open quotient estimation. Proceedings of the IEEE International Conference on Acoustics, Speech, and Signal Processing.
for .i from 1 to 3
r'.i' = e^(-pi*.b'.i'/fs)
w'.i' = 2*pi*.f'.i'/fs
endfor

.wh1 = 2*pi*.f0/fs
.wh2 = 2*pi*2*.f0/fs
.wh4 = 2*pi*4*.f0/fs
.wh2k = 2*pi*.fh2k/fs
.wa1 = 2*pi*.ff1/fs

call correction .h1 .wh1
.h1c = correction.amplitude
call correction .h2 .wh2
.h2c = correction.amplitude
call correction .h4 .wh4
.h4c = correction.amplitude
call correction .h2k .wh2k
.h2kc = correction.amplitude
call correction .a1 .wa1
.a1c = correction.amplitude

# Calculate measures of spectral slope
# Gobl, C., & Ní Chasaide, A. (2010). Voice source variation and its communicative functions. In W. J. Hardcastle, J. Laver, & F. E. Gibbon (Eds.), The handbook of phonetic sciences (2nd ed., pp. 378–423). Oxford: Wiley-Blackwell.
# Kreiman, J., Gerratt, B. R., & Antoñanzas-Barroso, N. (2007). Measures of the glottal source spectrum. Journal of Speech, Language and Hearing Research, 50(3), 595–610.
# Kreiman, J., Gerratt, B. R., Garellek, M., Samlan, R., & Zhang, Z. (2014). Toward a unified theory of voice production and perception. Loquens, 1(1), e009.
.h1h2 = .h1 - .h2
.h2h4 = .h2 - .h4
.h4h2k = .h4 - .h2k
.h2kh5k = .h2k - .h5k
.h1a1 = .h1 - .a1
.h1h2c = .h1c - .h2c
.h2h4c = .h2c - .h4c
.h4h2kc = .h4c - .h2kc
.h2kh5kc = .h2kc - .h5k
.h1a1c = .h1c - .a1c

select .sound4ltas
plus .fft
plus .ltas
Remove
label missing_data
endproc
##}


##{ correction
# This is part of the algorithm to compensate for the vicinity of a formant when calculating harmonic amplitude.
# It works in combination with spectral_analysis.
# Iseli, M., & Alwan, A. (2004). An improved correction formula for the estimation of harmonic magnitudes and its application to open quotient estimation. Proceedings of the IEEE International Conference on Acoustics, Speech, and Signal Processing.
procedure correction .amplitude .w
for .i from 1 to 3
.amplitude = .amplitude - 10*log10((r'.i'^2+1-2*r'.i'*cos(w'.i'))^2/((r'.i'^2+1-2*r'.i'*cos(w'.i'+.w))*(r'.i'^2+1-2*r'.i'*cos(w'.i'-.w))))
endfor
endproc
##}


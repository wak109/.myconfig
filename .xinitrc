#!/bin/sh
#
# $Id: .xinitrc,v 1.1 2009/04/27 08:50:21 nrjryka Exp $
#
# vim: set notextmode:
#

fontpath_init ()
{
	local _fontpath_list="
		/usr/pkg/lib/X11/fonts/local			\
		/usr/pkg/lib/X11/fonts/intlfonts		\
		/usr/pkg/lib/X11/fonts/Mozilla			\
		"
	local _fontpath

	for _fontpath in $_fontpath_list; do
		if [ -d ${_fontpath} ]; then
			xset fp+ ${_fontpath}
		fi
	done

	xset fp rehash
}

font_finder ()
{
	local code=$1
	local size="\-\-$2\-"
	local fndry_list="${3:-\-}"
	local type=${4:-fixed\-medium\-r\-normal}
	local extra="${5:-\-}"
	local fndry
	local font

	for fndry in ${fndry_list}; do
		font=`xlsfonts \
			| grep ${code} \
			| grep ${size} \
			| grep ${fndry} \
			| grep ${type} \
			| grep ${extra} \
			| head -n 1`
		if [ ${#font} -ne 0 ]; then
			echo ${font}
			return 0
		fi
	done
}

preferable_font_size ()
{
	local dimension=`xdpyinfo | grep "dimensions" | awk '{ print $2 }'`

	if [ ${#dimension} -eq 0 ]; then
		echo -n 12
	elif [ "$dimension" = "600x480" ]; then
		echo -n 12
	elif [ "$dimension" = "800x600" ]; then
		echo -n 12
	elif [ "$dimension" = "1024x768" ]; then
		echo -n 12
	elif [ "$dimension" = "1024x480" ]; then
		echo -n 12
	elif [ "$dimension" = "1280x1024" ]; then
		echo -n 14
	elif [ "$dimension" = "1400x1050" ]; then
		echo -n 16
	elif [ "$dimension" = "1600x1200" ]; then
		echo -n 16
	elif [ "$dimension" = "1920x1440" ]; then
		echo -n 16
	else
		echo -n 12
	fi
}

preferable_terminal_row ()
{
	local size=$1
	local height=`xwininfo -root | grep Height | sed -e 's/[^0-9]*\([0-9]*\)/\1/g'`
	local margin=100

	expr \( ${height} - ${margin} \) / \( ${size} + 1 \)
}

japanese_fontset ()
{
	local size=$1

	local ascii=`xlsfonts | grep 'iso8859\-1' | grep 'fixed\-medium' | grep "\-\-$size" | head -n 1`
	local kana=`xlsfonts | grep 'jisx0201.1976\-0' | grep 'fixed\-medium' | grep "\-\-$size" | head -n 1`
	local kanji=`xlsfonts | grep 'jisx0208.1983\-0' | grep 'fixed\-medium' | grep "\-\-$size" | head -n 1`

	if [ ${#ascii} -gt 0 -a ${#kana} -gt 0 -a ${#kanji} -gt 0 ]; then
		echo "-*-fixed-medium-*-${size}-*"
	fi
}


twmrc ()
{
	local width=`xwininfo -root | grep Width | sed -e 's/[^0-9]*\([0-9]*\)/\1/g'`
	local height=`xwininfo -root | grep Height | sed -e 's/[^0-9]*\([0-9]*\)/\1/g'`
	local terminal
	local fontarg
	local args
	local lterm
	local rterm
	local icondir=`tmp_file`
	local _icondir=`echo $icondir | sed -e 's/\//\\\\\\//g' -e 's/\./\\\./g'`
	local row
	local color=$basic_color

	mkdir $icondir
	kill_xbm > $icondir/kill.xbm
	maximize_xbm > $icondir/maximize.xbm
	minimize_xbm > $icondir/minimize.xbm
	titlebar_xbm > $icondir/titlebar.xbm

	if check_command kterm; then
		terminal=kterm
		fontarg='-fl'
		args='-sb'
	else
		terminal=xterm
		fontarg='-fn'
		args='-sb'
	fi

	if [ $height -eq 480 ]; then
		row=35
	elif [ $height -eq 768 ]; then
		row=50
	elif [ $height -eq 864 ]; then
		row=67
	elif [ $height -eq 1050 ]; then
		row=60
	else
		row=25
	fi
		
	twmrc_template | sed 				\
		-e "s/\$row/${row}/g" 			\
		-e "s/\$terminal/${terminal}/g"		\
		-e "s/\$icondir/${_icondir}/g"		\
		> $HOME/.twmrc
}

xdefaults ()
{
	xdefaults_template
}

tmp_file ()
{
	local tmp_prefix="/tmp/.tmpfile"
	local i=0

	while [ -e "$tmp_prefix$i" ]; do
		i=`expr $i + 1`
	done

	echo "$tmp_prefix$i"
}

default_xinit ()
{
	local	sysname=`uname -s`

	xhost +
	xset s on
	xdefaults | xrdb -merge -
	if check_command uim-xim; then
		uim-xim &
		if check_command uim-toolbar-gtk; then
			uim-toolbar-gtk &
		fi
	elif check_command kinput2; then
		case ${sysname} in

		NetBSD)
			XFILESEARCHPATH=/usr/pkg/lib/X11/app-defaults/Kinput2; kinput2 -canna -xim &
			;;

		esac
	fi
}

twm_xinit ()
{
	twmrc
	xclock -geometry 180x24-0-0 -bg $basic_color -fg white -padding 3 -d -norender &
}

startxfce4_xinit ()
{
	TERMCMD=${default_terminal}; export TERMCMD
}

wmaker_xinit ()
{
	if check_command wmtime; then
		wmtime &
	fi
}

mlterm_xinit ()
{
	local size=`preferable_font_size`
	local dir=${HOME}/.mlterm
	local mainconf=${dir}/main

	if [ ! -d $dir ]; then
		mkdir $dir
	fi

	echo "fontsize = $size" > $mainconf
	echo "scrollbar_view_name = mozmodern" >> $mainconf
}

xterm_init ()
{
	local _size=$1
	local _ascii_font=`font_finder "iso8859\-1" ${_size} "misc sony adobe" "\-medium\-r\-normal"` 

	echo xterm -fn ${_ascii_font}
}

kterm_init ()
{
	local _size=$1
	local _ascii_font=`font_finder "iso8859\-1" ${_size} "misc sony"`
	local _kana_font=`font_finder "jisx0201.1976\-0" ${_size} "misc sony"`
	local _kanji_font=`font_finder "jisx0208.1983\-0" ${_size} "misc jis"`

	echo kterm -fn ${_ascii_font} -fr ${_kana_font} -fk ${_kanji_font}
}

rxvt_init ()
{
	local _size=$1
	local _ascii_font=`font_finder "iso8859\-1" ${_size} "misc sony"`
	local _kanji_font=`font_finder "jisx0208.1983\-0" ${_size} "misc jis"`

	echo rxvt -fn ${_ascii_font} -fm ${_kanji_font}
}

mlterm_init ()
{
	local _size=$1

	echo mlterm --sbview="mozmodern" -fsrange="${_size}-${_size}"
}

. ${HOME}/.shlib

###
### Terminal
###
fontpath_init

font_size=`preferable_font_size`
term_cmd=`preferable_command "mlterm rxvt kterm xterm"`

echo ${term_cmd}

default_terminal=`eval ${term_cmd:=xterm}_init ${font_size}`
default_row=`preferable_terminal_row ${font_size}`

terminal_12pt=`eval ${term_cmd:=xterm}_init 12`
terminal_14pt=`eval ${term_cmd:=xterm}_init 14`
terminal_16pt=`eval ${term_cmd:=xterm}_init 16`
terminal_24pt=`eval ${term_cmd:=xterm}_init 24`

########################################################################
###
### twm
###
########################################################################

###
### twm colors
###
basic_color=DarkBlue

###
### twm icons
###
kill_xbm()
{
	cat <<________xbm_icon________
#define dismiss_width 11
#define dismiss_height 11
static unsigned char dismiss_bits[] = {
   0x00, 0x00, 0x06, 0x03, 0x8e, 0x03, 0xdc, 0x01, 0xf8, 0x00, 0x70, 0x00,
   0xf8, 0x00, 0xdc, 0x01, 0x8e, 0x03, 0x06, 0x03, 0x00, 0x00};
________xbm_icon________
}

maximize_xbm()
{
	cat <<________xbm_icon________
#define maximize_width 11
#define maximize_height 11
static unsigned char maximize_bits[] = {
   0x00, 0x00, 0xfe, 0x03, 0x00, 0x02, 0xf8, 0x02, 0xf0, 0x02, 0xf0, 0x02,
   0xf8, 0x02, 0x9c, 0x02, 0x0e, 0x02, 0x06, 0x02, 0x00, 0x00};
________xbm_icon________
}

minimize_xbm()
{
	cat <<________xbm_icon________
#define minimize_width 11
#define minimize_height 11
static unsigned char minimize_bits[] = {
   0x00, 0x00, 0x02, 0x03, 0x82, 0x03, 0xca, 0x01, 0xfa, 0x00, 0x7a, 0x00,
   0x7a, 0x00, 0xfa, 0x00, 0x02, 0x00, 0xfe, 0x03, 0x00, 0x00};
________xbm_icon________
}

titlebar_xbm()
{
	cat <<________xbm_icon________
#define titlebar_width 16
#define titlebar_height 15
static unsigned char titlebar_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00,
   0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00,
   0xff, 0xff, 0x00, 0x00, 0x00, 0x00};
________xbm_icon________
}

########################################################################
###
### .twmrc
###
########################################################################
twmrc_template()
{
	cat <<________twmrc________
# automatically generated by .xinitrc
#
NoDefaults
NoGrabServer
RestartPreviousState
DecorateTransients
BorderWidth 1
ButtonIndent 1
TitleButtonBorderWidth 1
IconDirectory "$icondir"

TitleFont "-misc-*-bold-r-normal--14-*-*-*-*-*-*-*"
ResizeFont "-misc-*-bold-r-normal--14-*-*-*-*-*-*-*"
MenuFont "-misc-*-bold-r-normal--14-*-*-*-*-*-*-*"
IconFont "-misc-*-bold-r-normal--14-*-*-*-*-*-*-*"
IconManagerFont "-misc-*-bold-r-normal--14-*-*-*-*-*-*-*"

Pixmaps {
	TitleHighlight		"titlebar.xbm"
}

Color {
	DefaultBackground	"${basic_color}"
	DefaultForeground	"white"
	TitleBackground		"${basic_color}"
	TitleForeground		"white"
	MenuBackground		"white"
	MenuForeground		"${basic_color}"
	MenuTitleBackground	"${basic_color}"
	MenuTitleForeground	"white"
	MenuShadowColor		"${basic_color}"
	BorderColor		"${basic_color}"
	BorderTileForeground	"white"
	BorderTileBackground	"${basic_color}"
	IconBackground		"white"
	IconForeground		"${basic_color}"
	IconBorderColor		"${basic_color}"
	IconManagerBackground	"white"
	IconManagerForeground	"${basic_color}"
	IconManagerHighlight	"${basic_color}"
}

IconifyByUnmapping
ShowIconManager
IconManagerGeometry "1024x24+0-0" 16 

NoTitle
{
	"TWM Icon Manager"
	"XClock"
	"Kinput2"
	"XBatt"
	"MozillaImStatus"
}

IconManagerDontShow
{
	"TWM Icon Manager"
	"XClock"
	"Kinput2"
	"XBatt"
}

WindowRing
{
	"XTerm"
	"KTerm"
	"mlterm"
	"Emacs"
	"Mozilla-bin"
	"Firefox-bin"
	"Mozilla"
	"Opera"
	"Wireshark"
	"GV"
}

#
# Define some useful functions for motion-based actions.
#
MoveDelta 20
Function "move-or-lower" { f.move f.deltastop f.lower }
Function "move-or-raise" { f.move f.deltastop f.raise }
Function "move-or-iconify" { f.move f.deltastop f.iconify }

Button1 = : root : f.menu "defops"
Button2 = : root : f.menu "TwmWindows"
Button3 = : root : f.menu "apps"

Button1 = m : window|icon : f.function "move-or-lower"
Button2 = m : window|icon : f.iconify
Button3 = m : window|icon : f.function "move-or-raise"

Button1 = : title : f.function "move-or-raise"
Button2 = : title : f.raiselower

Button1 = : icon : f.function "move-or-iconify"
Button2 = : icon : f.iconify

Button1 = : iconmgr : f.iconify
Button2 = : iconmgr : f.iconify


"Tab" = m : all : f.warpring "next"
"l" = c|s : all : !"${default_terminal} -geometry 80x${default_row}+0+0 &"
"r" = c|s : all : !"${default_terminal} -geometry 80x${default_row}-0+0 &"
"x" = c|s : all : !"xterm &"
"2" = c|s : all : !"${terminal_12pt} -geometry 80x25+0+0 &"
"4" = c|s : all : !"${terminal_14pt} -geometry 80x25+0+0 &"
"6" = c|s : all : !"${terminal_16pt} -geometry 80x25+0+0 &"
"b" = c|s : all : !"${terminal_24pt} -geometry 80x25+0+0 &"
"f" = c|s : all : !"firefox &"
"o" = c|s : all : !"opera &"
"q" = c|s : all : f.quit

"i" = c|s : window : f.iconify

RightTitleButton "minimize.xbm" = f.iconify
RightTitleButton "maximize.xbm" = f.fullzoom
RightTitleButton "kill.xbm" = f.delete
RightTitleButton ":resize" = f.resize
LeftTitleButton ":dot" = f.menu "winops"

#
# And a menus with the usual things
#
InterpolateMenuColors

menu "defops"
{
"Twm"		("white":"${basic_color}") f.title
"Iconify"	f.iconify
"Resize"	f.resize
"Move"		f.move
"Raise"		f.raise
"Lower"		f.lower
"Identify"	f.identify
""		f.nop
"Focus"		f.focus
"Unfocus"	f.unfocus
"Show Iconmgr"	f.showiconmgr
"Hide Iconmgr"	f.hideiconmgr
""		f.nop
"Kill"		f.destroy
"Delete"	f.delete
""		f.nop
"Restart"	f.restart
"Exit"		("white":"black") f.quit
}

menu "winops"
{
"Iconify"	("white":"${basic_color}") f.iconify
"Resize"	f.resize
"Move"		f.move
"Raise"		f.raise
"Lower"		f.lower
"Identify"	f.identify
"Focus"		f.focus
"Unfocus"	f.unfocus
"Kill"		f.destroy
"Delete"	("white":"black") f.delete
}

menu "apps"
{
"Apps"		("white":"${basic_color}") f.title
"${term_cmd} L"	!"${default_terminal} -geometry 80x${default_row}+0+0 &"
"${term_cmd} R"	!"${default_terminal} -geometry 80x${default_row}-0+0 &"
""		f.nop
"${term_cmd} 12pt"	!"${terminal_12pt} -geometry 80x25+0+0 &"
"${term_cmd} 14pt"	!"${terminal_14pt} -geometry 80x25+0+0 &"
"${term_cmd} 16pt"	!"${terminal_16pt} -geometry 80x25+0+0 &"
"${term_cmd} 24pt"	!"${terminal_24pt} -geometry 80x25+0+0 &"
""		f.nop
"xterm"		!"xterm &"
"firefox"	!"firefox &"
"opera"		("white":"black") !"opera &"
}
________twmrc________
}

########################################################################
###
### .Xdefaults
###
########################################################################
xdefaults_template()
{
	cat <<________Xdefaults________
XTerm*scrollBar:		true
XTerm*saveLines:		2048
XTerm*colorBDMode:		true
XTerm*colorBD:			blue
XTerm*colorULMode:		true
XTerm*colorUL:			red
!
KTerm*scrollBar:		true
KTerm*thickness:		12
KTerm*saveLines:		2048
KTerm*kanjiMode:		euc
KTerm*fontList:			-*-fixed-medium-r-normal--12-*
KTerm*allowSendEvents:		true
KTerm*inputMethod:		kinput2
KTerm*VT100.translations: #override \n\
	Shift<Key>space: begin-conversion(_JAPANESE_CONVERSION)
KTerm*colorBDMode:		true
KTerm*colorBD:			blue
KTerm*colorULMode:		true
KTerm*colorUL:			red
KTerm*foreground:		black
KTerm*background:		white
!
rxvt*scrollBar:			true
rxvt*saveLines:			1024
rxvt*foreground:		black
rxvt*background:		white
rxvt*scrollColor:		grey
rxvt*troughColor:		grey
rxvt*smallfont_key:		Alt-Left
rxvt*bigfont_key:		Alt-Right
rxvt*colorBD:			#060
rxvt*colorUL:			#660
rxvt*color3:			#660
rxvt*color11:			#aa0
rxvt*font:			-misc-fixed-medium-r-normal--12-*-iso8859-1
rxvt*font2:			-misc-fixed-medium-r-normal--14-*-iso8859-1
rxvt*font3:			-misc-fixed-medium-r-normal--16-*-iso8859-1
rxvt*boldFont:			-misc-fixed-medium-r-normal--12-*-iso8859-1
rxvt*mfont:			-misc-fixed-medium-r-normal--12-*-jisx0208.1983-*
rxvt*mfont2:			-misc-fixed-medium-r-normal--14-*-jisx0208.1983-*
rxvt*mfont3:			-misc-fixed-medium-r-normal--16-*-jisx0208.1983-*
rxvt*multichar_encoding:	eucj
rxvt*inheritPixmap:		false
rxvt*preeditType:		OverTheSpot
rxvt*inputMethod:		kinput2
!
URxvt.termName:			rxvt
!
XClock*font:			-*-fixed-medium-r-normal--12-*-iso8859-1
!
Mozilla*preeditType:		OverTheSpot
Mozilla*inputMethod:		kinput2
!
Kinput2*sendbackKeyPress:	true
Kinput2*xlsConversionStartKeys:	Shift<Key>space 
!
emacs*FontSetList:		default-fontset,14,12
emacs*FontSet-12:\
	-misc-fixed-medium-r-normal--12-*-iso8859-1\
	-kaname-fixed-medium-r-normal--12-*-jisx0208.1983-*\
	-kaname-fixed-medium-r-normal--12-*-jisx0201.1976-*
emacs*FontSet-14:\
	-misc-fixed-medium-r-normal--14-*-iso8859-1\
	-misc-fixed-medium-r-normal--14-*-jisx0208.1983-*\
	-misc-fixed-medium-r-normal--14-*-jisx0201.1976-*
!
!xemacs.default.attributeFont:		-*-fixed-medium-r-normal--12-*
________Xdefaults________
}

########################################################################
###
### Exec
###
########################################################################
wm=$1

eval ${wm:=twm}_xinit
eval `hostname -s`_xinit
default_xinit
mlterm_xinit

if is_cygwin; then
	xterm
elif check_command $wm; then
        eval exec $wm
else    
        exec twm
fi

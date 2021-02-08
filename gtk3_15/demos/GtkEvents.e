
----------------
namespace events
----------------

export constant version = "4.15.0"

--------------------------------------------------------
--Many Thanks to Pete Eberlein for helping with this! --
--------------------------------------------------------

------------------------------------------------------------------------
-- This library is free software; you can redistribute it               
-- and/or modify it under the terms of the GNU Lesser General           
-- Public License as published by the Free Software Foundation;         
-- either version 2 of the License, or (at your option) any later       
-- version.                                                             
--                                                                      
-- This library is distributed in the hope that it will be useful,      
-- but WITHOUT ANY WARRANTY; without even the implied warranty of       
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                 
-- See the GNU Lesser General Public License for more details.          
--                                                                      
-- You should have received a copy of the GNU Lesser General Public     
-- License along with this library; if not, write to the Free Software  
-- Foundation, Inc., 59 Temple Pl, Suite 330, Boston, MA 02111-1307 USA 
------------------------------------------------------------------------
	
include GtkEngine.e
include std/convert.e

if not equal(version,gtk:version) then
    Error(,,"GtkEvents version mismatch","should be version " & gtk:version)
end if

-- 1. Maps keys from keypad to match same keys on keyboard,
-- 2. maps control/arrow keys to negative numbers, so they 
--    can be differentiated from the same ascii character values;

constant keyvalues = {
{8,-8},   -- bksp
{9,-9},   -- tab
{20,-20}, -- scroll lock
{27,27},  -- escape
{80,-80}, -- home        'P'
{81,-81}, -- left arrow  'Q'
{82,-82}, -- up arrow    'R'
{83,-83}, -- right arrow 'S'
{84,-84}, -- down arrow  'T'
{85,-85}, -- page up     'U'
{86,-86}, -- page dn     'V'
{87,-87}, -- end         'W'
{99,-99}, -- insert      'c'
{103,-103},
{127,-127}, -- num lock

{141,13}, -- keypad Enter, with or w/o numlock;

-- keypad keys w/o numlock;
{149,-149}, -- keypad home
{150,-150}, -- keypad left
{151,-151}, -- keypad up
{152,-152}, -- keypad right
{153,-153}, -- keypad down
{154,-154}, -- keypad pg up
{155,-155}, -- keypad pg dn
{156,-156}, -- keypad end
{157,-157}, -- keypad 5
{158,-158}, -- keypad ins
{159,-159}, -- keypad del

-- keypad keys with numlock - return ascii 0..9
{170,'*'},{171,'+'},{173,'-'},{175,'/'}, 
{176,48},{177,49},{178,50},{179,51},{180,52}, -- keypad numbers 0..4
{181,53},{182,54},{183,55},{184,56},{185,57}, -- keypad numbers 5..9

-- F keys;
{190,-190}, -- F1
{191,-191}, -- F2
{192,-192}, -- F3
{193,-193}, -- F4
{194,-194}, -- F5
{195,-195}, -- F6
{196,-196}, -- F7
{197,-197}, -- F8
{198,-198}, -- F9
{199,-199}, -- F10
{200,-200}, -- F11
{201,-201}, -- F12
{227,-227}, -- left ctl
{228,-228}, -- right ctl
{229,-229},
{225,-225}, -- left shift
{226,-226}, -- right shift
{228,-228},
{233,-233}, -- left alt
{234,-234}, -- right alt
{236,-236},
{255,-255}, -- delete
$}

constant shiftkeys = {
{32,-9}, -- shift tab
$}

constant event_names = {
    {3,"focus-in"},
    {11,"focus-out"}
    }

-----------------------------------------
export function event_type(atom event)
-----------------------------------------
return gtk_func("gdk_event_get_event_type",{P})
end function
 
-----------------------------------------
export function event_peek()
-----------------------------------------
return gtk_func("gdk_event_peek",{})
end function

-----------------------------------------
export function scancode(atom event)
-----------------------------------------
return gtk_func("gdk_event_get_scancode",{P},{event}) 
end function

---------------------------------------
export function seat(atom event)
---------------------------------------
return gtk_func("gdk_event_get_seat",{P},{event})
end function

------------------------------------------------------------
export function triggers_context_menu(atom event)
------------------------------------------------------------
return gtk_func("gdk_event_triggers_context_menu",{P})
end function

----------------------------------
export function key(atom event) -- get key pressed;
----------------------------------
if event = 0 then return 0 end if
integer k = peek(event+16)
integer z = peek(event+17)
integer s = state(event)
ifdef BITS64 then 
	k = peek(event+28)
	z = peek(event+29) 
end ifdef 
switch z do
	case 0 then return k
	case 255 then return vlookup(k,keyvalues,1,2,k)
	case 254 then return vlookup(k,shiftkeys,1,2,k)
end switch
return 0
end function

--(32/64)struct GdkEventButton
--  0  0 GdkEventType type a.k.a. id
--  4  8 GtkWindow *window
--  8 16 gint8 send_event
-- 12 20 guint32 time
-- 16 24 gdouble x
-- 24 32 gdouble y
-- 32 40 gdouble *axes
-- 36 48 guint state
-- 40 52 guint button
-- 44 56 GdkDevice *device
-- 48 64 gdouble x_root, y_root

---------------------------------------------------------------------
export function id(atom event) 
---------------------------------------------------------------------
if event > 0 then return peek4u(event) 
else return event end if
end function

---------------------------------------------------------------------
export function name(atom event)
---------------------------------------------------------------------
event = id(event)
for i = 1 to length(event_names) do
    if event = event_names[i][1] then
	return event_names[i][2]
    end if
end for
return -1
end function

---------------------------------------------------------------------
export function window(atom event) -- get event window
---------------------------------------------------------------------
ifdef BITS64 then
    return peek8u(event + 8)
end ifdef
    return peek4u(event + 4)
end function

---------------------------------------------------------------------
export function time(atom event) -- get event time
---------------------------------------------------------------------
ifdef BITS64 then
    return peek4u(event + 20)
end ifdef
    return peek4u(event + 12)
end function

---------------------------------------------------------------------
export function xy(atom event) -- get mouse button x y;
---------------------------------------------------------------------
ifdef BITS64 then
    return floor({
	float64_to_atom(peek({event + 24, 8})),
	float64_to_atom(peek({event + 32, 8}))})
end ifdef
    return floor({
	float64_to_atom(peek({event + 16, 8})),
	float64_to_atom(peek({event + 24, 8}))})
end function

---------------------------------------------------------------------
export function axes(atom event)
---------------------------------------------------------------------
ifdef BITS64 then
	return float64_to_atom(peek({event + 40, 8}))
end ifdef
	return float64_to_atom(peek({event + 32, 8}))
end function

-----------------------------------------------------
export function coords(atom event)
-----------------------------------------------------
atom x = allocate(8), y = allocate(8)
atom fn = define_c_func(LIBS,"gdk_event_get_coords",{P,D,D},B)
integer result = c_func(fn,{event,x,y})
return {result,peek4u(x),peek4u(y)}
end function

---------------------------------------------------------------------
export function button(atom event) -- get mouse button clicked;
---------------------------------------------------------------------
ifdef BITS64 then
   return peek(event+52)
end ifdef
return peek(event+40)
end function

----------------------------------------------------------------------
export function state(atom event)
----------------------------------------------------------------------
ifdef BITS64 then
    return peek(event+48)
end ifdef
return peek(event+36)
end function

----------------------------------------------------------------------
export function device(atom event)
----------------------------------------------------------------------
ifdef BITS64 then
    return peek(event+56)
end ifdef
return peek(event+44)
end function

---------------------------------------------------------------------
export function clicks(atom event)
---------------------------------------------------------------------
atom ct = allocate(64)
object result
    if gtk_func("gdk_event_get_click_count",{P,I},{event,ct}) then
        result = peek4u(ct)
    else
        result = -1
    end if
    free(ct)
return result
end function

---------------------------------------------------------------------
export function scroll_dir(atom event)
---------------------------------------------------------------------
atom dir = allocate(64)
object result
    if gtk_func("gdk_event_get_scroll_direction",{P,I},{event,dir}) then
        result = peek4u(dir)
    else
        result = -1
    end if
    free(dir)
return result
end function

---------------------------------------------------------------------------------
export function pending() -- used sometimes when using timeout or eu tasks
---------------------------------------------------------------------------------
    return gtk_func("gtk_events_pending")
end function 

------------------------------------------------------------------------
export procedure main_iteration()
------------------------------------------------------------------------
    gtk_proc("gtk_main_iteration")
end procedure

------------------------------------------------------------------------------------
export function main_iteration_do(integer i=1) -- used sometimes when multi-tasking;
------------------------------------------------------------------------------------
    return gtk_func("gtk_main_iteration_do",{I},{i})
end function

------------------------------------------------------------------------
-- following routine traps the enter key when Entry is activated,
-- and uses it like the tab key - so it works like people expect.
-- When using Glade, connect each entry's 'activate' signal to 
-- trap_enter_key
------------------------------------------------------------------------
constant gsig = define_proc("g_signal_emit_by_name",{P,P,P})
constant fsig = allocate_string("move-focus")
------------------------------------------------------------------------
global function trap_enter_key(atom ctl, atom event)
-----------------------------------------------------------------------
	if class_id(ctl) = GtkEntry then
		if event = 0 then 
			c_proc(gsig,{ctl,allocate_string("move-focus"),0})
			return 1
		end if
	end if
return 0
end function

-----------------------------
-- copyright 2018 Irv Mullins
-----------------------------



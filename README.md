# EuGTK
A cross-platform GTK3 library for the Euphoria 4 programming language. EuGTK makes it easy to create modern, professional programs quickly. 

Euphoria is a powerful but easy-to-learn programming language. It has a simple syntax and structure with consistent rules, and is also easy to read. You can quickly, and with little effort, develop applications, big and small, for Windows, Unix variants (Linux, FreeBSD, ...) and OS X. 

EuGTK wraps the GTK3 calls in a sudo object-oriented fashion; you create GTK objects, and then set or get properties of those objects. There's no need to manually lay out "widgets", this is handled automatically. 

Development is fast, since Euphoria is one of the fastest interpreters available, making the development cycle easy (you just test each line of code as you add it) - and Euphoria can optionally convert your code to C and compile it into an executable with a single call.

For more information:
https://sites.google.com/site/euphoriagtk/Home

----------------------------------------------------------------------------
--# Example: Yet Another Hello World! program
----------------------------------------------------------------------------

include GtkEngine.e

--[1] create the widgets;

constant   
	win = create(GtkWindow,"border width=10,icon=face-laugh,$destroy=Quit"),<br />
	pan = create(GtkBox,"orientation=vertical"), <br />
	box = create(GtkButtonBox), <br />
	btn = create(GtkButton,"gtk-quit", "Quit"),<br />
	lbl = create(GtkLabel,"color=blue")

--[2] mark up label using basic html; 

    set(lbl,"markup", 
    "&lt;b&gt;&lt;u&gt;&lt;span color='red'&gt;&lt;big&gt;Hello World!&lt;/big&gt;&lt;/span&gt;&lt;/u&gt;&lt;/b&gt;\n\n" &amp; 
    "This demos a simple window with\na label and a quit button.\n")

--[3] add widgets to containers; 

    add(win,pan)  <br />
    add(pan,lbl)  <br />
    add(box,btn)  <br />
    pack(pan,-box)
 
show_all(win) --[4] instantiate widgets; <br />
main()        --[5] enter main processing loop; <br />

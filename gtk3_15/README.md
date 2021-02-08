![Hello.ex](https://github.com/irvm/EuGTK/blob/master/hello.png?raw=true)

A cross-platform GTK3 library for the [Euphoria](http://openeuphoria.org) programming language. EuGTK makes it easy to create modern, professional programs quickly. 

Euphoria is a powerful but easy-to-learn programming language. It has a simple syntax and structure with consistent rules, and is also easy to read. You can quickly, and with little effort, develop applications, big and small, for Windows, Unix variants (Linux, FreeBSD, ...) and OS X. 

EuGTK wraps the [GTK3](http://gtk.org) calls in a sudo object-oriented fashion; you create GTK objects, and then set or get properties of those objects. There's no need to manually lay out "widgets", this is handled automatically. 
No tricky sizing or layout code is required, and all that crazy type-casting you have to do with other programming languages doesn't exist! In addition, EuGTK provides 'wrappers' around several of the more difficult-to-use Gtk widgets (e.g. GtkListView) which makes them much easier to use.

Development is fast, since Euphoria is one of the fastest interpreters available, making the development cycle easy (you just test each line of code as you add it) - and Euphoria can optionally convert your code to C and compile it into an executable with a single call.

For more information:
https://sites.google.com/site/euphoriagtk/Home

```
----------------------------------------------------------------------------
--# Example: Yet Another Hello World! program
----------------------------------------------------------------------------

include GtkEngine.e

--[1] create the widgets;

constant   
	win = create(GtkWindow,"border width=10,icon=face-laugh,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical"), 
	box = create(GtkButtonBox), 
	btn = create(GtkButton,"gtk-quit", "Quit"),
	lbl = create(GtkLabel,"color=blue")

--[2] mark up label using basic html; 

    set(lbl,"markup", 
	"<b><u><span color='red'><big>Hello World!</big></span></u></b>\n\n" &
	"This demos a simple window with\na label and a quit button.\n")

--[3] add widgets to containers; 

    add(win,pan)  
    add(pan,lbl)  
    add(box,btn)  
    pack(pan,-box)
 
show_all(win) --[4] instantiate widgets; 
main()        --[5] enter main processing loop; 
```

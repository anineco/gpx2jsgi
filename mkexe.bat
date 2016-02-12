@echo off
bin\tclkitsh bin\sdx.kit qwrap gpx2jsgi.tcl -runtime bin\tclkit.exe
copy gpx2jsgi gpx2jsgi.exe
del gpx2jsgi
bin\tclkitsh bin\sdx.kit qwrap iconview.tcl -runtime bin\tclkit.exe
copy iconview iconview.exe
del iconview
bin\tclkitsh bin\sdx.kit qwrap jsgi2kml.tcl -runtime bin\tclkit.exe
copy jsgi2kml jsgi2kml.exe
del jsgi2kml

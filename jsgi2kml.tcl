#!/bin/sh
# the next line restarts using wish \
exec wish8.5 -encoding cp932 "$0" "$@"
# jsgi2kml.tcl - convert JSGI file to KML file
# Copyright (C) 2013 by anineco@nifty.com

set VERSION 1.3

# �f�[�^�t�H���_
set data [file join $env(APPDATA) map.jpn.org gpx2jsgi]
if {![file exists $data]} {file mkdir $data}

set cwd [file join $env(USERPROFILE)]
set jsgifile {}

# �t�H���_�����ċA�I�Ɍ���
# http://www.karak.jp/2009/10
proc globRecursive {dir masks} {
  set result [list]
  foreach cur [lsort [glob -nocomplain -dir $dir *]] {
    if {[file type $cur] == "directory"} {
      eval lappend result [globRecursive $cur $masks]
    } else {
      foreach mask $masks {
        if {[string match $mask $cur]} {
          lappend result $cur
          break
        }
      }
    }
  }
  return $result
}

wm title . JSGI2KML
wm resizable . 0 0
set top .top
ttk::frame $top
$top configure -padding 5
ttk::label $top.a0 -text "JSGI��KML�R���o�[�^ Ver.$VERSION"
grid $top.a0 -in $top -row 0 -column 0 -columnspan 6

ttk::label $top.a1 -text JSGI�t�@�C��
listbox $top.b1 -listvar jsgifiles -selectmode single -yscrollcommand "$top.e1 set"
$top.b1 configure -width 80 -height 12
scrollbar $top.e1 -orient vertical -command "$top.b1 yview"
ttk::button $top.f1 -text ���t�H���_ -command {
  set ret [tk_chooseDirectory -initialdir $cwd -mustexist yes]
  if {$ret == ""} {
    return
  }
  set cwd $ret
  set ret [globRecursive $cwd {*.xml}]
  foreach f $ret {
    $top.b1 insert end $f
    if {[file exists [file rootname $f].kml]} {
      $top.b1 itemconfigure end -background red
    }
  }
  tk_messageBox -type ok -title ���� -message "[llength $ret]�̃t�@�C����I�����܂���"
}
ttk::button $top.f2 -text ���t�@�C�� -command {
  set ret [tk_getOpenFile -filetypes {{"JSGI�t�@�C��" {.xml}} {"���ׂ�" {*}}} -initialdir $cwd -multiple yes]
  foreach f $ret {
    $top.b1 insert end $f
    if {[file exists [file rootname $f].kml]} {
      $top.b1 itemconfigure end -background red
    }
    set cwd [file dirname $f]
  }
}
ttk::button $top.f3 -text ���O -command "$top.b1 delete active"
ttk::button $top.f4 -text �N���A -command "$top.b1 delete 0 end"
grid $top.a1 -in $top -row 1 -column 0 -sticky ne
grid $top.b1 -in $top -row 1 -rowspan 12 -column 1 -columnspan 3 -sticky nsew
grid $top.e1 -in $top -row 1 -rowspan 12 -column 4 -sticky ns
foreach i {1 2 3 4} {grid $top.f$i -in $top -row $i -column 5 -sticky ew}

ttk::button $top.conv -text �ϊ� -command {
  if {$jsgifiles == {}} {
    tk_messageBox -type ok -icon warning -title �x�� -message "JSGI�t�@�C�������ݒ�"
    return
  }
  set out [open $data/success.log w]
  set cur [clock seconds]
  puts $out [clock format $cur -format "�ϊ��J�n %c"]
  set n [llength $jsgifiles]
  set i 0
  foreach src $jsgifiles {
    set dst [file rootname $src].kml
    exec bin/xsltproc jsgi2kml.xsl $src > $dst
    puts $out $dst
    incr i
  }
  set cur [clock seconds]
  puts $out [clock format $cur -format "�ϊ��I�� %c"]
  close $out
  set ret [tk_messageBox -type yesno -icon question -title ���� -message "${i}/${n}�̃t�@�C����ϊ����܂���\n���O�t�@�C�����J���܂����H"]
  if {$ret} {
    exec cmd /c start notepad [file nativename $data/success.log] &
  }
}
grid $top.conv -in $top -row 13 -column 2

ttk::button $top.exit -text �I�� -command { exit }
grid $top.exit -in $top -row 13 -column 5 -sticky ew
pack $top

# end of jsgi2kml.tcl

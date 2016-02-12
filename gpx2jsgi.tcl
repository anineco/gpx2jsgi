#!/bin/sh
# the next line restarts using wish \
exec wish8.5 -encoding cp932 "$0" "$@"
# gpx2jsgi.tcl - convert GPX files into JSGI/KML/GPX file
# Copyright (C) 2008-2014 by anineco@nifty.com

package require http

set VERSION 1.5

# データフォルダ
set data [file join $env(APPDATA) map.jpn.org gpx2jsgi]
set temp $data/temp
if {![file exists $temp]} {file mkdir $temp}
foreach f {iconlut.xml iconlut.dtd iconlut2html.xsl} {
	if {![file exists $data/$f]} {file copy $f $data}
}

array set meta "
	sw off
	データセット名 ルート地図：
	作成日 [clock format [clock seconds] -format %Y-%m-%d]
	提供者 {}
	Email {}
	URL {}
	摘要 {}
"

set image_sw off
set decim_sw off
set decim_err 0.005
set cwd [file join $env(USERPROFILE)]

# パラメータを読み込む
if {[file exists $data/param.tcl]} {source -encoding cp932 $data/param.tcl}

array set xsl {
	JSGI gpx2jsgi.xsl
	KML gpx2kml.xsl
	GPX identity.xsl
}
array set ext {
	JSGI xml
	KML kml
	GPX gpx
}
array set msg {
	JSGI ネイティブ化
	KML KML→KMZ
	GPX {}
}
set mode KML

set gpxfiles {}
set outfile {}
foreach p {軌跡点数 中心緯度 中心経度} {set result($p) {}}

# 指定したGPXファイルをインクルードする$data/main.gpxを作成する
proc prepare {} {
	global data meta gpxfiles VERSION
	set out [open $data/main.gpx w]
	fconfigure $out -translation lf -encoding utf-8
	puts $out "<?xml version='1.0' encoding='UTF-8'?>
<gpx version='1.1' creator='GPX2JSGI Ver.$VERSION'
xmlns='http://www.topografix.com/GPX/1/1'
xmlns:kashmir3d='http://www.kashmir3d.com/namespace/kashmir3d'
xmlns:xi='http://www.w3.org/2001/XInclude'>"
	if {$meta(sw)} {
# metadata要素を出力
		lassign [split $meta(Email) @] id domain
		puts $out "<metadata>
<name>$meta(データセット名)</name>
<author>
<name>$meta(提供者)</name>
<email id='$id' domain='$domain'/>
<link href='$meta(URL)'>
<text>$meta(摘要)</text>
</link>
</author>
<time>$meta(作成日)</time>
</metadata>"
	}
	set i 1
	foreach f $gpxfiles {
# Ver.8.8.5以前のカシミール3Dが出力するGPXファイルの名前空間の間違いを修正
		exec bin/xsltproc --xinclude fixver.xsl $f > $data/$i.gpx
# 修正したGPXファイルをインクルード
		puts $out "<xi:include href='$i.gpx'
xpointer='xmlns(gpx=http://www.topografix.com/GPX/1/1)
xpointer(/gpx:gpx/*\[local-name()!=\"metadata\"\])'/>"
		incr i
	}
	puts $out {</gpx>}
	close $out
}

wm title . GPX2JSGI
wm resizable . 0 0
set top .top
ttk::frame $top
$top configure -padding 5
ttk::label $top.a0 -text "GPX→KMLコンバータ Ver.$VERSION"
grid $top.a0 -in $top -row 0 -column 0 -columnspan 6

ttk::label $top.a1 -text GPXファイル
listbox $top.b1 -listvar gpxfiles -selectmode single -yscrollcommand "$top.e1 set"
$top.b1 configure -width 80 -height 4
scrollbar $top.e1 -orient vertical -command "$top.b1 yview"
ttk::button $top.f1 -text ←追加 -command {
	set ret [tk_getOpenFile -filetypes {{GPXファイル {.gpx}} {すべて {*}}} -initialdir $cwd -multiple yes]
	foreach f $ret {
		$top.b1 insert end $f
		set cwd [file dirname $f]
	}
}
ttk::button $top.f2 -text 除外 -command "$top.b1 delete anchor"
ttk::button $top.f3 -text クリア -command "$top.b1 delete 0 end"
grid $top.a1 -in $top -row 1 -column 0 -sticky ne
grid $top.b1 -in $top -row 1 -rowspan 3 -column 1 -columnspan 3 -sticky nsew
grid $top.e1 -in $top -row 1 -rowspan 3 -column 4 -sticky ns
foreach i {1 2 3} {grid $top.f$i -in $top -row $i -column 5 -sticky ew}

ttk::label $top.a4 -text 出力形式
ttk::frame $top.mode
ttk::radiobutton $top.mode.b1 -text JSGI -value JSGI -var mode -command {
	$top.conv.b2 configure -text $msg($mode) -state normal
}
ttk::radiobutton $top.mode.b2 -text KML -value KML -var mode -command {
	$top.conv.b2 configure -text $msg($mode) -state normal
}
ttk::radiobutton $top.mode.b3 -text GPX -value GPX -var mode -command {
	$top.conv.b2 configure -text $msg($mode) -state disabled
}
pack $top.mode.b1 $top.mode.b2 $top.mode.b3 -side left
grid $top.a4 -in $top -row 4 -column 0 -sticky e
grid $top.mode -in $top -row 4 -column 1 -sticky w

ttk::label $top.a5 -text 出力ファイル
ttk::entry $top.b5 -textvariable outfile
ttk::button $top.f5 -text 選択 -command {
	set e $ext($mode)
	set outfiletypes [list [list ${mode}ファイル .$e] {すべて {*}}]
	set ret [tk_getSaveFile -filetypes $outfiletypes -initialdir $cwd -initialfile routemap.$e -defaultextension $e]
	if {$ret != {}} {set outfile $ret}
}
grid $top.a5 -in $top -row 5 -column 0 -sticky e
grid $top.b5 -in $top -row 5 -column 1 -columnspan 4 -sticky ew
grid $top.f5 -in $top -row 5 -column 5 -sticky ew

ttk::checkbutton $top.b6 -text メタデータを付加 -variable meta(sw) -command {
	set s [expr {$meta(sw) ? {normal} : {disabled}}]
	foreach i {7 8 9 10 11 12} {$top.b$i configure -state $s}
}
grid $top.b6 -in $top -row 6 -column 1 -sticky w

set i 7
foreach p {データセット名 作成日 提供者 Email URL 摘要} {
	ttk::label $top.a$i -text $p
	ttk::entry $top.b$i -textvariable meta($p) -width 30 -state disabled
	grid $top.a$i -in $top -row $i -column 0 -sticky e
	grid $top.b$i -in $top -row $i -column 1 -sticky ew
	incr i
}

ttk::checkbutton $top.d6 -text 軌跡を間引く -variable decim_sw -command {
	set s [expr {$decim_sw ? {normal} : {disabled}}]
	$top.d7 configure -state $s
}
grid $top.d6 -in $top -row 6 -column 3 -columnspan 2 -sticky w

ttk::label $top.c7 -text {許容誤差[km]}
spinbox $top.d7 -textvariable decim_err -format %5.3f -from 0.001 -to 9.999 -increment 0.001 -state disabled
grid $top.c7 -in $top -row 7 -column 2 -sticky e
grid $top.d7 -in $top -row 7 -column 3 -columnspan 2 -sticky ew

ttk::label $top.d8 -text 変換結果情報
grid $top.d8 -in $top -row 8 -column 3 -columnspan 2 -sticky w

set i 9
foreach p {軌跡点数 中心緯度 中心経度} {
	ttk::label $top.c$i -text $p
	ttk::entry $top.d$i -textvariable result($p) -width 30 -foreground blue -state disabled
	grid $top.c$i -in $top -row $i -column 2 -sticky e
	grid $top.d$i -in $top -row $i -column 3 -columnspan 2 -sticky ew
	if {$p != {軌跡点数}} {
		ttk::button $top.f$i -text コピー -command "clipboard clear; clipboard append \$result($p)"
		grid $top.f$i -in $top -row $i -column 5 -sticky ew
	}
	incr i
}

ttk::frame $top.conv
ttk::button $top.conv.b1 -text 変換 -command {
	if {$gpxfiles == {}} {
		tk_messageBox -type ok -icon warning -title 警告 -message "GPXファイルが未設定"
		return
	}
	if {$outfile == {}} {
		tk_messageBox -type ok -icon warning -title 警告 -message "${mode}ファイルが未設定"
		return
	}
	if {$meta(sw)} {
		foreach p {データセット名 作成日 提供者 Email URL 摘要} {
			if {$meta($p) == {}} {
				tk_messageBox -type ok -icon warning -title 警告 -message "${p}が未設定"
				return
			}
		}
	}
	prepare ;# $data/main.gpxを作成
	if {$decim_sw} {
# トラックデータを間引く
		exec bin/xsltproc --xinclude filter1.xsl $data/main.gpx > $data/aux1.gpx
		exec bin/gpsbabel -t -i gpx -f $data/aux1.gpx -x simplify,error=${decim_err}k -o gpx,gpxver=1.1 -F $data/aux2.gpx
		exec bin/xsltproc --xinclude filter2.xsl $data/main.gpx > $data/decim.gpx
		set main $data/decim.gpx
	} else {
		set main $data/main.gpx
	}
	exec bin/xsltproc --xinclude $xsl($mode) $main > $outfile
	lassign [exec bin/xsltproc --xinclude center.xsl $main] result(軌跡点数) result(中心緯度) result(中心経度)
	tk_messageBox -type ok -title 成功 -message "変換結果を${outfile}に出力しました"
}

ttk::button $top.conv.b2 -text $msg($mode) -command {
	if {$outfile == {}} {
		tk_messageBox -type ok -icon warning -title 警告 -message "出力ファイルが未選択"
		return
	}
	if {![file exists $outfile]} {
		tk_messageBox -type ok -icon warning -title 警告 -message "${outfile}がない"
		return
	}
	if {$mode == {JSGI}} {
		set ret [file rootname $outfile].htm
		exec bin/x2h $outfile [file dirname $outfile] $data/x2h.log 2> $data/err.log
	} else {
		set ret [file rootname $outfile].kmz
		eval file delete [glob -nocomplain -directory $temp *]
		if {$image_sw} {
			set icons [exec bin/xsltproc geturl.xsl $outfile]
			set lut [open $data/templut.xml w]
			puts $lut {<iconlut>}
			foreach icon $icons {
				lassign $icon id url
				if {[string range $url 0 4] == {http:}} {
					set out [open $temp/$id w]
					set http [::http::geturl $url -channel $out]
					::http::cleanup $http
					close $out
				} else {
					file copy $url $temp/$id
				}
				lassign [exec bin/identify -format {%m %w %h} $temp/$id] m w h
				set src $id.[string tolower $m]
				file rename $temp/$id $temp/$src
				puts $lut "<icon code='$id' src='$src'/>"
			}
			puts $lut {</iconlut>}
			close $lut
			exec bin/xsltproc --stringparam ICONLUT $data/templut.xml puturl.xsl $outfile > $temp/doc.kml
		} else {
			file copy $outfile $temp/doc.kml
		}
		eval exec bin/zip --quiet --junk-paths - [glob -directory $temp *] > $ret
	}
	tk_messageBox -type ok -title 成功 -message "変換結果を${ret}に出力しました"
}

$top.conv.b1 configure -width 12
$top.conv.b2 configure -width 12
pack $top.conv.b1 $top.conv.b2 -side left
grid $top.conv -in $top -row 13 -column 1

ttk::button $top.exit -text 終了 -command {
# パラメータを保存する
	set out [open $data/param.tcl w]
	fconfigure $out -encoding cp932
	foreach p {提供者 Email URL 摘要} {puts $out "set meta($p) {$meta($p)}"}
	puts $out "set decim_sw {$decim_sw}"
	puts $out "set decim_err {$decim_err}"
	puts $out "set cwd {$cwd}"
	close $out
	exit
}
grid $top.exit -in $top -row 13 -column 5 -sticky ew
pack $top

# end of gpx2jsgi.tcl

#!/bin/sh
# the next line restarts using wish \
exec wish8.5 -encoding cp932 "$0" "$@"
# iconview.tcl - display list of KASHMIR 3D's symbol images
# Copyright (C) 2011 by anineco@nifty.com

set VERSION 1.2

set usage {このプログラムは、カシミール3Dでウェイポイントに
設定可能なアイコンを一括変換して、電子国土Webシステムや
Google_Mapsの地図上に表示可能なシンボル画像（透過処理済）
のフルセットと、これを用いるアイコン変換表を作成するユーティリティです。
動作には、カシミール3Dがインストールされていることが必要です。
まず[一覧作成]ボタンを押し、作成完了のメッセージを確認してから、
[一覧表示]ボタンを押して下さい。ブラウザが起動し、
生成したシンボル画像をアイコン変換表の形式で一覧表示します。}

set copyright {本プログラムで作成したシンボル画像は、
電子国土WebシステムやGoogle_Maps等のWeb地図上での表示、
および、それらに関連する凡例・説明等での表示に限って非商用で使用し、
その他の用途での使用や商用での使用、
特に画像ファイルを単体で配布することはご遠慮下さい。}

set data [file join $env(APPDATA) map.jpn.org gpx2jsgi]
set iconstck [file join $env(ALLUSERSPROFILE) Documents Kashmir IconStck.dat]

########################################
# ファイルとフォルダの指定
#
set symbols $data/icons
set workdir $data/temp
set bmpfile $workdir/iconstck.bmp
set xmlfile $data/iconlut_local.xml

if {![file exists $symbols]} {file mkdir $symbols}
if {![file exists $workdir]} {file mkdir $workdir}
foreach f {iconlut.dtd iconlut2html.xsl} {
  if {![file exists $data/$f]} {file copy $f $data}
}

########################################
# 手続き
#
proc getI2 {in} {
  set buf [read $in 2]
  binary scan $buf s v
  return $v
}

proc getI4 {in} {
  set buf [read $in 4]
  binary scan $buf i v
  return $v
}

proc getA {in} {
  set buf [read $in 1]
  binary scan $buf cu len
  return [encoding convertfrom cp932 [read $in $len]]
}

proc genicon {iconstck} {
  global symbols workdir xmlfile bmpfile auto_execs

  set in [open $iconstck r]
  fconfigure $in -translation binary
  getI4 $in
  getI4 $in
  getI4 $in
  set n [getI4 $in]
  for {set i 0} {$i < $n} {incr i} {
    set flag [getI4 $in]
    set str [getA $in]
    set nIcon [getI4 $in]
    set nType [getI4 $in]
    set idx [getI4 $in]
    if {$flag} {continue}
    set img($nIcon) [format %03d $idx]
    set nam($nIcon) $str
  }
  set n_icon [getI4 $in]
  seek $in [expr $n_icon * 10 + 28] current
  set bmp [open $bmpfile w]
  fconfigure $bmp -translation binary
  fcopy $in $bmp
  close $bmp
  close $in

  exec -ignorestderr bin/convert \
      ( $bmpfile\[0\] -fill "#fefefe" -opaque "#ffffff" ) \
      ( $bmpfile\[1\] -transparent "#000000" ) \
      -composite -transparent "#ffffff" \
      -crop 24x24 PNG8:$workdir/%03d.png
  foreach nIcon [array names img] {
    file rename -force $workdir/$img($nIcon).png $symbols/$nIcon.png
  }

  set xml [open $xmlfile w]
  fconfigure $xml -translation lf -encoding utf-8
  puts $xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"iconlut2html.xsl\"?>
<!DOCTYPE iconlut SYSTEM \"iconlut.dtd\" \[
<!ENTITY baseurl \"$symbols/\">
\]>
<iconlut>"
  foreach nIcon [lsort [array names img]] {
    puts $xml "<icon code=\"$nIcon\" src=\"&baseurl;$nIcon.png\" size=\"24\">$nam($nIcon)</icon>"
  }
  puts $xml {</iconlut>}
  close $xml
}

########################################
# 部品の定義と配置
#
wm title . "ICONVIEW Ver.$VERSION"

label .l0 -text 説明 -fg blue
message .usage -bg white -width 400 -text [join $usage ""]
label .l1 -text ！注意！ -fg red
message .copyright -bg white -width 400 -text [join $copyright ""]

set w .f0
ttk::frame $w
ttk::button $w.bexec -text 一覧作成 -command {
  if {![file exists $iconstck]} {
    tk_messageBox -type ok -icon warning -message "カシミール3DのIconStck.datを指定してください。"
    set iconstck [tk_getOpenFile -filetypes {{"DATファイル" {.dat}} {"すべて" {*}}}]
    if {$iconstck == ""} {return}
  }
  if {[file exists $xmlfile]} {
    set ret [tk_messageBox -type okcancel -icon warning -message "作成済のシンボル画像があります。上書きしてよいですか？"]
    if {$ret == "cancel"} {return}
  }
  genicon $iconstck
  tk_messageBox -type ok -message "シンボル画像の作成が完了しました。"
}
ttk::button $w.bshow -text 一覧表示 -command {
  if {![file exists $xmlfile]} {
    tk_messageBox -type ok -message "シンボル画像が作成されていません。"
    return;
  }
  exec cmd /c start iexplore [file nativename $xmlfile] &
}
ttk::button $w.bexit -text 終了 -command exit
pack .l0 .usage .l1 .copyright
pack $w.bexec $w.bshow -side left
pack $w.bexit -side right
pack $w

# end of iconview.tcl

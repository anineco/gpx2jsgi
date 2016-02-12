#!/bin/sh
# the next line restarts using wish \
exec wish8.5 -encoding cp932 "$0" "$@"
# iconview.tcl - display list of KASHMIR 3D's symbol images
# Copyright (C) 2011 by anineco@nifty.com

set VERSION 1.2

set usage {���̃v���O�����́A�J�V�~�[��3D�ŃE�F�C�|�C���g��
�ݒ�\�ȃA�C�R�����ꊇ�ϊ����āA�d�q���yWeb�V�X�e����
Google_Maps�̒n�}��ɕ\���\�ȃV���{���摜�i���ߏ����ρj
�̃t���Z�b�g�ƁA�����p����A�C�R���ϊ��\���쐬���郆�[�e�B���e�B�ł��B
����ɂ́A�J�V�~�[��3D���C���X�g�[������Ă��邱�Ƃ��K�v�ł��B
�܂�[�ꗗ�쐬]�{�^���������A�쐬�����̃��b�Z�[�W���m�F���Ă���A
[�ꗗ�\��]�{�^���������ĉ������B�u���E�U���N�����A
���������V���{���摜���A�C�R���ϊ��\�̌`���ňꗗ�\�����܂��B}

set copyright {�{�v���O�����ō쐬�����V���{���摜�́A
�d�q���yWeb�V�X�e����Google_Maps����Web�n�}��ł̕\���A
����сA�����Ɋ֘A����}��E�������ł̕\���Ɍ����Ĕ񏤗p�Ŏg�p���A
���̑��̗p�r�ł̎g�p�⏤�p�ł̎g�p�A
���ɉ摜�t�@�C����P�̂Ŕz�z���邱�Ƃ͂������������B}

set data [file join $env(APPDATA) map.jpn.org gpx2jsgi]
set iconstck [file join $env(ALLUSERSPROFILE) Documents Kashmir IconStck.dat]

########################################
# �t�@�C���ƃt�H���_�̎w��
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
# �葱��
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
# ���i�̒�`�Ɣz�u
#
wm title . "ICONVIEW Ver.$VERSION"

label .l0 -text ���� -fg blue
message .usage -bg white -width 400 -text [join $usage ""]
label .l1 -text �I���ӁI -fg red
message .copyright -bg white -width 400 -text [join $copyright ""]

set w .f0
ttk::frame $w
ttk::button $w.bexec -text �ꗗ�쐬 -command {
  if {![file exists $iconstck]} {
    tk_messageBox -type ok -icon warning -message "�J�V�~�[��3D��IconStck.dat���w�肵�Ă��������B"
    set iconstck [tk_getOpenFile -filetypes {{"DAT�t�@�C��" {.dat}} {"���ׂ�" {*}}}]
    if {$iconstck == ""} {return}
  }
  if {[file exists $xmlfile]} {
    set ret [tk_messageBox -type okcancel -icon warning -message "�쐬�ς̃V���{���摜������܂��B�㏑�����Ă悢�ł����H"]
    if {$ret == "cancel"} {return}
  }
  genicon $iconstck
  tk_messageBox -type ok -message "�V���{���摜�̍쐬���������܂����B"
}
ttk::button $w.bshow -text �ꗗ�\�� -command {
  if {![file exists $xmlfile]} {
    tk_messageBox -type ok -message "�V���{���摜���쐬����Ă��܂���B"
    return;
  }
  exec cmd /c start iexplore [file nativename $xmlfile] &
}
ttk::button $w.bexit -text �I�� -command exit
pack .l0 .usage .l1 .copyright
pack $w.bexec $w.bshow -side left
pack $w.bexit -side right
pack $w

# end of iconview.tcl

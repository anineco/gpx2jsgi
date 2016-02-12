# mm単位出力
#
# 	x2h.exe xmlfile htmfolder [logfile]
#
#		xmlfile   : xmlファイル名か、xmlファイルがあるフォルダ(絶対パス）
#				    フォルダの場合、含まれるxmlファイルがすべて変換対象となる
#					基本的にxmlファイル名を渡すこと(メモリ消費を押さえるため）)
#		htmfolder : htmファイルを出力するフォルダ(絶対パス)
#		logfile   : ログファイル名
#					省略化：省略した場合x2h.exeがあるフォルダにx2h.logファイルが作成される
#					ログファイルは追記モードでオープンされる
#		【注】ファイル名、フォルダ名の区切り文字は"/"を必ず使用のこと("\"は不可)
#
#		【例】x2h.exe c:/data/xml/test.xml c:/data/htm c:/data/xml/mylog.log
#			  x2h.exe c:/data/xml c:/data/htm

	lscan $::argv exename xmlfile htmfolder logfile
	if {$xmlfile==""} exit
	if {$htmfolder==""} exit
	if {$logfile==""} {set logfile "x2h.log"}

	load tclgdi.dll gdi
	unpack xml2htm.lib

	xml2htm::createCanvas #[gui get root hwnd]
	xml2htm::x2h $xmlfile $htmfolder $logfile
	exit

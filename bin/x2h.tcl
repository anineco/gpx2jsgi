# mm�P�ʏo��
#
# 	x2h.exe xmlfile htmfolder [logfile]
#
#		xmlfile   : xml�t�@�C�������Axml�t�@�C��������t�H���_(��΃p�X�j
#				    �t�H���_�̏ꍇ�A�܂܂��xml�t�@�C�������ׂĕϊ��ΏۂƂȂ�
#					��{�I��xml�t�@�C������n������(������������������邽�߁j)
#		htmfolder : htm�t�@�C�����o�͂���t�H���_(��΃p�X)
#		logfile   : ���O�t�@�C����
#					�ȗ����F�ȗ������ꍇx2h.exe������t�H���_��x2h.log�t�@�C�����쐬�����
#					���O�t�@�C���͒ǋL���[�h�ŃI�[�v�������
#		�y���z�t�@�C�����A�t�H���_���̋�؂蕶����"/"��K���g�p�̂���("\"�͕s��)
#
#		�y��zx2h.exe c:/data/xml/test.xml c:/data/htm c:/data/xml/mylog.log
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

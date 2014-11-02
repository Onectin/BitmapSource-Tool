-- BiTMap Switcher


try(DestroyDialog ::nazboobBTMswitcher) catch()

_localPath = "D:\NZB_SCRIPT\_MAPS"
_lclPathCount = _localPath.count
_networkPath = "W:\PRODUCTION\_MAPS"
_nwPathCount = _networkPath.count

_outOfRange = #()
_outOfRangePath = #()

_bitmapTexture = getClassInstances BitmapTexture

fn _FNsync =
(
	DOSCommand ("XCOPY " + _networkPath + " " + _localPath + " /E /D /C /Y")
)

fn _FNswitch _locToNet =
(
	if _locToNet == 0 do -- Local to Network
	(
		_srcPath = _localPath
		_srcStrCnt = _lclPathCount
		_tgtPath = _networkPath
		_tgtStrCnt = _nwPathCount
	)
	
	if _locToNet == 1 do -- Netw<ork to Local
	(
		_tgtPath = _localPath
		_tgtStrCnt = _lclPathCount
		_srcPath = _networkPath
		_srcStrCnt = _nwPathCount
	)
	
	_tgtStrCntPlusUn = _tgtStrCnt + 1
		
	for i in _bitmapTexture do
	(
		local _filename = i.filename
		local _rootPath = substring _filename 1 _tgtStrCnt
		local _subPath = substring _filename _tgtStrCntPlusUn 9999
		local _newFilePath = _tgtPath + _subPath
		if _rootPath != _srcPath then
		(
			_outOfRange = append _outOfRange i
			_outOfRangePath = append _outOfRangePath i.filename
		)
		else
		(
			_newFilePath = _tgtPath + _subPath
			i.filename = _newFilePath
		)
	)
)


rollout nazboobBTMswitcher "NZB - Bitmap Switcher" width:488 height:208
(
	groupBox _grpPaths "Paths" pos:[8,8] width:472 height:80
	
	label _lblNetworks "NETWORK (master)" pos:[16,27] width:104 height:16
	editText _edtNetworks "" pos:[120,24] width:268 height:24 text:_networkPath bold:true
	button _btnBrowseNetwork "Browse..." pos:[396,24] width:56 height:24
	button _btnReset1 "R" pos:[456,24] width:16 height:24
	
	label _lblLocal "LOCAL (slave)" pos:[16,59] width:80 height:16
	editText _edtLocal "" pos:[120,56] width:268 height:24 text:_localPath bold:true
	button _btnBrowseLocal "Browse..." pos:[396,56] width:56 height:24
	button _btnReset2 "R" pos:[456,56] width:16 height:24
	
	button _btnSync "SYNC (Network to Local)" pos:[8,96] width:472 height:24
	
	groupBox _grpUpdate "Update Materials" pos:[8,128] width:472 height:72
	radioButtons _rdoDirection "" pos:[132,144] width:260 height:16 labels:#("Local to Network", "Network to Local") columns:2
	button _btnUpdate "UPDATE" pos:[16,168] width:376 height:24
	checkbox _chkLog "Display Log" pos:[396,168] width:80 height:24 checked:true
	
	on _btnBrowseNetwork pressed do
	(
		_edtNetworks.text = getSavepath()
	)
	
		on _btnBrowseLocal pressed do
	(
		_edtLocal.text = getSavepath()
	)
	
	on _btnReset1 pressed do
	(
		_edtNetworks.text = _networkPath
	)
	
	on _btnReset2 pressed do
	(
		_edtLocal.text = _localPath
	)

	on _btnSync pressed do
	(
		_FNsync()
	)
	
	on _btnUpdate pressed do
	(
		_localPath = _edtLocal.text
		_networkPath = _edtNetworks.text
		_lclPathCount = _localPath.count
		_nwPathCount = _networkPath.count
		_outOfRange = #()
		if _rdoDirection.state == 2 then 
		(
			-- Network to Local
			_FNswitch 1
		)
		else
		(
			-- Network to Local
			_FNswitch 0
		)
		_compteur = 0
		global _text = ""
		for i in _outOfRange do
		(
			_compteur = _compteur + 1
			u = i as string
			_text = _text + u + " (" + _outOfRangePath[_compteur] + ")" +  "\n"
		)
		
		
		rollout nzboobLogWin "Log" width:536 height:360
		(
			editText edtLog "" pos:[8,32] width:520 height:288 --text:_text
			label lblLog "" pos:[8,8] width:520 height:16
			button btnClose "Close" pos:[8,328] width:520 height:24
			
			on nzboobLogWin open do
			(
				_logLabel =  "Les bitmap suivantes sont hors de \"" + _networkPath + "\""
				lblLog.text = _logLabel
				edtLog.text = _text
			)
			
			
			on btnClose pressed do
			(
				Destroydialog nzboobLogWin
			)
		)
		if _chkLog.state == true do 
		(
			createDialog nzboobLogWin
		)
	)
	
)

createDialog nazboobBTMswitcher
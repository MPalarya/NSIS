; 1. includes

!include MUI2.nsh
;--------------------------------------------------


; 2. defines

!define PRODUCT_NAME	"Scenario Analyzer"
!define PRODUCT_VERSION "0.2a"
!define COMPANY_NAME 	"Elbit Systems Land and C4I"
!define INSTALL_DIR		"$PROGRAMFILES\${COMPANY_NAME}\${PRODUCT_NAME}"
!define APP_URL			"http://localhost:5000/"

Function .onInit
	ReadEnvStr $R0 SYSTEMDRIVE
	!define PYTHON_PATH		"$R0\Python27"
FunctionEnd

Name		 "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile 	 "${PRODUCT_NAME} ${PRODUCT_VERSION} Installer.exe"
InstallDir   "${INSTALL_DIR}"
BrandingText "${COMPANY_NAME}"

!define MUI_ICON	"${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON	"${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
!define MUI_ABORTWARNING
;--------------------------------------------------


; 3. compression

;SetCompressor lzma
;--------------------------------------------------


; 4. pages 

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
	!define MUI_FINISHPAGE_RUN
	!define MUI_FINISHPAGE_RUN_TEXT "Run Server"
	!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
	!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
    !define MUI_FINISHPAGE_SHOWREADME $INSTDIR\readme.txt
	!define MUI_FINISHPAGE_LINK "Launch application in browser"
	!define MUI_FINISHPAGE_LINK_LOCATION "http://localhost:5000"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_DIRECTORY
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
;--------------------------------------------------

 
; 5. install

Section "Python" python
;SectionIn RO
SetOutPath $INSTDIR\Prerequisites
	File Prerequisites\python-2.7.14.msi
	DetailPrint "Launching Python installation..."   
	ExecWait "python-2.7.14.msi" 
	ExecWait '"msiExec" /i "$INSTDIR\Prerequisites\python-2.7.14.msi"' $0
	DetailPrint "Installation finished."
	StrCmp $0 "0" +3 0 ; if equal, installation succeeded, continue(+1)
		DetailPrint "Fail."
		Abort
	DetailPrint "OK."
SectionEnd

Section "Java" java
;SectionIn RO
SetOutPath $INSTDIR\Prerequisites
	File Prerequisites\jre-9.0.1_windows-x64_bin.exe
	DetailPrint "Launching JRE Installation..."
	ExecWait "$INSTDIR\Prerequisites\jre-9.0.1_windows-x64_bin.exe" $0
	DetailPrint "Installation finished."
	StrCmp $0 "0" +3 0 ; if equal, installation succeeded, continue(+1)
		DetailPrint "Fail."
		Abort
	DetailPrint "OK."
SectionEnd

Section "Server Files" server_files
SectionIn RO
	
	WriteUninstaller $INSTDIR\uninstaller.exe

	SetOutPath $INSTDIR
		File /nonfatal /r 					..\APIs
		File /nonfatal /r 					..\Application
		File /nonfatal /r /x data /x logs	..\Database			; exclude data and logs
		File /nonfatal /r 					..\Interface
		File /nonfatal  					..\*.*				; any files inside the main folder

	SetOutPath ${PYTHON_PATH}
		File /nonfatal /r "PythonLibs\"
		
SectionEnd

Section -Shortcuts
SetOutPath $INSTDIR\Interface
	CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\Interface\runAll.bat" "" "$INSTDIR\owl.ico"
SectionEnd
;--------------------------------------------------


; 6. uninstall

Section "un.Server Files" server_files2
SectionIn RO
	Delete $INSTDIR\uninstaller.exe
	Delete $INSTDIR\test.txt
	Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
	RMDir /r $INSTDIR
SectionEnd
;--------------------------------------------------


; 7. components description (components pages)

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${server_files}	"description1"
	!insertmacro MUI_DESCRIPTION_TEXT ${server_files2} 	"description1"
	!insertmacro MUI_DESCRIPTION_TEXT ${python}			"description2"
	!insertmacro MUI_DESCRIPTION_TEXT ${java}			"description3"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
;--------------------------------------------------


; 8. functions

Function un.onUninstSuccess
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
	Abort
FunctionEnd

Function LaunchLink
	ExecShell "" "$DESKTOP\${PRODUCT_NAME}.lnk"
FunctionEnd
;--------------------------------------------------
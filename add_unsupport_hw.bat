@echo off
setlocal EnableExtensions EnableDelayedExpansion

title add unsupported hard ware
echo Welcome to the image creator!
timeout /t 3 /nobreak > nul
cls

set DriveLetter=
set /p DriveLetter=Please enter the drive letter for the Windows 11 image: 
set "DriveLetter=%DriveLetter%:"
echo.
if not exist "%DriveLetter%\sources\boot.wim" (
	echo.Can't find Windows OS Installation files in the specified Drive Letter..
	echo.
	echo.Please enter the correct DVD Drive Letter..
	goto :Stop
)

if not exist "%DriveLetter%\sources\install.wim" (
	echo.Can't find Windows OS Installation files in the specified Drive Letter..
	echo.
	echo.Please enter the correct DVD Drive Letter..
	goto :Stop
)
md c:\w11u
echo Copying Windows image...
xcopy.exe /E /I /H /R /Y /J %DriveLetter% c:\w11u >nul
echo Copy complete!
sleep 2
cls
echo Getting image information:
dism /Get-WimInfo /wimfile:c:\w11u\sources\install.wim
set index=
set /p index=Please enter the image index:
set "index=%index%"
echo Mounting Windows image. This may take a while.
echo.
md c:\scratchdir
dism /mount-image /imagefile:c:\w11u\sources\install.wim /index:%index% /mountdir:c:\scratchdir
echo Mounting complete! Performing registry tweaks...
timeout /t 1 /nobreak > nul
cls

echo Loading registry...
reg load HKLM\zCOMPONENTS "c:\scratchdir\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\zDEFAULT "c:\scratchdir\Windows\System32\config\default" >nul
reg load HKLM\zNTUSER "c:\scratchdir\Users\Default\ntuser.dat" >nul
reg load HKLM\zSOFTWARE "c:\scratchdir\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\zSYSTEM "c:\scratchdir\Windows\System32\config\SYSTEM" >nul
echo Bypassing system requirements(on the system image):
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
echo Enabling Local Accounts on OOBE:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f >nul 2>&1
copy /y %~dp0autounattend.xml c:\scratchdir\Windows\System32\Sysprep\autounattend.xml
echo Disabling Reserved Storage:
Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f >nul 2>&1
echo Tweaking complete!
echo Unmounting Registry...
reg unload HKLM\zCOMPONENTS >nul 2>&1
reg unload HKLM\zDRIVERS >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSCHEMA >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
echo Cleaning up image...
dism /image:c:\scratchdir /Cleanup-Image /StartComponentCleanup /ResetBase
echo Cleanup complete.
echo Unmounting image...
dism /unmount-image /mountdir:c:\scratchdir /commit
echo Exporting image...
Dism /Export-Image /SourceImageFile:c:\w11u\sources\install.wim /SourceIndex:%index% /DestinationImageFile:c:\w11u\sources\install2.wim /compress:max
del c:\w11u\sources\install.wim
ren c:\w11u\sources\install2.wim install.wim
echo Windows image completed. Continuing with boot.wim.
timeout /t 2 /nobreak > nul
cls
echo Mounting boot image:
dism /mount-image /imagefile:c:\w11u\sources\boot.wim /index:2 /mountdir:c:\scratchdir
echo Loading registry...
reg load HKLM\zCOMPONENTS "c:\scratchdir\Windows\System32\config\COMPONENTS" >nul
reg load HKLM\zDEFAULT "c:\scratchdir\Windows\System32\config\default" >nul
reg load HKLM\zNTUSER "c:\scratchdir\Users\Default\ntuser.dat" >nul
reg load HKLM\zSOFTWARE "c:\scratchdir\Windows\System32\config\SOFTWARE" >nul
reg load HKLM\zSYSTEM "c:\scratchdir\Windows\System32\config\SYSTEM" >nul
echo Bypassing system requirements(on the setup image):
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f >nul 2>&1
			Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f >nul 2>&1
echo Tweaking complete! 
echo Unmounting Registry...
reg unload HKLM\zCOMPONENTS >nul 2>&1
reg unload HKLM\zDRIVERS >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSCHEMA >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
echo Unmounting image...
dism /unmount-image /mountdir:c:\scratchdir /commit 
cls
echo the w11u image is now completed. Proceeding with the making of the ISO...
echo Copying unattended file for bypassing MS account on OOBE...
copy /y %~dp0autounattend.xml c:\w11u\autounattend.xml
echo.
echo Creating ISO image...
%~dp0oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,bc:\w11u\boot\etfsboot.com#pEF,e,bc:\w11u\efi\microsoft\boot\efisys.bin c:\w11u %~dp0w11u.iso
echo Creation completed! Press any key to exit the script...
pause 
echo Performing Cleanup...
rd c:\w11u /s /q 
rd c:\scratchdir /s /q 
exit

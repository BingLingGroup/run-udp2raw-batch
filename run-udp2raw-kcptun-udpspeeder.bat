@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

set "remote_ip=change_this_into_your_remote_ip"
set "remote_uk_port=change_this_into_your_remote_udp2raw_for_kcptun_port"
set "remote_uu_port=change_this_into_your_remote_udp2raw_for_udpspeeder_port"
set "local_uk_port=change_this_into_your_local_udp2raw_for_kcptun_port"
set "local_uu_port=change_this_into_your_local_udp2raw_for_udpspeeder_port"
set "local_ss_port=change_this_into_your_local_shadowsocks_server_port"
set "passwd=change_this_into_your_universal_password"

@echo on
start /min udpspeeder -c -l0.0.0.0:%local_ss_port% -r127.0.0.1:%local_uu_port% -k "%passwd%" -f20:20 --timeout 50
start /min udp2raw -c -l127.0.0.1:%local_uu_port% -r%remote_ip%:%remote_uu_port% -k "%passwd%" --raw-mode faketcp --seq-mode 4
start /min kcp_client -l ":%local_ss_port%" -r "127.0.0.1:%local_uk_port%" --key "%passwd%" --crypt "salsa20" --mode manual --nodelay 1 --resend 1 --nc 1 --interval 10
start /min udp2raw -c -l127.0.0.1:%local_uk_port% -r%remote_ip%:%remote_uk_port% -k "%passwd%" --raw-mode faketcp --seq-mode 4
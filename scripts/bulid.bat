@rem  luajit -b init.lua ../script_build/init.lua
@echo off

setlocal enabledelayedexpansion

rd ..\build /S /Q
echo clean Build Dir
for /r "%cd%\" %%i in (.) do (
		set s=%%i
		set s=!s:%~dp0=!
		set s= !s:~0,-1!
		set s2=!s:~1,3!
		::echo s2=!s2!
		if !s2! NEQ  .id ( 
		if !s2! NEQ jit (
			if !s2! NEQ bui (
				mkdir ..\build\!s:~1,-1!
				)
			)
		)
	)

	

 
for /f "tokens=*" %%i in ('dir/s/b *.lua') do (
	set s=%%i
	set s=!s:%~dp0=!
	set s2=!s:~0,3!
	if !s2! NEQ jit  (luajit -b !s! ..\build\!s!) )
:end
echo build Scuess
pause
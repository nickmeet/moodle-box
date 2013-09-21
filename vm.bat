set argument=%1

if "%argument%" == "start" (   
    START VBoxHeadless --startvm moodle-box_default_1379763560 --vrde off
	C:\manual-installations\dev\putty vagrant@172.22.83.237 %= password is vagrant =%
)
if "%argument%" == "check" ( 
	VBoxManage metrics setup --period 1 --samples 5 host CPU/Load,RAM/Usage
	VBoxManage metrics enable
	ping 127.0.0.1 -n 6 -w 1000 > NUL
	VBoxManage metrics query moodle-box_default_1379763560 CPU/Load/User,CPU/Load/Kernel
)
if "%argument%" == "stop" (   
	VBoxManage controlvm moodle-box_default_1379763560 savestate
)

@Echo Off

if [%1]==[] (
    goto :USAGE
)

SET run_file=%~f1
SET run_file_name=%~n1
SET sim_macro=sim_macro.txt
SET sim_output=sim_output_log.txt

IF NOT EXIST %run_file% (
    ECHO %run_file% not found.
    goto :USAGE
)

IF NOT EXIST "execs" (
    mkdir execs
)
IF NOT EXIST "res" (
    mkdir res
)
IF NOT EXIST "tests" (
    ECHO No tests directory.
    goto :eof
)
IF NOT EXIST "sim_macro_in.txt" (
    ECHO sim_macro_in.txt not found.
    goto :eof
)
IF NOT EXIST "sim_macro_out.txt" (
    ECHO sim_macro_out.txt not found.
    goto :eof
)

IF EXIST %sim_macro% (
    del "%sim_macro%"
)

echo Running assembler..
copy "%run_file%" "execs\%run_file_name%".s11 > nul
call as11 "%cd%\execs\%run_file_name%.s11"> nul 2> "execs\%run_file_name%.log" && (echo %run_file% : ASSEMBLER PASSED) || (echo %run_file% : ASSEMBLER FAILED. View execs\%run_file_name%.log for additional details)

del "execs\%run_file_name%.s11"

for %%f in (tests\*.in) do (
    IF EXIST "%cd%\res\%%~nf.out" (
        del "%cd%\res\%%~nf.out"
    )
    
    echo o%cd%\execs\%run_file_name%.o11> "%sim_macro%"
	type sim_macro_in.txt>> "%sim_macro%"
	echo %%~nf.in>> "%sim_macro%"
	type sim_macro_out.txt>> "%sim_macro%"
	echo %%~nf.out>> "%sim_macro%"
	echo Pclk_cycle=200>>"%sim_macro%"
    echo c>> "%sim_macro%"
	echo q>> "%sim_macro%"
	echo y>> "%sim_macro%"
	echo Running simulator..
	sim11 -w -k "%sim_macro%" -s "%sim_output%" || (echo Simulator launching failed. View %sim_output% for additional details)
	del "%sim_macro%"
)


ECHO ------------------------ RESULTS ------------------------
for %%f in (tests\*.in) do (
    call fc "%cd%\res\%%~nf.out" "%cd%\tests\%%~nf.out" > nul 2> nul && (echo Test %%~nf : PASSED) || (echo Test %%~nf : FAILED)
)
goto :eof


:USAGE
ECHO ------------------------ USAGE ------------------------
ECHO Usage: tst4.bat my_prog.s11 
ECHO Written by Elad
ECHO Edited by Uriel
goto :eof
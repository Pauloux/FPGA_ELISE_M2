FPGA projects made during the second year of the ÉLISE Master's program.

To synthetize and load the program into the Red Pitaya, you need to install
everything as described on
https://github.com/master-elise/fpga_tools/tree/872ef5ebb082c328cb7ecc2ec63625131b2e3e2c.
This is the tested version (May 2026). Some project use Vivado to make a
connection between the PL and the PS.

Each project is located its own folder. Each folder can contain two Makefiles,
one for simulation (Makefile.simulation) and one for implementation on the
Red Pitaya (Makefile.openXC7). Some projects are only simulated so they do not
contain Makefile.openXC7.

To choose which Makefile to use, there are two solutions:
- Create a symbolic link with "ln -s <Makefile_name> Makefile". You can then run
	"make <command>" as usual.
- Specify the Makefile name in the command with "make -f <Makefile_name> <command>".

Here are the basic commands you need:
- With Makefile.simulation:
	- make (or make simulation): analyze and elaborate, then run the
		simulation, and finally display the result with GTKWave. If a
		SAVE file (.gtkw) with the same name as the testbench exists,
		then it it displayed. You can select another SAVE file with
		"make SAVE_FILE=<my_save_file.gtkw>". Similarly, you can select
		another testbench file (.vhd) with "make TESTBENCH <testbench_name>"
		WITHOUT extension. You can also change the maximum simulation
		time with "make STOP_TIME=<time>".
	- make elaborate: analyze and elaborate only.
	- make run: analyze and elaborate, then run the simulation. The result is
		NOT displayed.
	- make clean: remove the library file (work-objXX.cf) and the DUMP file
	(containing the simulation results).
- With Makefile.openXC7:
	- make: synthetize the project for the Red Pitaya.
	- make load: synthetize the project and load it in the Red Pitaya.

The project conventions used are listed below:

naming prefix:
c_ : component
g_ : generate
i_ : input
n_ : inverted signal
o_ : output
p_ : process (label)
s_ : signal
t_ : type
v_ : variable

Please write only in English to be consistent.

Use descriptive signal/variable/component/process names. Prefer long names to
short but unreadable ones. Common abbreviations can be used such as "i"
(loop index), "tmp", "freq", etc.

VHDL keyword are in CAPITAL LETTERS. Constant are also in CAPITAL LETTERS

Always define default values for output and signals.

Use tabs for indentation (and not spaces).

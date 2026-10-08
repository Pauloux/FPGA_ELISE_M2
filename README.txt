FPGA projects made during the second year of the ÉLISE Master's program.

To synthesize and load the program into the Red Pitaya, please install
everything as described on
https://github.com/master-elise/fpga_tools/tree/872ef5ebb082c328cb7ecc2ec63625131b2e3e2c.
This is the tested version (May 2026). Some projects use Vivado to make a
connection between the PL and the PS.

Each project is located in its own folder. Each folder can contain two Makefiles,
one for simulation (Makefile.simulation) and one for implementation on the
Red Pitaya (Makefile.openXC7). Some projects are only simulated so they do not
contain Makefile.openXC7.

To choose which Makefile to use, there are two solutions:
- Create a symbolic link with "ln -s <Makefile_name> Makefile". The command
	"make <command>" can then be used as usual.
- Specify the Makefile name in the command with
	"make -f <Makefile_name> <command>".

Here are the basic commands needed:
- With Makefile.simulation:
	- make (or make simulation): analyze and elaborate, then run the
		simulation, and finally display the result with GTKWave.
		
		If a SAVE file (.gtkw) with the same name as the testbench
		exists,	then it is displayed. Another SAVE file can be selected
		with "make SAVE_FILE=<save_file.gtkw>".
		
		The default test bench (.vhd) used for simulation is named 
		"testbench.vhd" and is located in the "testbenches" directory.
		Another test bench file can be selected with
		"make TESTBENCH_FILE=<testbench_file.vhd>".

		The default entity for simulation is named "simulation".
		This name can be changed with
		"make TESTBENCH_ENTITY=<entity_name>".

		If an RC file named ".gtkwaverc" exists in the "testbenches"
		folder, then it is used when GTKWave is launched. Another RC
		file can be selected with "make RC_FILE=<RC_file_name>".

		The maximum simulation duration is defined by the variable
		"STOP_TIME" in the Makefile. The STOP_TIME can be modified for 
		a single run when calling the Makefile with
		"make STOP_TIME=<stop_time>".

	- make elaborate: analyze and elaborate only.

	- make run: analyze and elaborate, then run the simulation. The result
		is NOT displayed with GTKWave.

	- make clean: delete generated files and directories during the
		simulation. All files are generated in the "output" directory.
		In case of a problem, simply delete this directory to restart
		from a clean project.

- With Makefile.openXC7:
	- make: synthesize the project for the Red Pitaya. Please run
		"source /home/jmfriedt/openxc7/export.sh" before running this
		command	(when using the PC of the university).

	- make load: synthesize the project and load it into the Red Pitaya.

	- make verify: analyze and elaborate the project. This is used to check
		for syntax errors without the need to synthesize the project,
		and thus to work on another PC than the PC of the university.
		Warnings can still show up if IBUFDS or BUFG are used, because
		they are not linked yet.

	- make clean: delete generated files and directories during the
		synthesis of the project EXCEPT the CHIP DB directory. This is
		independent of the project. This directory can be manually
		deleted if needed. All other output files are generated in the
		"output" directory. In case of a problem, simply delete this
		directory to restart from a clean project.

The project conventions used are listed below:

Naming prefixes:
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

VHDL keywords are in CAPITAL LETTERS. Constants are also in CAPITAL LETTERS.

Always define default values for outputs and signals.

Use tabs for indentation (and not spaces).

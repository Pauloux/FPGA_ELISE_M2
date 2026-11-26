# ÉLISE Master's program FPGA projects (second year)

> [!WARNING]
> The tools used to synthesize the project for the Red Pitaya have
> recently received an important update. The Makefile.openXC7 probably needs
> to be modified in order to work again.

> [!NOTE]
> This project has been made on Linux and for the Red Pitaya. If you do not use
> Linux, you may need to adapt some things to get these projects running for
> you. Similarly, you can use these projects as you like and port them to other
> boards. Feel free to make a contribution!

# Dependencies

To synthesize and load the program into the Red Pitaya (not needed for
simulation), please install everything as described on
<https://github.com/master-elise/fpga_tools/tree/872ef5ebb082c328cb7ecc2ec63625131b2e3e2c>.
This is the tested version (May 2026).
Some projects use Vivado to make a connection between the PL and the PS.

# File structure

There are 3 main directories:

- `Drivers`, for Linux drivers.
- `Projects`, for VHDL projects.
- `Resources`, for documentation and schematics needed to understand the
projects.

## Drivers

> [!IMPORTANT]
> The Vivado part is not detailed here. You have to connect the PL with the PS
> using `axi_gpio`.

Two Linux drivers have been made for the DDS_AD9834 project. Here is how
to use these drivers:

- Load the DDS_AD9834 project in the PL of the Red Pitaya.
- Compile the driver you want by running `make` in the driver's directory.
- Copy the .ko file that has been generated to the Red Pitaya.
- Insert the module with `insmod <driver_name>.ko`.
- To write a frequency, for example 1 MHz, use
`echo "1000000" > /sys/bus/platform/devices/<device_name>.0/frequency`.
- To read the last written frequency, use
`cat /sys/bus/platform/devices/<device_name>.0/frequency`.
- `Driver_2` can also select the signal waveform. Supported waveforms are
sine (`sin`) and triangle (`trig`). For example, to generate a triangle
waveform, use
`echo "trig" > /sys/bus/platform/devices/<device_name>.0/waveform`.
- To remove the driver once you have finished, use `rmmod <driver_name>.ko`.


## Projects

### General structure

Inside the `Projects` directory, each project is located in its own folder. Each
folder can contain two Makefiles, one for simulation (`Makefile.simulation`) and
one for implementation on the Red Pitaya (`Makefile.openXC7`). Some projects
have only one Makefile, for simulation or for the Red Pitaya synthesis.

### Using the makefiles

#### Selecting a makefile

To choose which Makefile to use, there are two solutions:
- Create a symbolic link with `ln -s <Makefile_name> Makefile`. The command
`make <command>` can then be used as usual.
- Specify the Makefile name in the command with
`make -f <Makefile_name> <command>`.

#### Makefile commands

Here are the basic commands needed:
- With `Makefile.simulation`:
	- `make` (or `make simulation`): analyze and elaborate, then run the
simulation, and finally display the result with GTKWave.
		
		- If a SAVE file (.gtkw) with the same name as the testbench
exists, then it is displayed. Another SAVE file can be selected with
`make SAVE_FILE=<save_file.gtkw>`.
		
		- The default test bench (.vhd) used for simulation is named 
`testbench.vhd` and is located in the `testbenches` directory.
Another test bench file can be selected with
`make TESTBENCH_FILE=<testbench_file.vhd>`.

		- The default entity for simulation is named `simulation`.
This name can be changed with
`make TESTBENCH_ENTITY=<entity_name>`.

		- If an RC file named `.gtkwaverc` exists in the `testbenches`
directory, then it is used when GTKWave is launched. Another RC
file can be selected with `make RC_FILE=<RC_file_name>`.

		- The maximum simulation duration is defined by the variable
`STOP_TIME` in the Makefile. The STOP_TIME can be modified for 
a single run when calling the Makefile with
`make STOP_TIME=<stop_time>`.

	- `make elaborate`: analyze and elaborate only.

	- `make run`: analyze and elaborate, then run the simulation. The result
is NOT displayed with GTKWave.

	- `make clean`: delete generated files and directories during the
simulation. All files are generated in the `output` directory.
In case of a problem, simply delete this directory to restart
from a clean project.

- With `Makefile.openXC7`:
	- `make`: synthesize the project for the Red Pitaya. Please run
`source /home/jmfriedt/openxc7/export.sh` before running this
command (on the university machines).

	- `make load`: synthesize the project and load it into the Red Pitaya.

	- `make verify`: analyze and elaborate the project. This is used to
check for syntax errors without the need to synthesize the
project, and thus to work outside the university. Warnings can still show up if
IBUFDS or BUFG are used, because they are not linked yet.

	- `make clean`: delete generated files and directories during the
synthesis of the project EXCEPT the `CHIP DB` directory. This is
independent of the project. This directory can be manually
deleted if needed. All other output files are generated in the
`output` directory. In case of a problem, simply delete this
directory to restart from a clean project.

# Guidelines

The project guidelines used are listed below:

- Naming prefixes:
	- c_: component
	- g_: generate
	- i_: input
	- n_ (or N_): inverted signal
	- o_: output
	- p_: process (label)
	- s_: signal
	- t_: type
	- v_: variable

- Write code, comments, and documentation in English for consistency.

- Use descriptive signal/variable/component/process names. Prefer long names to
short but unreadable ones. Common abbreviations can be used such as `i`
(loop index), `tmp`, `freq`, etc.

- VHDL keywords are in CAPITAL LETTERS. Constants are also in CAPITAL LETTERS.

- Always define default values for outputs and signals.

- Use tabs for indentation (and not spaces).

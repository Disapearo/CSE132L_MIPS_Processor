CSE 132L MIPS Processor
-----------------------------
Questasim Instructions:
Note: Run all these commands from the root directory (ie where design, verif, sim, and doc are subdirectories).

1. Set up the workspace environment by running the following lines once, whenever you log in:
source setup.csh
source pre_compile.csh

2. In order to compile and simulate the code, run these commands:
vcom -64 -f rtl.cfg
vlog -64 -sv -f tb.cfg
vopt -64 processor_tb +acc=mpr -o processor_tb_opt
vsim -64 -l simulation.log -do sim.do -c processor_tb_opt

3. Finally, use vsim to view the simulation's waveform:
vsim -view sim/waveform.wlf

----------------------------
Notes:
- When using FILE_OPEN in the VHDL code, the path given is relative to the project's root directory.
I assume it works this way because we compile/simulate the code from the root directory.
- sim.do, tb.cfg, and rtl.cfg have been modified with our file structure in mind. E.g. rtl.cfg
looks for the source files in design/
- Make sure to update rtl.cfg when creating/adding source files to the project. Questasim uses this
in order to know what to compile and the order to do it.

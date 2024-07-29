Time Pilot Arcade for the Altera DE2-35 Dev Board.

Notes:
Controls are PS2 keyboard, see readme file in de2 folder for instructions.
Use the included SRAM loader project to load Time Pilot program prom code to DE2 SRAM.

Build:
* Obtain correct roms file for time pilot, see make_time_pilot_proms script in tools/time_pilot_unzip folder for rom filenames.
* Unzip rom files to tools/time_pilot_unzip folder.
* Run the make_time_pilot_proms script in the tools/time_pilot_unzip folder.
* Place generated prom files into proms folder (except the time_pilot_prog.vhd prom file - see below)
* Place the time_pilot_prog.vhd prom file inside the time pilot sram_loader/proms folder (see readme file inside the folder).
* Compile and program the time pilot sram loader project into DE2-35. (see readme file in sram loader folder).
* Open the time-pilot_de2 project file using Quartus and compile.
* Program DE2-35 Board.

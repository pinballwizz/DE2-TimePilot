Procedure:

* Generate time pilot prom files using script in tools/time_pilot_unzip folder.
* Copy the time_pilot_prog.vhd file into the timepilot_sram_loader/prom folder.
* Compile the sram_loader project in quartus.
* Program DE2-35 Board (JTAG). The DE2 SRAM will now contain time pilot prog code.
* 7seg display and green leds can confirm correct hex and binary byte values using switches to select address.
* Without switching off DE2-35, compile the time pilot project in de2 folder and program DE2-35 (JTAG).

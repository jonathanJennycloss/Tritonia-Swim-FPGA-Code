
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { Clk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 5.00 -waveform {0 4} [get_ports { Clk }];


set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L19N_T3_VREF_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { output1 }]; #IO_L23P_T3_35 Sch=led[0]



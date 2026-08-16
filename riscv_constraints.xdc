############################################################
# RISC-V Processor Timing Constraints
############################################################

# 100 MHz clock
# Period = 10 ns
create_clock -name clk -period 10.000 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.2 [get_clocks clk]

############################################################
# Input delays
############################################################

set_input_delay -clock clk 2.0 [get_ports reset]

############################################################
# Reset is asynchronous
############################################################

set_false_path -from [get_ports reset]

############################################################
# Output delays
############################################################

# If your top module has output ports, constrain them here.
# Example:
# set_output_delay -clock clk 2.0 [get_ports some_output]
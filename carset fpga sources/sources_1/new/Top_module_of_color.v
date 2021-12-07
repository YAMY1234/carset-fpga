`timescale 1ns / 1ps

module Top_module_of_color(
input clk,
input frequncy,
output [1:0] filter_select,
output [1:0] frequncy_rate,
output led,
output [9:0] r,g,b
    );
    assign frequncy_rate=2'b10;
    assign led=1'b1;
    
    wire [63:0] r_time,g_time,b_time;
    wire [1:0]filter_balance,filter_identify;
    wire ready;
    white_balance white_balance_init
    (.clk(clk),
    .frequncy(frequncy),
    .R_time(r_time),
    .G_time(g_time),
    .B_time(b_time),
    .ready(ready),
    .filter_select(filter_balance)
    );
 
    identify_color identify_color_init
    (.clk(clk),
    .frequncy(frequncy),
    .ready(ready),
    .r_time(r_time),
    .g_time(g_time),
    .b_time(b_time),
    .filter_select(filter_identify),
    .red(r),
    .green(g),
    .blue(b));
    
    conbine_wire conbine_wire_init
    (.ready(ready)
    ,.filter_select_balance(filter_balance),
    .filter_select_identify(filter_identify)
    ,.filter_select_out(filter_select));
    
    
endmodule
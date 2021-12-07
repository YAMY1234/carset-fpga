`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 14:12:02
// Design Name: 
// Module Name: car_player_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module car_player_top(
    input clk,
    input rst,
    input get_bluetooth,
    //mp3
    output XRSET,
    output XCS,
    output XDCS,
    output SI,
    input SO,
    output SCLK,
    input DREQ,
    //七段数码管部分
    output disp7_dot,
    output [7:0] disp7_shf,
    output [6:0] disp7_odata,
    output [15:0] led,
    output [2:0] led_rgb
    );
    wire [7:0] out_bluetooth;
    bluetooth bt(.clk(clk),.rst(rst),.get(get_bluetooth),.out(out_bluetooth));
    wire up,down,next,prev;//这些东西实在deal里面出来的
    deal_bluetooth mydeal(.clk(clk),.oper(out_bluetooth),.up(up),.down(down),.next(next),.prev(prev));
    
    MP3 mp3(.CLK(clk),.XRSET(XRSET),.XCS(XCS),.XDCS(XDCS),.SI(SI),.SO(SO),.SCLK(SCLK),.DREQ(DREQ),.rst(rst),.next(next),
        .prev(prev),.up(up),.down(down),.disp7_dot(disp7_dot),.disp7_odata(disp7_odata),.led(led),.led_rgb(led_rgb));




/*
module MP3(
input CLK,
output reg XRSET=1,
output reg XCS=1,
output reg XDCS=1,
output reg SI=0,
input SO,
output reg SCLK=0,
input DREQ,
input rst,
input next,
input prev,
input up,
input down,
output disp7_dot,
output [7:0] disp7_shf,
output [6:0] disp7_odata,
output [15:0] led,
output [2:0] led_rgb
*/



endmodule

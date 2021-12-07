`timescale 1ns / 1ps
module change_oper_by_color(
    input rst,
    input [7:0]r,
    input [7:0]g,
    input [7:0]b,
    input clk,
    output reg [7:0]oper
    );
    always@(posedge clk)
    begin
        if(r+g+b<3*241/8/2)oper=8'b00110001;
        else if(r+g+b<3*241*2/8/2)oper=8'b00110010;
        else if(r+g+b<3*241*3/8/2)oper=8'b00110011;
        else if(r+g+b<3*241*4/8/2)oper=8'b00110100;
        else if(r+g+b<3*241*5/8/2)oper=8'b00110101;
        else if(r+g+b<3*241*6/8/2)oper=8'b00110110;
        else if(r+g+b<3*241*7/8/2)oper=8'b00110111;
        else if(r+g+b<3*241*2/8/2)oper=8'b00111000;
        else oper=8'b00000000;
    end
endmodule

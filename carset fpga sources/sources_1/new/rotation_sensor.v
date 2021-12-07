`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/08 01:14:51
// Design Name: 
// Module Name: rotation_sensor
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


module rotation_sensor(
    input clk,
    input rst_n,
    input left,
    input right,
    input BTN,
    output reg[2:0] LED
    );
    always @(posedge clk) begin
        if(left==1)begin
            LED=3'b100;
        end
        else if(right==1)begin
            LED=3'b001;
        end
    end


endmodule


/*

module xuanniu(
input clk,
input rst_n,
input A,
input B,
input BTN,
output [2:0] LED
);

reg clk_10ms;
reg [31:0]count;

reg A_reg,A_reg0;
reg B_reg,B_reg0;
reg BTN_reg,BTN_reg0;
wire A_Debounce;
wire B_Debounce;
wire BTN_Debounce;

reg A_Debounce_reg;
reg B_Debounce_reg;
wire A_pos,A_neg;
wire B_pos,B_neg;

reg rotary_right;
reg rotary_left;

reg rotary_right_reg,rotary_left_reg;
wire rotary_right_pos,rotary_left_pos;
wire rotary_event;

reg [2:0]shift_d;

always@(posedge clk,negedge rst_n)begin
if(!rst_n)begin
count <= 0;
clk_10ms <= 1'b0;
end
else begin
if(count < 32'd24_999)begin//10ms消抖，25MCLK
count <= count + 1'b1;
clk_10ms <= 1'b0;
end
else begin
count <= 0;
clk_10ms <= 1'b1;
end
end
end

always@(posedge clk,negedge rst_n)begin
if(!rst_n)begin
A_reg <= 1'b1;
A_reg0 <= 1'b1;
B_reg <= 1'b1;
B_reg0 <= 1'b1;
BTN_reg <= 1'b0;
BTN_reg0 <= 1'b0;
end
else begin
if(clk_10ms)begin
A_reg <= A;
A_reg0 <= A_reg;
B_reg <= B;
B_reg0 <= B_reg;
BTN_reg <= BTN;
BTN_reg0 <= BTN_reg;
end
end
end

assign A_Debounce = A_reg0 && A_reg && A;
assign B_Debounce = B_reg0 && B_reg && B;
assign BTN_Debounce = BTN_reg0 && BTN_reg && BTN;//消抖后制作脉冲上升沿

always@(posedge clk,negedge rst_n)begin
if(!rst_n)begin
A_Debounce_reg <= 1'b1;
//	B_Debounce_reg <= 1'b1;
end
else begin
A_Debounce_reg <= A_Debounce;
//	B_Debounce_reg <= B_Debounce;
end
end

assign A_pos = !A_Debounce_reg && A_Debounce;
//	assign B_pos = !B_Debounce_reg && B_Debounce;

assign A_neg = A_Debounce_reg && !A_Debounce;
//	assign B_neg = B_Debounce_reg && !B_Debounce;

always@(posedge clk,negedge rst_n)begin
if(!rst_n)begin
rotary_right <= 1'b1;
rotary_left <= 1'b1;
end
else begin
if(A_pos && !B_Debounce)begin//A的上升沿时候如果B为低电平，则旋转编码器是向右转
rotary_right <= 1'b1;
end

if(A_pos && B_Debounce)begin//A上升沿时候如果B为低电平，则旋转编码器是向左转
rotary_left <= 1'b1;
end

if(A_neg && B_Debounce)begin//A的下降沿B为高电平，则向右转结束
rotary_right <= 1'b0;
end

if(A_neg && !B_Debounce)begin//A的下降沿B为低电平，则向左转结束
rotary_left <= 1'b0;
end
end
end

//	assign Rotary_left = rotary_left;
//	assign Rotary_right = rotary_right;
always@(posedge clk,negedge rst_n)begin
if(!rst_n)begin
rotary_right_reg <= 1'b1;
rotary_left_reg <= 1'b1;
end
else begin
rotary_right_reg <= rotary_right;
rotary_left_reg <= rotary_left;
end
end

assign rotary_right_pos = !rotary_right_reg && rotary_right;
assign rotary_left_pos = !rotary_left_reg && rotary_left;//消抖

assign rotary_event = rotary_right_pos || rotary_left_pos;//转动标志位

always@(posedge clk,negedge rst_n)begin
if(!rst_n)
shift_d <= 3'b100;
else if(rotary_event)begin
if(rotary_right_pos)
begin
    case(shift_d)
        3'b011:shift_d=3'b011;
        3'b010:shift_d=3'b011;
        3'b001:shift_d=3'b010;
        3'b100:shift_d=3'b001;
        3'b101:shift_d=3'b100;
        3'b110:shift_d=3'b101;
        3'b111:shift_d=3'b110;
     endcase
end
if(rotary_left_pos)
begin
    case(shift_d)
        3'b011:shift_d=3'b010;
        3'b010:shift_d=3'b001;
        3'b001:shift_d=3'b100;
        3'b100:shift_d=3'b101;
        3'b101:shift_d=3'b110;
        3'b110:shift_d=3'b111;
        3'b111:shift_d=3'b111;
     endcase
end
end
end

assign LED = shift_d;//灯的向左向右的测试模块

endmodule

*/
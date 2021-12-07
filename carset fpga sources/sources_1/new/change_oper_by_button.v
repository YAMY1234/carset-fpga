`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/25 00:11:21
// Design Name: 
// Module Name: change_oper_by_button
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


module change_oper_by_button(
    input clk,
    input [7:0] button,
    input rst,
    output reg [7:0] oper//Êı¾İÊä³ö¶Ë
    );
    always@(posedge clk)
    begin
        if(rst)oper=8'b0;
        else
        begin
            if(button[0]==1)oper=8'b00110001;
            if(button[1]==1)oper=8'b00110010;
            if(button[2]==1)oper=8'b00110011;
            if(button[3]==1)oper=8'b00110100;
            if(button[4]==1)oper=8'b00110101;
            if(button[5]==1)oper=8'b00110110;
            if(button[6]==1)oper=8'b00110111;
            if(button[7]==1)oper=8'b00111000;
            if(button==8'b00000000)oper=8'b00000000;
        end
    end
endmodule

/* if(oper==8'b00110001)//»Ò¶ÈÂË¾µ
        begin
            mid1=(red_mid+green_mid+blue_mid)/3;
            red_mid=mid1;
            green_mid=mid1;
            blue_mid=mid1;
        end
        else if(oper==8'b00110010)//ºÚ°×ÂË¾µ£¨¶şÖµ»¯£©
        begin
            mid1=(red_mid+green_mid+blue_mid)/3;
            if(mid1>=100)
            begin
                red_mid=255;
                green_mid=255;
                blue_mid=255;
            end
            else
            begin
                red_mid=0;
                green_mid=0;
                blue_mid=0;
            end
        end
        else if(oper==8'b00110011)//·´ÏòÂË¾µ£¨µ×Æ¬£©
        begin
            red_mid=255-red_mid;
            green_mid=255-green_mid;
            blue_mid=255-blue_mid;
        end
        else if(oper==8'b00110100)//È¥É«ÂË¾µ
        begin
            mid1=red_mid>green_mid?red_mid:green_mid;
            mid1=mid1>blue_mid?mid1:blue_mid;
            mid2=red_mid<green_mid?red_mid:green_mid;
            mid2=mid1<blue_mid?mid1:blue_mid;
            mid1=(mid1+mid2)/2;
            red_mid=mid1;
            green_mid=mid1;
            blue_mid=mid1;
        end
        else if(oper==8'b00110101)//ÈÛÖıÂË¾µ
        begin
            red_mid=red_mid2*128/(green_mid2+blue_mid2+1);
            green_mid=green_mid2*128/(red_mid2+blue_mid2);
            blue_mid=blue_mid2*128/(red_mid2+green_mid2);
        end
        else if(oper==8'b00110110)//±ù¶³ÂË¾µ
        begin
            red_mid=(red_mid2-green_mid2-blue_mid2)*3/2;
            green_mid=(green_mid2-red_mid2-blue_mid2)*3/2;
            blue_mid=(blue_mid2-red_mid2-green_mid2)*3/2;
        end
        else if(oper==8'b00110111)//Á¬»·»­ÂË¾µ
        begin
            red_mid=(green_mid2-blue_mid2+green_mid2+red_mid2)*red_mid2/256;
            green_mid=(blue_mid2-green_mid2+blue_mid2+red_mid2)*red_mid2/256;
            blue_mid=(blue_mid2-green_mid2+blue_mid2+red_mid2)*green_mid2/256;
        end
        else if(oper==8'b00111000)//»³¾ÉÂË¾µ
        begin
*/


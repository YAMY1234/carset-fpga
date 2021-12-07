`timescale 1ns / 1ps
module rotation_sensor(
    input clk,
    input rst_n,
    input A,
    input B,
    input BTN,
    output rohigh,
    output rodown
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
            rotary_right <= 1'b0;rotary_left <= 1'b0;
            //rotary_right <= 1'b1;rotary_left <= 1'b0;
            end
            if(A_pos && B_Debounce)begin//A上升沿时候如果B为低电平，则旋转编码器是向左转
            // rotary_left <= 1'b1;rotary_right <= 1'b0;
            rotary_left <= 1'b0;rotary_right <= 1'b0;
            end
            if(A_neg && B_Debounce)begin//A的下降沿B为高电平，则向右转结束
            //rotary_right <= 1'b0;rotary_left <= 1'b0;
            rotary_right <= 1'b1;rotary_left <= 1'b0;
            end
            if(A_neg && !B_Debounce)begin//A的下降沿B为低电平，则向左转结束
            // rotary_left <= 1'b0;rotary_right <= 1'b0;
            rotary_left <= 1'b1;rotary_right <= 1'b0;
            end
        end
    end
    assign rohigh=(rotary_left==1?1:0);
    assign rodown=(rotary_right==1?1:0);
endmodule

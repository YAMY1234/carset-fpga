`timescale 1ns / 1ps
module deal_bluetooth2(
    input  wire clk, 
    input [7:0] oper,
    output reg up,
    output reg down,
    output reg sunchange,
    output reg mp3change,
    input vol_dis,
    input mp3mode_dis
    );
    // always @ (posedge clk)
    // begin
    //     up=0;down=0;sunchange=0;mp3change=0;
    //     if(oper==8'b00110011)// sun 3
    //         sunchange=1;
    //     else if(oper==8'b00110100) // mp3 4
    //         mp3change=1;
    //     else if(oper==8'b00110001)//up 5
    //         up=1;
    //     else if(oper==8'b00110010)//down 2
    //         down=1;
    //     else begin
    //         up=0;down=0;sunchange=0;mp3change=0;
    //     end
    // end
    integer up_last;
    integer down_last;
    integer prev_last;
    integer next_last;
    integer sun_change_last;
    integer mp3_change_last;
    parameter delay=10;
    initial begin
        up_last=0;
        down_last=0;
        prev_last=0;
        next_last=0;
        sun_change_last=0;
        mp3_change_last=0;
    end
    
    always @ (posedge clk)
    begin
        up=0;down=0;sunchange=0;mp3change=0;
        if(oper==8'b00000001)begin//1
            up_last=up_last+1;down_last=0;prev_last=0;next_last=0;
            sun_change_last=0; mp3_change_last=0;
            if(up_last>=delay)
                if(!vol_dis)up=1;
            end
        else if(oper==8'b00000010)begin//2
            up_last=0;down_last=down_last+1;prev_last=0;next_last=0;
            sun_change_last=0; mp3_change_last=0;
            if(down_last>=delay)
                if(!vol_dis)down=1;
            end
        else if(oper==8'b00000100)begin//3
            up_last=0;down_last=0;prev_last=0;next_last=0;
            sun_change_last=sun_change_last+1; mp3_change_last=0;
            if(sun_change_last>=delay)
                sunchange=1;
            end
        else if(oper==8'b00001000)begin//4
            up_last=0;down_last=0;prev_last=0;next_last=0;
            sun_change_last=0; mp3_change_last=mp3_change_last+1;
            if(mp3_change_last>=delay)
                if(!mp3mode_dis)mp3change=1;
            end
        else  begin
            up=0;down=0;mp3change=0;sunchange=0;
        end
    end
endmodule

module  divider #(parameter N=100000)(
    input iData,
    output reg oData=0
);
    integer tc=0;
    always @(posedge iData)begin
        if(tc<N/2-1)///这个分频应该是分到了1/50000
            tc<=tc+1;
        else begin
            tc<=0;
            oData<=~oData;
        end
    end
endmodule

module changeinfo (
    input clk,
    input up,
    input down,
    input sunchange,
    input mp3change, 
    output reg [1:0] volum,
    output reg mp3_mode,
    output reg [1:0] sun_mode
);
    initial begin
        volum=0;
        mp3_mode=1;
        sun_mode=0;
    end
    integer voldelay=0;
    always @(negedge clk) begin
        if(voldelay==0) begin
            if(sunchange) begin
                voldelay <= 300000;
                sun_mode=sun_mode+1;
                if(sun_mode==3)sun_mode=0;//改动之后的sun_mode只有三种形式0，1，2 0表示太阳模式，1表示月亮模式，2表示只能模式
            end
            else if(mp3change) begin
                voldelay <= 300000;
                mp3_mode=mp3_mode+1;
            end
            else if(up) begin
                voldelay<=300000;
                if(volum!=3)volum=volum+1;
            end
            else if(down) begin
                voldelay <= 300000;
                if(volum!=0)volum=volum-1;
            end
        end
        else 
            voldelay<=voldelay-1;
    end
endmodule

//deal_blue_link

module deal_blue_link(
    input clk,
    input [7:0] blue_data,
    output [1:0] volum,
    output mp3_mode,
    output [1:0] sun_mode,
    input vol_dis,
    input mp3mode_dis,
    output reg focus
    );
    wire slow_clk,wire_focus;
    divider #(.N(100)) pdivider(.iData(clk),.oData(slow_clk));
    wire up2,down2,mp3change2,sunchange2;
    deal_bluetooth2 mydeal2(.clk(clk),.oper(blue_data),.up(up2),.down(down2),.mp3change(mp3change2),.sunchange(sunchange2),.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis));
    changeinfo mychange(.clk(slow_clk),.volum(volum),.mp3_mode(mp3_mode),.sun_mode(sun_mode),.up(up2),.down(down2),.mp3change(mp3change2),.sunchange(sunchange2));
    integer delay;
    initial begin
        focus=0;
        delay=10000000;
    end
    always @(posedge clk) begin
        if(delay<=10)begin
            if(blue_data==8'b01000000)begin
                focus=~focus;
                delay=10000000;
            end
        end
        delay=delay-1;
    end


endmodule
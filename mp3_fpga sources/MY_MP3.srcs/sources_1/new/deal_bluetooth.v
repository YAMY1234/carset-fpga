`timescale 1ns / 1ps

module deal_bluetooth(
    input  wire clk, 
    input [7:0] oper,
    output reg up,
    output reg down,
    output reg prev,
    output reg next,
    inout mp3change,
    output reg sunchange
    );
    assign mp3change=temp_mp3change;
    reg temp_mp3change;

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
        up=0;down=0;prev=0;next=0;
        if(oper==8'b00000001)//up 5 出现问题，会被自动感应成1（next！！！）
            begin
            up_last=up_last+1;down_last=0;prev_last=0;next_last=0;
            sun_change_last=0; mp3_change_last=0;
            if(up_last>=delay)
                up=1;
            end
        else if(oper==8'b00000010)begin
            up_last=0;down_last=down_last+1;prev_last=0;next_last=0;
            sun_change_last=0; mp3_change_last=0;
            if(down_last>=delay)
                down=1;
            end
        else if(oper==8'b00000100)begin//sun 3
            up_last=0;down_last=0;prev_last=0;next_last=0;
            sun_change_last=sun_change_last+1; mp3_change_last=0;
            if(sun_change_last>=delay)
                sunchange=1;
            end
        else if(oper==8'b00001000)begin
            up_last=0;down_last=0;prev_last=0;next_last=0;
            sun_change_last=0; mp3_change_last=mp3_change_last+1;
            if(mp3_change_last>=delay)
                temp_mp3change=1;
            end
        else if(oper==8'b00010000)begin//5 next
            up_last=0;down_last=0;prev_last=0;next_last=next_last+1;
            sun_change_last=0; mp3_change_last=0;
            if(next_last>=delay)
                next=1;
            end
        else if(oper==8'b00100000)begin//7 prev
            up_last=0;down_last=0;prev_last=prev_last+1;next_last=0;
            sun_change_last=0; mp3_change_last=0;
            if(prev_last>=delay)
                prev=1;
            end
        else  begin
            up=0;down=0;prev=0;next=0;temp_mp3change=0;sunchange=0;
        end
    end
endmodule

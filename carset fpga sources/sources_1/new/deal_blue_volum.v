`timescale 1ns / 1ps


module deal_blue_volum(
    input indata,
    output reg [1:0]outdata,
    output reg [3:0]outSong,
    input  clk
    );
    integer delay=100000000;
    initial begin
       outdata=3;
       outSong=1;
    end
    always @(posedge clk) begin
        delay=delay-1;
        if(outdata!=0&&delay<=10)begin
            if(indata==8'b00110010)begin
                outdata=outdata-1;
                delay=100000000;
            end
        end
        if(outdata!=3&&indata==8'b00110001&&delay<-10)begin
            outdata=outdata+1;
            delay=100000000;
        end
        if(delay<=10&&indata==8'b00110011)begin
            outSong=outSong-1;
            if(outSong==0)outSong=4'd7;
            delay=100000000;
        end
        if(delay<=10&&indata==8'b00110100)begin
            outSong=outSong+1;
            if(outSong==9)outSong=4'd0;
            delay=100000000;
        end
    end
endmodule

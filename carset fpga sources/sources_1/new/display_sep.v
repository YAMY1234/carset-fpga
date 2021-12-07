`timescale 1ns / 1ps
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

module display_sep(//最新的7段数码管展示
    input [31:0] iData,
    input clk,
    output reg [6:0] oData,
    output reg [7:0] shf=8'b01111111
    );
    reg [5:0] shr=0;
    wire [31:0] showdata;
    assign showdata[31:16]=iData[31:16];
    wire clkt;
    divider #(.N(200))pdivider(.iData(clk),.oData(clkt));//这个是每秒钟的东西了   本来是200000的 
    always @(posedge clkt)
        begin
            shf<={shf[6:0],shf[7]};
            shr<=shr+4;//这个是拿来干嘛的，我是不太清楚这个shr+4这个是用来干嘛的
            case({showdata[shr+3],showdata[shr+2],showdata[shr+1],showdata[shr]})
            4'b0000:oData<=7'b1000000;
            4'b0001:oData<=7'b1111001;
            4'b0010:oData<=7'b0100100;
            4'b0011:oData<=7'b0110000;
            4'b0100:oData<=7'b0011001;
            4'b0101:oData<=7'b0010010;
            4'b0110:oData<=7'b0000010;
            4'b0111:oData<=7'b1111000;
            4'b1000:oData<=7'b0000000;
            4'b1001:oData<=7'b0010000;
            default:oData<=7'b1111111;
            endcase
        end
endmodule

`timescale 1ns / 1ps


module conbine_wire(
input ready,
input [1:0]filter_select_balance,
input [1:0]filter_select_identify,
output  reg [1:0] filter_select_out
    );
    always@(*)
    begin
        if(!ready)
        begin
            filter_select_out = filter_select_balance;       
        end
        else
        begin
         filter_select_out = filter_select_identify;       
        end
    end
    
    
endmodule


`timescale 1ns / 1ps
module  divider #(parameter N=100000)(
    input iData,
    output reg oData=0
);
    integer tc=0;
    always @(posedge iData)begin
        if(tc<N/2-1)///�����ƵӦ���Ƿֵ���1/50000
            tc<=tc+1;
        else begin
            tc<=0;
            oData<=~oData;
        end
    end
endmodule

//���Ӧ�����������ڵ�
module inputvol(
    input clk,
    input up2,
    input up,
    input up3,
    input down2,
    input down,
    input down3,
    output reg [15:0]vol=16'h0000
    );
    integer voldelay=0;
    always @(negedge clk) begin
        if(voldelay==0) begin
            if(up||up2||up3) begin
                voldelay<=100000;
                vol<=(vol==16'h0000)?16'h0000:(vol-16'h1010);
            end
            else if(down||down2||down3) begin
                voldelay <= 100000;
                vol<=(vol==16'hf0f0)?16'hf0f0:(vol+16'h1010);
            end
        end
        else 
            voldelay<=voldelay-1;
    end
endmodule

//sw��ʲô����
module inputsw(
    input clk,
    input prev2,
    input prev,
    input next2,
    input next,
    input [1:0]force_change,
    input [2:0]remember_sw,
    output reg [2:0]sw=0
    );
    integer swdelay=0;
    reg [1:0]temp_change;
    always @(negedge clk) begin
        temp_change=force_change;
        if(swdelay==0) begin
            if(prev||prev2) begin
                swdelay<=500000;
                sw<=sw-1;
            end
            else if(next||next2) begin
                swdelay <= 500000;
                sw<=sw+1;
            end
        end
        else 
            swdelay<=swdelay-1;
        if(force_change==2'b01)begin//��ͻȻ�뵽ֱ���ñ��ص���ʽ�Ϳ��Ա���ܶ������ѽ������ô��ôɵѽ
            sw<=3'b111;
        end
        else if(force_change==2'b10)begin//������ġ�������d'd
            sw<=remember_sw;
        end
    end
endmodule


module mustime(
    input clk,
    input rst,
    output reg [15:0] timet=0
    );
    integer timesc=0;
    always @(negedge clk) begin
        if(rst)begin
            timesc<=0;
            timet<=0;
        end
        else begin
            if(timesc<999999)
                timesc<=timesc+1;
            else begin
                timesc<=0;
                timet<=timet+1;
            end
        end
    end
endmodule

module BLUE_MP3(
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
    //����ܽӿ�
    // output [6:0] display,//��Ӧ����ܽӿ�
    output [15:0] led,
    output [2:0] led_rgb,
    //����
    input get_bluetooth,
    //����
    output blue_link,
    input iA,
    input iB,
    input SW,

    input alarm_sig//�������alarm_signal
    );
    wire [15:0] data1;
    wire [15:0] data2;//����
    reg [15:0] data;
    reg [15:0] pos=0;
    reg [9:0] pos2=0;//����
    wire clk;
    divider #(.N(100)) pdivider(.iData(CLK),.oData(clk));
    //���ڴ�д��CLK���з�Ƶ ԭ����100 MHZ�� 100 00 0000 ��Ϊ ������50 0000
    reg [127:0] initar={32'h02000804,32'h02000804,32'h020B0000,32'h020000800};
    reg [127:0]ar={32'h02000804,32'h02000804,32'h020B0000,32'h020000800};

    integer i=0;//���ﶨ������i��ʲô��˼��
    integer cmdcounter=0;
    //reg flag=1;
    //reg [63:0]test={32'h53ef6e07,32'h00000000};
    parameter maxcmd=4;
    assign led=data1;
    wire [15:0] timet;
    mustime ptime(.clk(clk),.rst(pos[14:0]==0),.timet(timet));
    reg [31:0] nextcmd;
    reg [2:0] presw=0;
    reg [2:0] remember_sw;
    wire [2:0] sw;
    reg [1:0]force_change;
    reg pre_sig;
    initial begin
        pre_sig=0;
    end
    /*
    �����һֱ��1�Ͳ��У����ǰ��ĺͺ���Ĳ�һ���˲��У�Ҳ���Ǵ���һ��pre=0����now=1ʱ����rst����now��pre����ȵ�ʱ��rst=0
    */
    integer delay;
    initial begin
        delay=1000;
        remember_sw=3'b000;
    end

    // always @(clk) begin
    //     force_change=2'b00;
    //     if(delay<=10)begin
    //         if((count%2==0)&&alarm_sig==1)begin//��ʵ������һ�£�����ط�����ֱ����always@(posedge pre_sig or negadge pre_sig)����ķ�ʽ��Ū�������ͼ򵥺ܶ�ѽ�����һ������׳���
    //             force_change=2'b01;
    //             remember_sw=sw;
    //             delay=1000;
    //             count=count+1;
    //         end
    //         else if((count%2==1)&&alarm_sig==0)begin
    //             force_change=2'b10;
    //             delay=1000;
    //             count=count+1;
    //         end
    //     end
    //     else delay=delay-1;
    // end
    // always @(alarm_sig) begin
    //     force_change=2'b00;
    //         if(alarm_sig==1)begin//��ʵ������һ�£�����ط�����ֱ����always@(posedge pre_sig or negadge pre_sig)����ķ�ʽ��Ū�������ͼ򵥺ܶ�ѽ�����һ������׳���
    //             force_change=2'b01;
    //             remember_sw=sw;
    //         end
    //         else if(alarm_sig==0)begin
    //             force_change=2'b10;
    //         end
    // end

    always @(posedge clk) begin
        if(alarm_sig!=pre_sig)begin
            force_change<=2'b00;
            if(alarm_sig==1)begin//��ʵ������һ�£�����ط�����ֱ����always@(posedge pre_sig or negadge pre_sig)����ķ�ʽ��Ū�������ͼ򵥺ܶ�ѽ�����һ������׳���
                force_change<=2'b01;
                remember_sw<=sw;
            end
            else if(alarm_sig==0)begin
                force_change<=2'b10;
            end
        end
        if(force_change!=2'b00)begin
            if(delay>=10)
                delay<=delay-1;
            else begin
                delay<=1000;
                force_change<=2'b00;
            end
        end
        pre_sig<=alarm_sig;
    end
    

/************************************************************************************/

    wire [7:0] out_bluetooth;
    bluetooth bt(.clk(CLK),.rst(0),.get(get_bluetooth),.out(out_bluetooth));
    wire up2,down2,next2,prev2;//��Щ����ʵ��deal���������
    wire rst_blue;
    deal_bluetooth mydeal(.clk(clk),.oper(out_bluetooth),.up(up2),.down(down2),.next(next2),.prev(prev2),.mp3change(rst_blue));
    assign blue_link=get_bluetooth;
//��ת������
    wire up3,down3;
    rotation_sensor rs(.clk(CLK),.rst_n(1),.A(iA),.B(iB),.rohigh(up3),.rodown(down3));

/***************************************************************************************/

    //��������ǲ�ͬ�ĸ���
    inputsw pinsw(.clk(clk),.prev(prev),.next(next),.prev2(prev2),.next2(next2),.sw(sw),.force_change(force_change),.remember_sw(remember_sw));
    wire [15:0] vol;
    inputvol pinvol(.clk(clk),.up(up),.up2(up2),.down(down),.down2(down2),.down3(down3),.up3(up3),.vol(vol));

    // new_display7 dis(.iData({{up}{down}{up3}{down3}}),.oData(display));
    // display7 pdisp7(.iData({13'b0,sw[2:0],timet[15:0]}),.clk(CLK),.oData(disp7_odata),.shf(disp7_shf),.dot(disp7_dot));
    display7 pdisp7(.iData({3'b0,up3,3'b0,down3,5'b0,sw[2:0],timet[15:0]}),.clk(CLK),.oData(disp7_odata),.shf(disp7_shf),.dot(disp7_dot));
    disprgb prgb(.clk(clk),.led(led),.rst(XRSET),.rgb(led_rgb));

    blk_mem_gen_0 p(.clka(CLK),.ena(1),.addra({sw[2:0],pos[14:0]}),.douta(data1));//����ĵ�ַλ18λ���������û��ʲô̫�������
    Alarm alarm(.clka(CLK),.ena(1),.addra({pos2[9:0]}),.douta(data2));

    //�����sw�൱�ھ��Ǹ����ĵ�ַ���Ҹ������sw���е��ھͿ����ˣ�����Ǹ��Ƚ�С������
    //ǰ��������Ƕ�Ӧ��sw�������15λ�൱�ھ��Ǹ����������Ϣ�ˣ����Ǹо������Ӵ洢������һ���˷ѿռ䣬���ȿ�һ�°�
    integer stat=0;
    always @(posedge clk) begin
        presw<=sw;
    if(~rst||rst_blue|| presw!=sw) begin
        XRSET<=0;
        cmdcounter<=0;
        stat<=4;
        ar<=initar;
        SCLK<=0;
        XCS<=1;
        XDCS<=1;
        i<=0;
        pos<=0;
        pos2<=0;
    end
    else begin
        case(stat)//���statӦ�ø����������Ǹ�STATU��һ��
        0:begin
            SCLK<=0;
            if(cmdcounter>=maxcmd)
                stat<=2;
            else if(DREQ) begin
                XCS<=0;
                i<=1;
                stat<=1;
                SI<=ar[127];
                ar<={ar[126:0],ar[127]};
            end
        end
        
        1:begin
            if(DREQ) begin
                if(SCLK) begin
                    if(i<32)begin
                        i<=i+1;
                        SI<=ar[127];
                        ar<={ar[126:0],ar[127]};
                    end
                    else begin
                        XCS<=1;
                        i<=0;
                        cmdcounter<=cmdcounter+1;
                        stat<=0;
                    end
                end
                SCLK<=~SCLK;
            end
        end
        2:begin
            if(vol[15:0]!=initar[47:32]) begin
                stat<=5;
                nextcmd<={16'h020B,vol[15:0]};
            end
            else if(DREQ) begin
                XDCS<=0;
                SCLK<=0;
                stat<=3;
                data<={data1[14:0],data1[15]};//������Ǿ���������������
                SI<=data1[15];
                i<=1;
            end
            initar[47:32]<=vol;
        end
        
        3:begin 
            if(SCLK)begin
                if(i<16)begin
                    i<=i+1;
                    SI<=data[15];
                    data<={data[14:0],data[15]};
                end
                else begin
                    XDCS<=1;
                    pos<=pos+1;
                    stat<=2;
                end
            end
            SCLK<=~SCLK;
        end
        
        4:begin
            if(i<1000000)//�����һ��reset�Ĳ���
                i<=i+1;
            else begin
                i<=0;
                stat<=0;
                XRSET<=1;
            end
        end
        5:begin
            if(DREQ) begin
                XCS<=0;
                i<=1;
                stat<=6;
                SI<=nextcmd[31];
                nextcmd<={nextcmd[30:0],nextcmd[31]};
            end
        end
        6:begin
            if(DREQ) begin
                if(SCLK) begin
                    if(i<32)begin
                        i<=i+1;
                        SI<=nextcmd[31];
                        nextcmd<={nextcmd[30:0],nextcmd[31]};
                    end
                    else begin
                        XCS<=1;
                        i<=0;
                        stat<=2;
                    end
                end
                SCLK<=~SCLK;
            end
        end
        default:
            ;
        endcase
    end
end
endmodule
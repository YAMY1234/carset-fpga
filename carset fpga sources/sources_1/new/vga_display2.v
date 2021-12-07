`timescale 1ns / 1ps
module vga_display2(
    input clk_vga,//����vga��ʱ�ӣ�Ƶ��Ϊ25.175MHz
    input rst,//��λ�źţ��ߵ�ƽ��Ч
    input [11:0] color_data_in,//��RAM�ж�ȡ��������Ϣ
    /******************************************/
    input [11:0]rom_data_in,
    output reg[18:0] rom_addr, 
    output reg[18:0] ram_addr,//Ӧ�ö�ȡ��RAM��ͼƬ��ַ����vga_control����
    output x_valid,
    output y_valid,
    output reg[3:0] red,
    output reg[3:0] blue,
    output reg[3:0] green,
    //�����Ӳ���
    input [3:0] L_sec,
    input [3:0] H_sec,
    input [3:0] L_min,
    input [3:0] H_min,
    input [3:0] L_hour,
    input [3:0] H_hour,     //���������������
    //�Լ��˲�����
    input addup,
    input turndown,
    input [2:0]rgbpos,
    //�����ҹģʽ
    input [1:0] voice,
    input [1:0]sun_mode,
    input Mp3_mode,
    input vol_dis,
    input mp3mode_dis,
    input sun_change_info,
    input focus
);
//dis�й�
    reg [1:0] pre_voice;
    reg [1:0] pre_mp3_mode;
    parameter x_before=11'd144;
    parameter y_before=11'd35;
    parameter x_size_pic=11'd640;
    parameter y_size_pic=11'd480;

//����������ʾ��������λ����ʾ
    parameter x_graph=11'd144+11'd45;
    parameter y_graph=11'd135+11'd35;

    wire [11:0] x_poi;//�����ʱx������
    wire [11:0] y_poi;//�����ʱy������
    wire is_display;//������ʱ�Ƿ��ܹ����
//�������й�
    reg [3:0] temp_num;//������
    reg [3:0] temp_voice;
    reg [5:0] x_locate, y_locate, voice_x_locate, voice_y_locate, mp3_x_locate, mp3_y_locate,mode_x_locate,mode_y_locate;//
    parameter colon = 10, blank = 12, point = 11;   //ð����հ�
//������ʾ�豸�й�
    parameter x_voice_begin=340;
    parameter x_voice_end=x_voice_begin+48;
    parameter y_voice_begin=400;
    parameter y_voice_end=y_voice_begin+48;
//mp3״̬�й�
    parameter x_mp3_begin=180;
    parameter x_mp3_end=x_mp3_begin+48;
    parameter y_mp3_begin=400;
    parameter y_mp3_end=y_mp3_begin+48;
//ֻ��ģʽ/̫��ģʽ/����ģʽ�л�
    parameter x_mode_begin=500;
    parameter x_mode_end=x_mode_begin+48;
    parameter y_mode_begin=400;
    parameter y_mode_end=y_mode_begin+48;    
//̫��������ʾ�й�
    parameter pic_len=40*2;
    parameter x_day_begin=640-pic_len-100;
    parameter x_day_end=640-100;
    parameter y_day_begin=100;
    parameter y_day_end=100+pic_len;
//�����Ӽ�����ģ���йر�������
    reg [9:0] base_addr;        //���ڶ�ȡ��Ӧλ������ģcoe�ļ���������
    reg [9:0] voice_base_addr;
    wire [8:0] addra;
    wire [8:0] addr_voice;
    assign addra = base_addr + y_locate;      //��λ��һ�������������е����ص㣬��������
    assign addr_voice = voice_base_addr + voice_y_locate;
    wire [15:0] douta;
    wire [47:0] dout_voice;

    parameter number_begin=x_graph+x_size_pic/2+11'd50;//���������ʱ���õ����ˣ���Ϊ�Ѿ���x_begin������ȥ��
    parameter delta_x=16;
    parameter y_number_begin=200;
    parameter y_number_end=y_number_begin+31;
//������������ģ
    Character character_uut
    (
    .clka(clk_vga), 
    .addra(addra), 
    .douta(douta), //��ȡÿ�����ֵ�16λһ�е�����
    .ena(1)
    );
//������ģ
    reg [8:0]my_voice_addr;
    wire [47:0] my_out;
    Voice2 v
    (
    .clka(clk_vga), 
    .addra(my_voice_addr), 
    .douta(my_out), //��ȡÿ�����ֵ�48λһ�е�����
    .ena(1)
    );
//̫������ͼģ
    reg [14:0] day_addr;//̫���������ĵ�ַ
    wire [11:0]day_out;
    Day day(.clka(clk_vga), 
    .addra(day_addr), 
    .douta(day_out), //��ȡÿ�����ֵ�48λһ�е�����
    .ena(1));
//mp3״̬ģ
    reg [8:0]my_mp3_addr;
    wire [47:0] my_mp3_out;
    MP3_mode mp3
    (
    .clka(clk_vga), 
    .addra(my_mp3_addr), 
    .douta(my_mp3_out), //��ȡÿ�����ֵ�48λһ�е�����
    .ena(1)
    );
//�����ҹģʽģ��
    // reg [8:0]my_mode_addr;
    // wire [47:0]my_mode_out;
    // Sun_mode sun
    // (
    // .clka(clk_vga), 
    // .addra(my_mode_addr), 
    // .douta(my_mode_out), //��ȡÿ�����ֵ�48λһ�е�����
    // .ena(1)
    // );
//�������ڱ�������
    /********************�ֶ����ڱ���ͼƬrgb��ɫ�İ�ť����**********************/
    reg [3:0]r_add;reg[3:0]g_add;reg[3:0]b_add;
    reg [3:0]r_down;reg[3:0]g_down;reg[3:0]b_down;
    integer delay;
    initial begin
        delay=10000000;
        r_add=8;g_add=8;b_add=8;
    end
    always @(posedge clk_vga) begin
        delay=delay-1;
        if(addup&&delay<=10&&r_add!=15)begin
            if(rgbpos[0]&&r_add!=15)r_add=r_add+1;
            if(rgbpos[1]&&g_add!=15)g_add=r_add+1;
            if(rgbpos[2]&&b_add!=15)b_add=r_add+1;
            delay=10000000;
        end
        else if(turndown&&delay<=10&&r_add!=0)begin
            if(rgbpos[0]&&r_add!=0)r_add=r_add-1;
            if(rgbpos[1]&&g_add!=0)g_add=r_add-1;
            if(rgbpos[2]&&b_add!=0)b_add=r_add-1;
            delay=10000000;
        end
    end
    // wire [15:0] douta_initial;
    // assign douta_initial = douta << x_locate;     //ÿ����Χ�ڵĵ�ַ����ӳ�䵽��Ե�ַ��Ȼ���������������λ�õ����λ�����Ǹõ��rgbֵ
    assign num = douta[15-x_locate];
    assign voice_num = dout_voice[47-voice_x_locate];

    //����������ģʱ�䣺
    vga_control control(clk_vga,rst,x_poi,y_poi,is_display,x_valid,y_valid);
    always@ (*)
    begin
        red=0;
        blue=0;
        green=0;
        if(focus&&is_display)
        begin
            if(x_poi-x_before<=x_size_pic&&y_poi-y_before<=y_size_pic)
            begin
                ram_addr=(y_poi-y_before)*x_size_pic+(x_poi-x_before);
                red=color_data_in[11:8];
                green=color_data_in[7:4];
                blue=color_data_in[3:0];
            end
            else
            begin
                red=0;
                green=0;
                blue=0;
            end
        end
        else if(is_display)
        // if(is_display)
        begin
            if(x_poi-x_before<=x_size_pic&&y_poi-y_before<=y_size_pic)
            begin
                if(x_poi-x_graph<=x_size_pic/2&&y_poi-y_graph<=y_size_pic/2&&x_poi>x_graph&&y_poi>y_graph)
                begin
                    ram_addr=(y_poi-y_graph)*x_size_pic*2+(x_poi-x_graph)*2;
                    red=color_data_in[11:8];
                    green=color_data_in[7:4];
                    blue=color_data_in[3:0];
                end
                else 
                begin
                    rom_addr=((y_poi-y_before)/2)*(x_size_pic/2)+(x_poi-x_before)/2;
                    red=rom_data_in[11:8];
                    green=rom_data_in[7:4];
                    blue=rom_data_in[3:0];
                    if(r_add+red-8<=15&&r_add+red-8>=0)red=r_add-8+red;
                    else if(r_add+red-8>15)red=15;
                    else if(r_add+red-8<0)red=0;
                    if(g_add-8+green<=15&&g_add-8+green>=0)green=g_add-8+green;
                    else if(g_add-8+green>15)green=15;
                    else if(g_add-8+green<0)green=0;
                    if(b_add-8+blue<=15&&b_add-8+blue>=0)blue=b_add-8+blue;
                    else if(b_add-8+blue>15)blue=15;
                    else if(b_add-8+blue<0)blue=0;
                    //ʱ����ʾ����
                    if(y_poi-y_before>= y_number_begin && y_poi-y_before <= y_number_end&&x_poi<number_begin+delta_x*12&&x_poi >= number_begin)//��ʾʱ��ķ�Χ
                    begin
                        y_locate = y_poi-y_before-y_number_begin;//x��ʼ��ʱ����368��������ʱ����544������ʵ��559��
                        if(x_poi >= number_begin  && x_poi < number_begin+delta_x)  begin
                            temp_num = H_hour;
                            x_locate  = x_poi - (number_begin);  
                        end
                        else if(x_poi >= number_begin+delta_x  && x_poi < number_begin+delta_x*2)  begin
                            temp_num = L_hour;
                            x_locate  = x_poi - (number_begin+delta_x);  
                        end
                        else if(x_poi >= number_begin+delta_x*2 && x_poi < number_begin+delta_x*3)  
                        begin
                            temp_num = blank;
                            x_locate  = x_poi - (number_begin+delta_x*2);  
                        end
                        else if(x_poi >= number_begin+delta_x*3 && x_poi < number_begin+delta_x*4)  
                        begin
                            temp_num = colon;
                            x_locate  = x_poi - (number_begin+delta_x*3);  
                        end
                        else if(x_poi >= number_begin+delta_x*4  && x_poi < number_begin+delta_x*5)  
                        begin
                            temp_num = blank;
                            x_locate  = x_poi - (number_begin+delta_x*4);  
                        end
                        else if(x_poi >= number_begin+delta_x*5  && x_poi < number_begin+delta_x*6)  
                        begin
                            temp_num = H_min;
                            x_locate  = x_poi - (number_begin+delta_x*5);  
                        end
                        else if(x_poi >= number_begin+delta_x*6 && x_poi < number_begin+delta_x*7)  
                        begin
                            temp_num = L_min;
                            x_locate  = x_poi - (number_begin+delta_x*6);  
                        end
                        else if(x_poi >= number_begin+delta_x*7  && x_poi < number_begin+delta_x*8)  
                        begin
                            temp_num = blank;
                            x_locate  = x_poi - (number_begin+delta_x*7);  
                        end
                        else if(x_poi >= number_begin+delta_x*8  && x_poi < number_begin+delta_x*9)  
                        begin
                            temp_num = colon;
                            x_locate  = x_poi - (number_begin+delta_x*8);  
                        end
                        else if(x_poi >= number_begin+delta_x*9 && x_poi < number_begin+delta_x*10)  
                        begin
                            temp_num = blank;
                            x_locate  = x_poi - (number_begin+delta_x*9);  
                        end
                        else if(x_poi >= number_begin+delta_x*10 && x_poi < number_begin+delta_x*11)  
                        begin
                            temp_num = H_sec;
                            x_locate  = x_poi - (number_begin+delta_x*10); 
                        end
                        else if(x_poi >= number_begin+delta_x*11 && x_poi < number_begin+delta_x*12)  
                        begin
                            temp_num = L_sec;
                            x_locate  = x_poi - (number_begin+delta_x*11);  
                        end
                        else 
                        begin
                            temp_num = blank;
                            x_locate = 0;  
                        end
                        //if(num!=0&&y_poi-y_before >= y_number_begin && y_poi-y_before <= y_number_end&&x_poi<number_begin+delta_x*12&&x_poi >= number_begin)begin
                        if(num!=0)begin
                            red={4{num}};
                            green={4{num}};
                            blue={4{num}};
                            //base_addr=temp_num*32;
                        end
                    end
                    //voice
                    if(y_poi-y_before>=y_voice_begin&&y_poi-y_before<y_voice_end)
                    begin
                        if(x_poi-x_before >= x_voice_begin  && x_poi-x_before <x_voice_end)begin
                            voice_x_locate  = x_poi - x_voice_begin-x_before;
                            my_voice_addr=y_poi-y_voice_begin-y_before+pre_voice*48;//��������ط�Ϊʲô����һ��34��ƫ��������Ĳ�֪��������
                            if(my_out[47-voice_x_locate]!=1)begin
                                red={4{my_out[47-voice_x_locate]}};
                                green={4{my_out[47-voice_x_locate]}};
                                blue={4{my_out[47-voice_x_locate]}};
                            end
                        end
                    end
                    if(y_poi-y_before>=y_mp3_begin&&y_poi-y_before<y_mp3_end)
                    begin
                        if(x_poi-x_before >= x_mp3_begin  && x_poi-x_before <x_mp3_end)begin
                            mp3_x_locate  = x_poi - x_mp3_begin-x_before;
                            my_mp3_addr=y_poi-y_mp3_begin-y_before+pre_mp3_mode*48;//��������ط�Ϊʲô����һ��34��ƫ��������Ĳ�֪��������
                            if(my_mp3_out[47-mp3_x_locate]!=1)begin
                                red={4{my_mp3_out[47-mp3_x_locate]}};
                                green={4{my_mp3_out[47-mp3_x_locate]}};
                                blue={4{my_mp3_out[47-mp3_x_locate]}};
                            end
                        end
                    end
                    if(y_poi-y_before>=y_mode_begin&&y_poi-y_before<y_mode_end)
                    begin
                        if(x_poi-x_before >= x_mode_begin  && x_poi-x_before <x_mode_end)begin
                            mode_x_locate  = x_poi - x_mode_begin-x_before;
                            mode_y_locate  = y_poi - y_mode_begin-y_before;
                            if((mode_x_locate>=mode_y_locate/2&&mode_x_locate<=mode_y_locate+5&&mode_x_locate<24)
                            ||(mode_x_locate<=48-mode_y_locate/2&&mode_x_locate>=48-mode_y_locate-5&&mode_x_locate>=24))begin
                                if((((mode_x_locate<=mode_y_locate/2+2)||(mode_x_locate>=mode_y_locate+5-2))&&mode_x_locate<24)||(((mode_x_locate>=48-mode_y_locate/2-2)||(mode_x_locate<=48-mode_y_locate-5+2))&&mode_x_locate>=24))
                                begin//�߿�ȫ��Ϊ��ɫ
                                    red=4'b0;                                   
                                    green=4'b0;
                                    blue=4'b0;
                                end
                                else begin
                                    if(sun_mode==2)begin//��ɫ����ʾ����ģʽ�Ѿ���
                                        red=4'b0;                                   
                                        green=4'b0;
                                        blue=4'b0;
                                    end
                                    else begin//��ɫ����ʾ����ģʽ�Ѿ��ر�
                                        // red=4'b0111;
                                        // green=4'b0111;
                                        // blue=4'b0111;
                                    end
                                end
                            end
                        end
                    end
                    if(y_poi-y_before>=y_day_begin&&y_poi-y_before<y_day_end)
                    begin
                        if(x_poi-x_before >= x_day_begin && x_poi-x_before <x_day_end)begin
                            if(sun_mode==0||sun_mode==1)day_addr=(x_poi-x_before-x_day_begin)/2+((y_poi-y_day_begin-y_before)/2)*pic_len/2+(sun_mode==1?40*40:0);
                            else begin
                                day_addr=(x_poi-x_before-x_day_begin)/2+((y_poi-y_day_begin-y_before)/2)*pic_len/2+(sun_change_info==1?40*40:0);
                            end
                            if(x_poi-x_before-x_day_begin<=1)begin
                                red=rom_data_in[11:8];
                                green=rom_data_in[7:4];
                                blue=rom_data_in[3:0];
                            end                        
                            else if(day_out!=12'h28d)begin
                                red=day_out[11:8];
                                green=day_out[7:4];
                                blue=day_out[3:0];
                            end
                            // if(x_poi-x_before+1<x_day_end)
                            //     day_addr=(x_poi-x_before-x_day_begin+1)/2+((y_poi-y_day_begin-y_before)/2)*pic_len/2+(sun_mode==1?40*40:0);
                            // else day_addr=(y_poi+1-y_day_begin-y_before)*pic_len;//��ʼ������һλ
                        end
                    end
                end
            end
            else
            begin
            red=0;
            green=0;
            blue=0;
            end
        end
    end
    always@(*) 
    begin
        base_addr=temp_num*32;
        if(!vol_dis)
            pre_voice=voice;
        if(!mp3mode_dis)
            pre_mp3_mode=Mp3_mode;
    end
endmodule
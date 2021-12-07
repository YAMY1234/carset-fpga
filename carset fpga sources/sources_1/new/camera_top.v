module camera_top(
        //����ͷ����ӿ�
        output       sio_c,//����ͷsio_c�ź�
        inout        sio_d,//����ͷsio_d�ź�
        output       reset,//reset�źţ���Ҫ���ߣ���������üĴ���
        output       pwdn,//pwdn�źţ����ͣ��رպĵ�ģʽ
        output       xclk,//xclk�źţ��ɲ���
        input        pclk,href,vsync,//���ڿ���ͼ�����ݴ���������ź�
        input  [7:0] camera_data ,//ͼ�������ź�
        //color sensor
        input color_frequncy,
        output [1:0] filter_select,
        output [1:0] frequncy_rate,
        output led,
        //VGA����ӿ�
        output [3:0]  red_out,green_out,blue_out,//rgb������Ϣ
        output x_valid,//��ʱ���ź�
        output y_valid,//��ʱ���ź�
        //ʱ��
        input  clk,//�Ӱ���ʼ�գ�100mhz
        //��λ�ӿ�
        input rst,//�ߵ�ƽ��Ч
        //��������
        input get_bluetooth,//��pmod
        //��ť�ӿ�
        //input [7:0] button,
        //output [6:0] display,//��Ӧ����ܽӿڣ���ʾ����

        //���°�֮���7������ܽӿ�
        output [7:0] disp7_shf,
        output [6:0] disp7_odata,

        input blue_link,
        output show_link,
        //����������
        input rst_time,          
        input change,           //changeΪ1ʱ���ֶ���ʱoutput [7:0] bit_sel,
        input select,           //����ѡ������ʱ�ĸı䣬����һ 
        input time_cnt,         //Ϊ1ʱ��Ӧʱ��+1//��Ϊλѡ�ź�
        // output [7:0] bit_sel,//��Ϊ��ѡ�ź�
        // output [6:0] seg_sel
        input addup,
        input turndown,
        input [2:0]rgbpos,
        input vol_dis,
        input mp3mode_dis,
        input alarm_set,
        output alarm_link
    );
    wire [7:0]out_bluetooth;//�������ݴ���
    wire [7:0]out_bluetooth_link;
    wire [7:0]oper;//��ť�������ݽӿ�
    wire [9:0]r,g,b;//color sensor�ӿ�

    Top_module_of_color color_sensor(.clk(clk),.frequncy(color_frequncy),.filter_select(filter_select),
    .frequncy_rate(frequncy_rate),.led(led),.r(r),.g(g),.b(b));

    change_oper_by_color cobc(.rst(rst),.clk(clk),.r(r),.g(g),.b(b),.oper(oper));

    bluetooth bt(.clk(clk),.rst(rst),.get(get_bluetooth),.out(out_bluetooth));
    bluetooth bt2(.clk(clk),.rst(rst),.get(blue_link),.out(out_bluetooth_link));
    // change_oper_by_button cobb(.rst(rst),.clk(clk),.button(button),.oper(oper));

    //ԭ�ȵ������������ʾ
    //display7 dis(.iData(out_bluetooth_link[3:0]),.oData(display));
    //display7 dis(.iData(oper[3:0]),.oData(display));
    //display7 display_sep(.iData({3'b0,up3,3'b0,down3,5'b0,sw[2:0],timet[15:0]}),.clk(CLK),.oData(disp7_odata),.shf(disp7_shf),.dot(disp7_dot));
    display_sep disp7(.iData({out_bluetooth_link[3:0],oper[3:0],24'b0}),.clk(clk),.oData(disp7_odata),.shf(disp7_shf));
    wire clk_vga ;//vgaʱ�� 24mhz
    wire clk_init_reg;//��ʼ���Ĵ�����ʱ�ӣ�25mhz

    clk_wiz_0 div(.clk_in1(clk),.clk_out1(clk_vga),.clk_out2(clk_init_reg));

    camera_init init(.clk(clk_init_reg),.sio_c(sio_c),.sio_d(sio_d),.reset(reset),.pwdn(pwdn),.rst(rst),.xclk(xclk));

    wire [11:0] ram_data;//д����
    wire  wr_en;//
    wire [18:0] ram_addr;//д��ַ
    camera_get_pic get_pic(.rst(rst),.pclk(pclk),.href(href),.vsync(vsync),.data_in(camera_data),.data_out(ram_data),.wr_en(wr_en),.out_addr(ram_addr));

    wire [11:0] rd_data;//������
    wire [18:0] rd_addr;//����ַ
    //�ҵ�
    wire [18:0] rom_addr;
    wire [11:0] rom_data;

    blk_mem_gen_0 buffer(.clka(clk),.ena(1),.wea(wr_en),.addra(ram_addr),.dina(ram_data),.clkb(clk),.enb(1),.addrb(rd_addr),.doutb(rd_data));
    bg_mem buffer2(.clka(clk),.ena(1),.addra(rom_addr),.douta(rom_data));

    wire [1:0] volum;wire mp3_mode;wire [1:0]sun_mode;
    wire focus;
    deal_blue_link bl(.clk(clk),.blue_data(out_bluetooth_link),.volum(volum),.mp3_mode(mp3_mode),.sun_mode(sun_mode),.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis),.focus(focus));
    // deal_blue_link bl(.clk(clk),.blue_data(out_bluetooth_link),.volum(volum),.mp3_mode(mp3_mode),.sun_mode(sun_mode),.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis));

    wire [11:0]deald_color;//�����������ź�
    wire sun_change_info;
    deal_pic deal(.clk(clk),.in_rgb(rd_data),.oper(oper),.out_rgb(deald_color),.ena(1),.sun_change_info(sun_change_info),.sun_mode(sun_mode));
    //vga_display vga(.clk_vga(clk_vga),.rst(rst),.color_data_in(deald_color),.ram_addr(rd_addr),.x_valid(x_valid),.y_valid(y_valid),.red(red_out),.green(green_out),.blue(blue_out));
    
    //�����Ӳ��֣�
    //��Ϊ�ֶ����Զ�ʱ����������
    wire [3:0] L_sec;
    wire [3:0] H_sec;
    wire [3:0] L_min;
    wire [3:0] H_min;
    wire [3:0] L_hour;
    wire [3:0] H_hour;    

    //����ʱ��
    Clock_display clock_display(.clk_100MHz(clk),.rst_time(rst_time),.select(select),.time_cnt(time_cnt),.change(change),       
   .L_sec(L_sec), .H_sec(H_sec), .L_min(L_min), .H_min(H_min), .L_hour(L_hour),.H_hour(H_hour),
   .select_time(select_time),.change_out(change_out));
   
    vga_display2 vga2(.clk_vga(clk_vga),.rst(rst),.color_data_in(deald_color),.rom_data_in(rom_data),.rom_addr(rom_addr),
    .ram_addr(rd_addr),.x_valid(x_valid),.y_valid(y_valid),.red(red_out),.green(green_out),.blue(blue_out),.L_sec(L_sec),.H_sec(H_sec),.L_min(L_min)
    ,.H_min(H_min),.L_hour(L_hour),.H_hour(H_hour),.voice(volum),.addup(addup),.turndown(turndown),.rgbpos(rgbpos),.Mp3_mode(mp3_mode),.sun_mode(sun_mode)
    ,.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis),.sun_change_info(sun_change_info),.focus(focus));
    
    //     vga_display2 vga2(.clk_vga(clk_vga),.rst(rst),.color_data_in(deald_color),.rom_data_in(rom_data),.rom_addr(rom_addr),
    // .ram_addr(rd_addr),.x_valid(x_valid),.y_valid(y_valid),.red(red_out),.green(green_out),.blue(blue_out),.L_sec(L_sec),.H_sec(H_sec),.L_min(L_min)
    // ,.H_min(H_min),.L_hour(L_hour),.H_hour(H_hour),.voice(volum),.addup(addup),.turndown(turndown),.rgbpos(rgbpos),.Mp3_mode(mp3_mode),.sun_mode(sun_mode)
    // ,.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis),.sun_change_info(sun_change_info));
    assign show_link=blue_link;
    assign alarm_link=alarm_set;
endmodule



/*
vga_display(
    input clk_vga,//����vga��ʱ�ӣ�Ƶ��Ϊ25.175MHz
    input rst,//��λ�źţ��ߵ�ƽ��Ч
    input [11:0] color_data_in,//��RAM�ж�ȡ��������Ϣ
    output reg[18:0] ram_addr,//Ӧ�ö�ȡ��RAM��ͼƬ��ַ����vga_control����
    output x_valid,
    output y_valid,
    output reg[3:0] red,
    output reg[3:0] blue,
    output reg[3:0] green
);

*/

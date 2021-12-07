module camera_top(
        //摄像头对外接口
        output       sio_c,//摄像头sio_c信号
        inout        sio_d,//摄像头sio_d信号
        output       reset,//reset信号，需要拉高，否则会重置寄存器
        output       pwdn,//pwdn信号，拉低，关闭耗电模式
        output       xclk,//xclk信号，可不接
        input        pclk,href,vsync,//用于控制图像数据传输的三组信号
        input  [7:0] camera_data ,//图像数据信号
        //color sensor
        input color_frequncy,
        output [1:0] filter_select,
        output [1:0] frequncy_rate,
        output led,
        //VGA对外接口
        output [3:0]  red_out,green_out,blue_out,//rgb像素信息
        output x_valid,//行时序信号
        output y_valid,//场时序信号
        //时钟
        input  clk,//接板内始终，100mhz
        //复位接口
        input rst,//高电平有效
        //蓝牙串口
        input get_bluetooth,//接pmod
        //按钮接口
        //input [7:0] button,
        //output [6:0] display,//对应数码管接口，显示蓝牙

        //更新版之后的7段数码管接口
        output [7:0] disp7_shf,
        output [6:0] disp7_odata,

        input blue_link,
        output show_link,
        //关于数字钟
        input rst_time,          
        input change,           //change为1时表手动计时output [7:0] bit_sel,
        input select,           //控制选择对秒分时的改变，三合一 
        input time_cnt,         //为1时对应时间+1//作为位选信号
        // output [7:0] bit_sel,//作为段选信号
        // output [6:0] seg_sel
        input addup,
        input turndown,
        input [2:0]rgbpos,
        input vol_dis,
        input mp3mode_dis,
        input alarm_set,
        output alarm_link
    );
    wire [7:0]out_bluetooth;//蓝牙数据传输
    wire [7:0]out_bluetooth_link;
    wire [7:0]oper;//按钮传送数据接口
    wire [9:0]r,g,b;//color sensor接口

    Top_module_of_color color_sensor(.clk(clk),.frequncy(color_frequncy),.filter_select(filter_select),
    .frequncy_rate(frequncy_rate),.led(led),.r(r),.g(g),.b(b));

    change_oper_by_color cobc(.rst(rst),.clk(clk),.r(r),.g(g),.b(b),.oper(oper));

    bluetooth bt(.clk(clk),.rst(rst),.get(get_bluetooth),.out(out_bluetooth));
    bluetooth bt2(.clk(clk),.rst(rst),.get(blue_link),.out(out_bluetooth_link));
    // change_oper_by_button cobb(.rst(rst),.clk(clk),.button(button),.oper(oper));

    //原先的蓝牙数码管显示
    //display7 dis(.iData(out_bluetooth_link[3:0]),.oData(display));
    //display7 dis(.iData(oper[3:0]),.oData(display));
    //display7 display_sep(.iData({3'b0,up3,3'b0,down3,5'b0,sw[2:0],timet[15:0]}),.clk(CLK),.oData(disp7_odata),.shf(disp7_shf),.dot(disp7_dot));
    display_sep disp7(.iData({out_bluetooth_link[3:0],oper[3:0],24'b0}),.clk(clk),.oData(disp7_odata),.shf(disp7_shf));
    wire clk_vga ;//vga时钟 24mhz
    wire clk_init_reg;//初始化寄存器的时钟，25mhz

    clk_wiz_0 div(.clk_in1(clk),.clk_out1(clk_vga),.clk_out2(clk_init_reg));

    camera_init init(.clk(clk_init_reg),.sio_c(sio_c),.sio_d(sio_d),.reset(reset),.pwdn(pwdn),.rst(rst),.xclk(xclk));

    wire [11:0] ram_data;//写数据
    wire  wr_en;//
    wire [18:0] ram_addr;//写地址
    camera_get_pic get_pic(.rst(rst),.pclk(pclk),.href(href),.vsync(vsync),.data_in(camera_data),.data_out(ram_data),.wr_en(wr_en),.out_addr(ram_addr));

    wire [11:0] rd_data;//读数据
    wire [18:0] rd_addr;//读地址
    //我的
    wire [18:0] rom_addr;
    wire [11:0] rom_data;

    blk_mem_gen_0 buffer(.clka(clk),.ena(1),.wea(wr_en),.addra(ram_addr),.dina(ram_data),.clkb(clk),.enb(1),.addrb(rd_addr),.doutb(rd_data));
    bg_mem buffer2(.clka(clk),.ena(1),.addra(rom_addr),.douta(rom_data));

    wire [1:0] volum;wire mp3_mode;wire [1:0]sun_mode;
    wire focus;
    deal_blue_link bl(.clk(clk),.blue_data(out_bluetooth_link),.volum(volum),.mp3_mode(mp3_mode),.sun_mode(sun_mode),.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis),.focus(focus));
    // deal_blue_link bl(.clk(clk),.blue_data(out_bluetooth_link),.volum(volum),.mp3_mode(mp3_mode),.sun_mode(sun_mode),.vol_dis(vol_dis),.mp3mode_dis(mp3mode_dis));

    wire [11:0]deald_color;//处理后的数据信号
    wire sun_change_info;
    deal_pic deal(.clk(clk),.in_rgb(rd_data),.oper(oper),.out_rgb(deald_color),.ena(1),.sun_change_info(sun_change_info),.sun_mode(sun_mode));
    //vga_display vga(.clk_vga(clk_vga),.rst(rst),.color_data_in(deald_color),.ram_addr(rd_addr),.x_valid(x_valid),.y_valid(y_valid),.red(red_out),.green(green_out),.blue(blue_out));
    
    //数字钟部分：
    //作为手动与自动时间的最终输出
    wire [3:0] L_sec;
    wire [3:0] H_sec;
    wire [3:0] L_min;
    wire [3:0] H_min;
    wire [3:0] L_hour;
    wire [3:0] H_hour;    

    //计算时间
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
    input clk_vga,//输入vga的时钟，频率为25.175MHz
    input rst,//复位信号，高电平有效
    input [11:0] color_data_in,//从RAM中读取的像素信息
    output reg[18:0] ram_addr,//应该读取的RAM的图片地址，由vga_control给出
    output x_valid,
    output y_valid,
    output reg[3:0] red,
    output reg[3:0] blue,
    output reg[3:0] green
);

*/

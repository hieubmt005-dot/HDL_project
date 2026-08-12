module BrickSmash_DE2(
    input CLOCK_50,          
    input [3:0] KEY,         // KEY0: Reset, KEY1: Phải, KEY2: Trái, KEY3: Bắt đầu
    output VGA_HS, VGA_VS,   
    output [9:0] VGA_R, VGA_G, VGA_B, 
    output VGA_BLANK, VGA_SYNC, VGA_CLK,
	 output [6:0] HEX0, HEX1, HEX2, HEX3 // Dùng 4 LED đầu tiên
);

    wire rst = ~KEY[0];     
    wire clk_25M, clk_60Hz;
    wire [9:0] w_pixel_x, w_pixel_y;
    wire w_video_on;
    
    wire [9:0] w_ball_x, w_ball_y, w_paddle_x;
    wire [119:0] w_bricks;  
    wire [2:0] w_state;
    wire [7:0] w_delay_cnt;

	 wire [11:0] w_score;
    
    // Tách số thành BCD (Binary Coded Decimal) để hiển thị
    // Với DE2, Quartus hỗ trợ toán tử / và % cho các số nhỏ
    wire [3:0] score_unit = w_score % 10;
    wire [3:0] score_ten  = (w_score / 10) % 10;
    wire [3:0] score_hun  = (w_score / 100) % 10;
    wire [3:0] score_thou  = (w_score / 1000) % 10;

    // Khởi tạo các bộ giải mã cho từng LED
    hex_decoder h0 (.bin(score_unit), .hex(HEX0)); // Hàng đơn vị
    hex_decoder h1 (.bin(score_ten),  .hex(HEX1)); // Hàng chục
    hex_decoder h2 (.bin(score_hun),  .hex(HEX2)); // Hàng trăm
    hex_decoder h3 (.bin(score_thou),  .hex(HEX3)); // Hàng nghìn 
	 
    clk_divider clk_unit (
        .clk_50M(CLOCK_50), .rst(rst), 
        .clk_25M(clk_25M), .clk_60Hz(clk_60Hz)
    );

    vga_sync vga_unit (
        .clk_25M(clk_25M), .rst(rst), 
        .hsync(VGA_HS), .vsync(VGA_VS),
        .pixel_x(w_pixel_x), .pixel_y(w_pixel_y), .video_on(w_video_on)
    );

    game_logic game_unit (
        .clk_60Hz(clk_60Hz), .rst(rst), 
        .btn_left(KEY[2]), .btn_right(KEY[1]), .btn_start(KEY[3]),
        .ball_x(w_ball_x), .ball_y(w_ball_y), .paddle_x(w_paddle_x),
        .bricks(w_bricks), .state(w_state), .delay_cnt(w_delay_cnt),
		  .score(w_score)
    );

    image_gen draw_unit (
        .pixel_x(w_pixel_x), .pixel_y(w_pixel_y), .video_on(w_video_on),
        .ball_x(w_ball_x), .ball_y(w_ball_y), .paddle_x(w_paddle_x),
        .bricks(w_bricks), .state(w_state), .delay_cnt(w_delay_cnt),
        .vga_r(VGA_R), .vga_g(VGA_G), .vga_b(VGA_B)
    );

    assign VGA_CLK = clk_25M;   
    assign VGA_SYNC = 1'b0;     
    assign VGA_BLANK = w_video_on; 

endmodule
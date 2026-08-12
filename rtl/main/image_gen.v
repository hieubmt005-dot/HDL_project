module image_gen(
    input [9:0] pixel_x, pixel_y,
    input video_on,
    input [9:0] ball_x, ball_y, paddle_x,
    input [119:0] bricks,
    input [2:0] state,
    input [7:0] delay_cnt,
    output reg [9:0] vga_r, vga_g, vga_b
);

    localparam PADDLE_W = 80, PADDLE_H = 10, PADDLE_Y = 440;
    localparam BALL_SIZE = 8;
    localparam BRICK_W = 32, BRICK_H = 16, BRICK_START_Y = 32;

    wire is_paddle = (pixel_x >= paddle_x) && (pixel_x < paddle_x + PADDLE_W) && (pixel_y >= PADDLE_Y) && (pixel_y < PADDLE_Y + PADDLE_H);
    wire is_ball = (pixel_x >= ball_x) && (pixel_x < ball_x + BALL_SIZE) && (pixel_y >= ball_y) && (pixel_y < ball_y + BALL_SIZE);
    
    wire [6:0] current_col = pixel_x >> 5;
    wire [6:0] current_row = (pixel_y - BRICK_START_Y) >> 4;
    wire [6:0] brick_index = (current_row << 4) + (current_row << 2) + current_col;
    wire is_brick = (pixel_y >= BRICK_START_Y) && (pixel_y < BRICK_START_Y + 6 * BRICK_H) && (bricks[brick_index] == 1'b1);
    // =========================================================================
    // 1. MÀN HÌNH START (Căn giữa, Y từ 205 đến 275)
    // Khoảng cách mỗi chữ là 50px rộng, cách nhau 10px. X bắt đầu từ 175.
    // =========================================================================
    wire st_S = (pixel_x>=175 && pixel_x<=225 && pixel_y>=205 && pixel_y<=215) || 
                (pixel_x>=175 && pixel_x<=185 && pixel_y>=205 && pixel_y<=245) || 
                (pixel_x>=175 && pixel_x<=225 && pixel_y>=235 && pixel_y<=245) || 
                (pixel_x>=215 && pixel_x<=225 && pixel_y>=235 && pixel_y<=275) || 
                (pixel_x>=175 && pixel_x<=225 && pixel_y>=265 && pixel_y<=275);

    wire st_T1= (pixel_x>=235 && pixel_x<=285 && pixel_y>=205 && pixel_y<=215) || 
                (pixel_x>=255 && pixel_x<=265 && pixel_y>=205 && pixel_y<=275);

    wire st_A = (pixel_x>=295 && pixel_x<=345 && pixel_y>=205 && pixel_y<=215) || 
                (pixel_x>=295 && pixel_x<=305 && pixel_y>=205 && pixel_y<=275) || 
                (pixel_x>=335 && pixel_x<=345 && pixel_y>=205 && pixel_y<=275) || 
                (pixel_x>=295 && pixel_x<=345 && pixel_y>=235 && pixel_y<=245);

    wire st_R = (pixel_x>=355 && pixel_x<=365 && pixel_y>=205 && pixel_y<=275) || 
                (pixel_x>=365 && pixel_x<=395 && pixel_y>=205 && pixel_y<=215) || 
                (pixel_x>=395 && pixel_x<=405 && pixel_y>=215 && pixel_y<=235) || 
                (pixel_x>=365 && pixel_x<=395 && pixel_y>=235 && pixel_y<=245) || 
                (pixel_x>=375 && pixel_x<=385 && pixel_y>=245 && pixel_y<=255) || 
                (pixel_x>=385 && pixel_x<=395 && pixel_y>=255 && pixel_y<=265) || 
                (pixel_x>=395 && pixel_x<=405 && pixel_y>=265 && pixel_y<=275);   

    wire st_T2= (pixel_x>=415 && pixel_x<=465 && pixel_y>=205 && pixel_y<=215) || 
                (pixel_x>=435 && pixel_x<=445 && pixel_y>=205 && pixel_y<=275);

    wire is_start_text = st_S || st_T1 || st_A || st_R || st_T2;


    // =========================================================================
    // 2. MÀN HÌNH GAME OVER (Xếp 2 dòng: GAME ở trên, OVER ở dưới)
    // =========================================================================
    
    // --- DÒNG 1: Chữ "GAME" (Y từ 160 đến 230) ---
    wire go_G = (pixel_x>=205 && pixel_x<=255 && pixel_y>=160 && pixel_y<=170) ||
                (pixel_x>=205 && pixel_x<=215 && pixel_y>=160 && pixel_y<=230) ||
                (pixel_x>=205 && pixel_x<=255 && pixel_y>=220 && pixel_y<=230) ||
                (pixel_x>=245 && pixel_x<=255 && pixel_y>=195 && pixel_y<=230) ||
                (pixel_x>=230 && pixel_x<=255 && pixel_y>=195 && pixel_y<=205);

    wire go_A = (pixel_x>=265 && pixel_x<=315 && pixel_y>=160 && pixel_y<=170) ||
                (pixel_x>=265 && pixel_x<=275 && pixel_y>=160 && pixel_y<=230) ||
                (pixel_x>=305 && pixel_x<=315 && pixel_y>=160 && pixel_y<=230) ||
                (pixel_x>=265 && pixel_x<=315 && pixel_y>=190 && pixel_y<=200);

    wire go_M = (pixel_x>=325 && pixel_x<=335 && pixel_y>=160 && pixel_y<=230) ||
                (pixel_x>=365 && pixel_x<=375 && pixel_y>=160 && pixel_y<=230) ||
                (pixel_x>=335 && pixel_x<=345 && pixel_y>=170 && pixel_y<=190) ||
                (pixel_x>=345 && pixel_x<=355 && pixel_y>=190 && pixel_y<=210) ||
                (pixel_x>=355 && pixel_x<=365 && pixel_y>=170 && pixel_y<=190);

    wire go_E1= (pixel_x>=385 && pixel_x<=435 && pixel_y>=160 && pixel_y<=170) ||
                (pixel_x>=385 && pixel_x<=395 && pixel_y>=160 && pixel_y<=230) ||
                (pixel_x>=385 && pixel_x<=425 && pixel_y>=190 && pixel_y<=200) ||
                (pixel_x>=385 && pixel_x<=435 && pixel_y>=220 && pixel_y<=230);

    // --- DÒNG 2: Chữ "OVER" (Y từ 250 đến 320) ---
    wire go_O = (pixel_x>=205 && pixel_x<=255 && pixel_y>=250 && pixel_y<=260) ||
                (pixel_x>=205 && pixel_x<=215 && pixel_y>=250 && pixel_y<=320) ||
                (pixel_x>=245 && pixel_x<=255 && pixel_y>=250 && pixel_y<=320) ||
                (pixel_x>=205 && pixel_x<=255 && pixel_y>=310 && pixel_y<=320);

    wire go_V = (pixel_x>=265 && pixel_x<=275 && pixel_y>=250 && pixel_y<=290) ||
                (pixel_x>=305 && pixel_x<=315 && pixel_y>=250 && pixel_y<=290) ||
                (pixel_x>=275 && pixel_x<=285 && pixel_y>=290 && pixel_y<=310) ||
                (pixel_x>=295 && pixel_x<=305 && pixel_y>=290 && pixel_y<=310) ||
                (pixel_x>=285 && pixel_x<=295 && pixel_y>=310 && pixel_y<=320);

    wire go_E2= (pixel_x>=325 && pixel_x<=375 && pixel_y>=250 && pixel_y<=260) ||
                (pixel_x>=325 && pixel_x<=335 && pixel_y>=250 && pixel_y<=320) ||
                (pixel_x>=325 && pixel_x<=365 && pixel_y>=280 && pixel_y<=290) ||
                (pixel_x>=325 && pixel_x<=375 && pixel_y>=310 && pixel_y<=320);

    wire go_R = (pixel_x>=385 && pixel_x<=395 && pixel_y>=250 && pixel_y<=320) || // Trụ dọc bên trái
                (pixel_x>=395 && pixel_x<=425 && pixel_y>=250 && pixel_y<=260) || // Gạch ngang trên cùng
                (pixel_x>=425 && pixel_x<=435 && pixel_y>=260 && pixel_y<=280) || // Cạnh phải của vòng lặp
                (pixel_x>=395 && pixel_x<=425 && pixel_y>=280 && pixel_y<=290) || // Gạch ngang giữa
                (pixel_x>=405 && pixel_x<=415 && pixel_y>=290 && pixel_y<=300) || // Bậc thang chéo 1
                (pixel_x>=415 && pixel_x<=425 && pixel_y>=300 && pixel_y<=310) || // Bậc thang chéo 2
                (pixel_x>=425 && pixel_x<=435 && pixel_y>=310 && pixel_y<=320);   // Bậc thang chéo 3
    wire is_over_text = go_G || go_A || go_M || go_E1 || go_O || go_V || go_E2 || go_R;

	 // 1. CHỮ W (Trụ 2 bên cao, có khối nhô lên ở giữa)
    wire is_W = (pixel_x >= 235 && pixel_x <= 245 && pixel_y >= 205 && pixel_y <= 275) || // Trụ trái
                (pixel_x >= 275 && pixel_x <= 285 && pixel_y >= 205 && pixel_y <= 275) || // Trụ phải
                (pixel_x >= 245 && pixel_x <= 255 && pixel_y >= 255 && pixel_y <= 275) || // Đáy trái
                (pixel_x >= 255 && pixel_x <= 265 && pixel_y >= 235 && pixel_y <= 275) || // Đỉnh chóp giữa
                (pixel_x >= 265 && pixel_x <= 275 && pixel_y >= 255 && pixel_y <= 275);   // Đáy phải

    // 2. CHỮ I (Có gạch ngang trên và dưới)
    wire is_I = (pixel_x >= 305 && pixel_x <= 335 && pixel_y >= 205 && pixel_y <= 215) || // Gạch ngang trên
                (pixel_x >= 305 && pixel_x <= 335 && pixel_y >= 265 && pixel_y <= 275) || // Gạch ngang dưới
                (pixel_x >= 315 && pixel_x <= 325 && pixel_y >= 215 && pixel_y <= 265);   // Trụ dọc giữa

    // 3. CHỮ N (Nét chéo được tạo bằng 3 bậc thang)
    wire is_N = (pixel_x >= 355 && pixel_x <= 365 && pixel_y >= 205 && pixel_y <= 275) || // Trụ trái
                (pixel_x >= 395 && pixel_x <= 405 && pixel_y >= 205 && pixel_y <= 275) || // Trụ phải
                (pixel_x >= 365 && pixel_x <= 375 && pixel_y >= 215 && pixel_y <= 235) || // Bậc chéo 1
                (pixel_x >= 375 && pixel_x <= 385 && pixel_y >= 235 && pixel_y <= 255) || // Bậc chéo 2
                (pixel_x >= 385 && pixel_x <= 395 && pixel_y >= 255 && pixel_y <= 275);   // Bậc chéo 3

    wire is_win_text = is_W || is_I || is_N;
	 
    // SỐ ĐẾM NGƯỢC 3, 2, 1
    wire is_top = (pixel_x>=300 && pixel_x<=340 && pixel_y>=200 && pixel_y<=210);
    wire is_mid = (pixel_x>=300 && pixel_x<=340 && pixel_y>=235 && pixel_y<=245);
    wire is_bot = (pixel_x>=300 && pixel_x<=340 && pixel_y>=270 && pixel_y<=280);
    wire is_right = (pixel_x>=330 && pixel_x<=340 && pixel_y>=200 && pixel_y<=280);
    wire is_right_top = (pixel_x>=330 && pixel_x<=340 && pixel_y>=200 && pixel_y<=245);
    wire is_left_bot = (pixel_x>=300 && pixel_x<=310 && pixel_y>=235 && pixel_y<=280);
    wire is_mid_vert = (pixel_x>=315 && pixel_x<=325 && pixel_y>=200 && pixel_y<=280);

    wire is_3 = (delay_cnt > 120) && (is_top || is_mid || is_bot || is_right);
    wire is_2 = (delay_cnt <= 120 && delay_cnt > 60) && (is_top || is_right_top || is_mid || is_left_bot || is_bot);
    wire is_1 = (delay_cnt <= 60 && delay_cnt > 0) && is_mid_vert;

    always @(*) begin
        if (~video_on) {vga_r, vga_g, vga_b} = 30'h0;
        else begin
            case (state)
                2'd0: begin // MÀN HÌNH START (Nền xanh)
                    if (is_start_text) {vga_r, vga_g, vga_b} = {10'h3FF, 10'h3FF, 10'h3FF}; // Chữ trắng
                    else               {vga_r, vga_g, vga_b} = {10'd0, 10'd0, 10'h1FF};     // Nền xanh
                end
                2'd1: begin // MÀN HÌNH ĐẾM NGƯỢC
                    if (is_3 || is_2 || is_1) {vga_r, vga_g, vga_b} = {10'h3FF, 10'h3FF, 10'h3FF}; 
                    else                      {vga_r, vga_g, vga_b} = 30'h0; // Nền đen
                end
                2'd2: begin // MÀN HÌNH GAME
                    if (is_ball) {vga_r, vga_g, vga_b} = {10'h3FF, 10'd0, 10'd0};
                    else if (is_paddle) {vga_r, vga_g, vga_b} = {10'd0, 10'h3FF, 10'h3FF};
                    else if (is_brick) begin
						 if (current_row == 0)      {vga_r, vga_g, vga_b} = {10'h3FF, 10'h3FF, 10'd0}; // Vàng
						 else if (current_row == 1) {vga_r, vga_g, vga_b} = {10'd0, 10'h3FF, 10'd0};   // Xanh lá
						 else if (current_row == 2) {vga_r, vga_g, vga_b} = {10'h3FF, 10'd0, 10'h3FF}; // Tím
						 else if (current_row == 3) {vga_r, vga_g, vga_b} = {10'd0, 10'd0, 10'h3FF};   // Xanh dương
						 else if (current_row == 4) {vga_r, vga_g, vga_b} = {10'h3FF, 10'h1FF, 10'd0}; // Cam (hàng mới)
						 else                       {vga_r, vga_g, vga_b} = {10'd0, 10'h3FF, 10'h3FF}; // Xanh lơ (hàng mới)
					end else {vga_r, vga_g, vga_b} = 30'h0;
                end
					 3'd4: begin // MÀN HÌNH WIN (Nền xanh lá)
                    if (is_win_text) {vga_r, vga_g, vga_b} = {10'h3FF, 10'h3FF, 10'h3FF}; // Chữ trắng
                    else             {vga_r, vga_g, vga_b} = {10'd0, 10'h2FF, 10'd0};    // Nền xanh lá
                end
                2'd3: begin // MÀN HÌNH GAME OVER (Nền đỏ)
                    if (is_over_text) {vga_r, vga_g, vga_b} = {10'h3FF, 10'h3FF, 10'h3FF};
                    else              {vga_r, vga_g, vga_b} = {10'h2FF, 10'd0, 10'd0}; 
                end
                default: {vga_r, vga_g, vga_b} = 30'h0;
            endcase
        end
    end
endmodule
module game_logic(
    input clk_60Hz, rst,
    input btn_left, btn_right, btn_start, // KEY[2], KEY[1], KEY[3]
    
    output reg [9:0] ball_x, ball_y,
    output reg [9:0] paddle_x,
    output reg [119:0] bricks,
    output reg [2:0] state,       // 0:START, 1:DELAY, 2:PLAY, 3:GAMEOVER
    output reg [7:0] delay_cnt,   // Bộ đếm gửi ra màn hình
    output reg [15:0] score
);

    localparam S_START = 3'd0, S_DELAY = 3'd1, S_PLAY = 3'd2, S_GAMEOVER = 3'd3, S_WIN = 3'd4;    localparam PADDLE_W = 80, PADDLE_H = 10, PADDLE_Y = 440; 
    localparam BALL_SIZE = 8;
    localparam BRICK_W = 32, BRICK_H = 16, BRICK_START_Y = 32; 

    reg [9:0] dx, dy; 
    reg dir_x, dir_y; 
    reg [2:0] hit_wait;
    reg [7:0] timer; 

    // Tọa độ Điểm Dẫn Đầu (Chống xuyên gạch)
    wire [9:0] lead_x = dir_x ? (ball_x + BALL_SIZE) : ball_x;
    wire [9:0] lead_y = dir_y ? (ball_y + BALL_SIZE) : ball_y;

    initial begin
        state = S_START;
        bricks = {120{1'b1}}; 
        timer = 0; hit_wait = 0;
    end

    always @(posedge clk_60Hz or posedge rst) begin
        if (rst) begin
            state <= S_START; // Nhấn KEY0 luôn quay về START
            bricks <= {120{1'b1}};
        end else begin
            case (state)
                // ---------------------------------------------------
                // TRẠNG THÁI 1: MÀN HÌNH CHỜ (START)
                // ---------------------------------------------------
                S_START: begin
					     score <= 16'd0; // Reset điểm khi bắt đầu
                    paddle_x <= 280; 
                    ball_x <= 320;   // 280 + (80/2) - (8/2) -> Đặt chính giữa thanh chèo
                    ball_y <= 240;   // Treo bóng lơ lửng
                    dx <= 2;         // KHÔNG di chuyển ngang ở lần rơi đầu tiên
                    dy <= 2;         
                    dir_x <= 1; dir_y <= 1; 
                    bricks <= {120{1'b1}}; // Nạp đầy 80 viên gạch
                    
                    if (~btn_start) begin
                        state <= S_DELAY;
                        timer <= 180; // 60Hz * 3 giây = 180 khung hình
                    end
                end

                // ---------------------------------------------------
                // TRẠNG THÁI 2: ĐẾM NGƯỢC 3... 2... 1...
                // ---------------------------------------------------
                S_DELAY: begin
                    if (timer > 0) begin
                        timer <= timer - 1;
                        delay_cnt <= timer; // Truyền giá trị ra image_gen để vẽ số
                    end else begin
                        state <= S_PLAY;
                    end
                end

                // ---------------------------------------------------
                // TRẠNG THÁI 3: ĐANG CHƠI (PLAY)
                // ---------------------------------------------------
                S_PLAY: begin
					 
					     if (score == 16'd400) begin
                        dx <= 3; 
                        dy <= 3;
                    end 
						  
						  if (score == 16'd800) begin
                        dx <= 4; 
                        dy <= 4;
                    end

                    // 2. Logic kiểm tra thắng cuộc (phá hết 120 gạch)
                    if (score == 16'd1200) begin
                        state <= S_WIN;
                        timer <= 0;
                    end
                    // 1. THANH CHÈO
                    if (~btn_left) paddle_x <= (paddle_x >= 6) ? (paddle_x - 6) : 0;
                    if (~btn_right) paddle_x <= (paddle_x <= 640 - PADDLE_W - 6) ? (paddle_x + 6) : (640 - PADDLE_W);

                    // 2. TỌA ĐỘ BÓNG
                    ball_x <= dir_x ? (ball_x + dx) : ((ball_x >= dx) ? (ball_x - dx) : 0);
                    ball_y <= dir_y ? (ball_y + dy) : ((ball_y >= dy) ? (ball_y - dy) : 0);

                    // 3. VA CHẠM TƯỜNG
                    if (dir_x == 0 && ball_x <= dx) dir_x <= 1; 
                    else if (dir_x == 1 && ball_x >= (640 - BALL_SIZE - dx)) dir_x <= 0; 
                    if (dir_y == 0 && ball_y <= dy) dir_y <= 1; 

                    // 4. KIỂM TRA THUA (Chạm đáy)
                    if (dir_y == 1 && ball_y >= (480 - BALL_SIZE - dy)) begin
                        state <= S_GAMEOVER;
                        timer <= 0;
                    end

                    // 5. VA CHẠM THANH CHÈO
                    if ((ball_y + BALL_SIZE >= PADDLE_Y) && (ball_y + BALL_SIZE <= PADDLE_Y + PADDLE_H) &&
                        (ball_x + BALL_SIZE >= paddle_x) && (ball_x <= paddle_x + PADDLE_W)) begin
                        dir_y <= 0; // Nảy lên
                        
                        // Nếu đang là cú rơi thẳng đứng (dx = 0), bật vận tốc chéo lên
                        //if (dx == 0) dx <= 3; 
                    end

                    // 6. VA CHẠM GẠCH (Dùng điểm dẫn đầu & Cooldown)
                    if (hit_wait > 0) hit_wait <= hit_wait - 1; 
                    else if ((lead_y >= BRICK_START_Y) && (lead_y < BRICK_START_Y + 6 * BRICK_H)) begin                        begin : collision_block
                            integer col, row, index, local_x;
                            col = lead_x >> 5;                       
                            row = (lead_y - BRICK_START_Y) >> 4;     
                            index = (row << 4) + (row << 2) + col; 
                            local_x = lead_x & 10'h01F;              
                            
                            if (bricks[index] == 1'b1) begin 
                                bricks[index] <= 1'b0;  
										  score <= score + 16'd10; // Mỗi viên gạch +1 điểm
                                hit_wait <= 3; // Chống xuyên thấu
                                if (local_x <= 4 || local_x >= 27) dir_x <= ~dir_x; 
                                else dir_y <= ~dir_y;        
                            end
                        end
                    end
                end

					 // TRANG THAI WIN
					 S_WIN: begin
                    if (timer < 180) begin // Dừng ở màn hình đỏ 2 giây (120 frames)
                        timer <= timer + 1;
                    end else begin
                        state <= S_START; // Tự động quay về START
                    end
                end
                // ---------------------------------------------------
                // TRẠNG THÁI 4: THUA CUỘC (GAME OVER)
                // ---------------------------------------------------
                S_GAMEOVER: begin
                    if (timer < 180) begin // Dừng ở màn hình đỏ 2 giây (120 frames)
                        timer <= timer + 1;
                    end else begin
                        state <= S_START; // Tự động quay về START
                    end
                end
            endcase
        end
    end
endmodule
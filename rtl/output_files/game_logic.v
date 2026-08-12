module game_logic(
    input clk_60Hz, rst,
    input btn_left, btn_right,     // Nút điều khiển thanh chèo (Tích cực mức 0)
    output reg [9:0] ball_x, ball_y,
    output reg [9:0] paddle_x,
    output reg [31:0] bricks       // Mảng 32 bit lưu trạng thái 32 viên gạch
);

    // --- CÁC HẰNG SỐ KÍCH THƯỚC ---
    localparam PADDLE_W = 80, PADDLE_H = 10;
    localparam PADDLE_Y = 440; // Gần đáy màn hình
    localparam BALL_SIZE = 8;
    localparam BRICK_W = 64, BRICK_H = 16;
    localparam BRICK_START_X = 64, BRICK_START_Y = 64; // Tọa độ bắt đầu vẽ gạch

    // --- VẬN TỐC BÓNG ---
    reg [9:0] dx, dy; // Có thể âm hoặc dương (dùng bù 2)
    reg dir_x, dir_y; // 0: sang trái/lên trên, 1: sang phải/xuống dưới

    // --- LOGIC CHÍNH ---
    always @(posedge clk_60Hz or posedge rst) begin
        if (rst) begin
            paddle_x <= 280;     // Giữa màn hình (640/2 - 80/2)
            ball_x <= 320;       // Giữa màn hình
            ball_y <= 240;
            dir_x <= 1; dir_y <= 1; // Ban đầu bay chéo xuống góc phải
            dx <= 3; dy <= 3;       // Tốc độ 3 pixel/frame
            bricks <= 32'hFFFFFFFF; // Ban đầu cả 32 viên gạch đều còn (mức 1)
        end else begin
            // 1. ĐIỀU KHIỂN THANH CHÈO
            if (~btn_left && (paddle_x > 0)) 
                paddle_x <= paddle_x - 5; // Tốc độ rê thanh chèo
            if (~btn_right && (paddle_x < (640 - PADDLE_W))) 
                paddle_x <= paddle_x + 5;

            // 2. CẬP NHẬT VỊ TRÍ BÓNG
            ball_x <= dir_x ? (ball_x + dx) : (ball_x - dx);
            ball_y <= dir_y ? (ball_y + dy) : (ball_y - dy);

            // 3. XỬ LÝ VA CHẠM TƯỜNG
            if (ball_x <= 0 || ball_x >= 640 - BALL_SIZE) dir_x <= ~dir_x; // Dội tường trái/phải
            if (ball_y <= 0) dir_y <= 1; // Dội trần (bay xuống)
            // Nếu rớt xuống đáy (ball_y >= 480) -> Thua. Để đơn giản tạm thời cho nảy lên.
            if (ball_y >= 480 - BALL_SIZE) dir_y <= 0; 

            // 4. XỬ LÝ VA CHẠM THANH CHÈO
            if ((ball_y + BALL_SIZE >= PADDLE_Y) && (ball_y <= PADDLE_Y + PADDLE_H) &&
                (ball_x + BALL_SIZE >= paddle_x) && (ball_x <= paddle_x + PADDLE_W)) begin
                dir_y <= 0; // Nảy lên trên
            end

            // 5. XỬ LÝ VA CHẠM GẠCH (Ứng dụng dịch bit chia nhanh)
            // Kiểm tra xem bóng có đang nằm trong khu vực có gạch không
            if ((ball_y >= BRICK_START_Y) && (ball_y < BRICK_START_Y + 4 * BRICK_H) &&
                (ball_x >= BRICK_START_X) && (ball_x < BRICK_START_X + 8 * BRICK_W)) begin
                
                // Tính toán chỉ số viên gạch (từ 0 đến 31)
                // Cột: (ball_x - 64) / 64 => Dịch phải 6 bit (>>6)
                // Hàng: (ball_y - 64) / 16 => Dịch phải 4 bit (>>4)
                begin : collision_block
                    integer col, row, index;
                    col = (ball_x - BRICK_START_X) >> 6;
                    row = (ball_y - BRICK_START_Y) >> 4;
                    index = (row << 3) + col; // index = row * 8 + col
                    
                    if (bricks[index] == 1'b1) begin // Nếu gạch còn
                        bricks[index] <= 1'b0;       // Xóa gạch
                        dir_y <= ~dir_y;             // Nảy bóng ngược lại
                    end
                end
            end
        end
    end
endmodule
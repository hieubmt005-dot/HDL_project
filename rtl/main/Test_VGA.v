module Test_VGA(
    input CLOCK_50,          // Xung 50MHz từ DE2
    input [0:0] KEY,         // Dùng KEY0 làm nút Reset
    
    output VGA_HS, VGA_VS,   // Đồng bộ ngang/dọc
    output [9:0] VGA_R, VGA_G, VGA_B, // Tín hiệu màu
    
    output VGA_BLANK, VGA_SYNC, // Các chân điều khiển DAC của DE2
    output VGA_CLK           // <-- QUAN TRỌNG: Xung nhịp cho chip DAC
);

    wire rst = ~KEY[0]; // Nhấn KEY0 = 0 -> rst = 1 (Tích cực mức cao)
    wire clk_25M, clk_60Hz;
    wire [9:0] w_x, w_y;
    wire w_video_on;

    // Khởi tạo module Clock Divider
    clk_divider clk_unit (
        .clk_50M(CLOCK_50), .rst(rst),
        .clk_25M(clk_25M), .clk_60Hz(clk_60Hz)
    );

    // Khởi tạo module VGA Sync
    vga_sync vga_unit (
        .clk_25M(clk_25M), .rst(rst),
        .hsync(VGA_HS), .vsync(VGA_VS),
        .pixel_x(w_x), .pixel_y(w_y),
        .video_on(w_video_on)
    );

    // --- CẤU HÌNH CHIP DAC ADV7123 TRÊN BOARD DE2 ---
    assign VGA_CLK = clk_25M;   // Cấp xung 25MHz cho chip DAC
    assign VGA_SYNC = 1'b0;     // Mức 0 theo datasheet
    assign VGA_BLANK = w_video_on; // Chỉ cho phép xuất màu khi ở vùng hiển thị

    // --- TEST HIỂN THỊ MÀU ---
    // Tô toàn màn hình màu Xanh Lá khi nằm trong vùng hiển thị
    assign VGA_R = 10'd0;
    assign VGA_G = w_video_on ? 10'h3FF : 10'd0; 
    assign VGA_B = 10'd0;

endmodule
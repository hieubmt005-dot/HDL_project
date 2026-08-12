`timescale 1ns / 1ps

module tb_vga_sync();

    // Khai báo các tín hiệu kết nối với module cần test
    reg clk_25M;
    reg rst;
    wire hsync, vsync;
    wire [9:0] pixel_x, pixel_y;
    wire video_on;

    // Gọi (Instantiate) module vga_sync
    vga_sync uut (
        .clk_25M(clk_25M),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on)
    );

    // Tạo xung clock 25MHz (chu kỳ 40ns -> nửa chu kỳ là 20ns)
    initial begin
        clk_25M = 0;
        forever #20 clk_25M = ~clk_25M;
    end

    // Kịch bản test (Test sequence)
    initial begin
        // Bật reset
        rst = 1;
        #100; // Chờ 100ns
        
        // Tắt reset để mạch hoạt động
        rst = 0;
        
        // Chạy mô phỏng trong thời gian đủ dài để quét qua vài dòng
        // 1 dòng mất 32,000 ns. Chờ 100,000 ns sẽ quét được khoảng 3 dòng.
        #100000;
        
        // Dừng mô phỏng
        $stop;
    end

endmodule
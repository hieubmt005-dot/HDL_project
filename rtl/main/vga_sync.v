module vga_sync(
    input clk_25M, rst,
    output hsync, vsync,
    output [9:0] pixel_x, pixel_y,
    output video_on 
);

    localparam HD = 640; 
    localparam HF = 16;  
    localparam HB = 48;  
    localparam HR = 96;  
    localparam HMAX = HD + HF + HB + HR - 1; //799

    localparam VD = 480; 
    localparam VF = 10;  
    localparam VB = 33;  
    localparam VR = 2;   
    localparam VMAX = VD + VF + VB + VR - 1; //524

    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    reg v_sync_reg, h_sync_reg;

    always @(posedge clk_25M or posedge rst) begin
        if (rst) begin
            h_count_reg <= 0;
            v_count_reg <= 0;
        end else begin
            h_count_reg <= h_count_next;
            v_count_reg <= v_count_next;
        end
    end

    always @(*) begin
        h_count_next = h_count_reg;
        v_count_next = v_count_reg;
        
        if (h_count_reg == HMAX) begin
            h_count_next = 0;
            if (v_count_reg == VMAX)
                v_count_next = 0;
            else
                v_count_next = v_count_reg + 1;
        end else begin
            h_count_next = h_count_reg + 1;
        end
    end

    assign hsync = ~((h_count_reg >= (HD + HF)) && (h_count_reg <= (HD + HF + HR - 1)));
    assign vsync = ~((v_count_reg >= (VD + VF)) && (v_count_reg <= (VD + VF + VR - 1)));

    assign video_on = (h_count_reg < HD) && (v_count_reg < VD);
    
    assign pixel_x = h_count_reg;
    assign pixel_y = v_count_reg;

endmodule
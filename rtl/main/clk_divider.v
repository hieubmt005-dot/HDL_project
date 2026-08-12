module clk_divider (
    input clk_50M,        
    input rst,           
    output reg clk_25M,   
    output reg clk_60Hz   
);

    always @(posedge clk_50M or posedge rst) begin
        if (rst) 
            clk_25M <= 0;
        else 
            clk_25M <= ~clk_25M;
    end

    reg [19:0] counter_60Hz;
    always @(posedge clk_50M or posedge rst) begin
        if (rst) begin
            counter_60Hz <= 0;
            clk_60Hz <= 0;
        end else begin
            if (counter_60Hz == 20'd416666) begin
                counter_60Hz <= 0;
                clk_60Hz <= ~clk_60Hz; 
            end else begin
                counter_60Hz <= counter_60Hz + 1;
            end
        end
    end
endmodule
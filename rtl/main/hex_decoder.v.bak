module hex_decoder(
    input [3:0] bin,
    output reg [6:0] hex
);
    always @(*) begin
        case (bin)
            4'h0: hex = 7'b1000000; // 0
            4'h1: hex = 7'b1111001; // 1
            4'h2: hex = 7'b0100100; // 2
            4'h3: hex = 7'b0110000; // 3
            4'h4: hex = 7'b0011001; // 4
            4'h5: hex = 7'b0010010; // 5
            4'h6: hex = 7'b0000010; // 6
            4'h7: hex = 7'b1111000; // 7
            4'h8: hex = 7'b0000000; // 8
            4'h9: hex = 7'b0010000; // 9
            default: hex = 7'b1111111; // Tắt hết
        endcase
    end
endmodule
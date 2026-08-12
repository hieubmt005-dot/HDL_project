library verilog;
use verilog.vl_types.all;
entity clk_divider is
    port(
        clk_50M         : in     vl_logic;
        rst             : in     vl_logic;
        clk_25M         : out    vl_logic;
        clk_60Hz        : out    vl_logic
    );
end clk_divider;

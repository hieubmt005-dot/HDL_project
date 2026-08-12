library verilog;
use verilog.vl_types.all;
entity clk_divider_vlg_check_tst is
    port(
        clk_25M         : in     vl_logic;
        clk_60Hz        : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end clk_divider_vlg_check_tst;

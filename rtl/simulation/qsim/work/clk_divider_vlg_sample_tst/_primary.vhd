library verilog;
use verilog.vl_types.all;
entity clk_divider_vlg_sample_tst is
    port(
        clk_50M         : in     vl_logic;
        rst             : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end clk_divider_vlg_sample_tst;

library verilog;
use verilog.vl_types.all;
entity vga_sync is
    port(
        clk_25M         : in     vl_logic;
        rst             : in     vl_logic;
        hsync           : out    vl_logic;
        vsync           : out    vl_logic;
        pixel_x         : out    vl_logic_vector(9 downto 0);
        pixel_y         : out    vl_logic_vector(9 downto 0);
        video_on        : out    vl_logic
    );
end vga_sync;

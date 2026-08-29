# Brick Smash Arcade Game on FPGA (Altera DE2)

[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()
[![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue.svg)]()
[![Tool](https://img.shields.io/badge/Tool-Quartus%20II-orange.svg)]()
[![Target](https://img.shields.io/badge/Target-Cyclone%20II%20(DE2%20Kit)-red.svg)]()

## 📖 Giới thiệu đề tài (Introduction)

Đồ án này hiện thực hóa trò chơi arcade kinh điển **Brick Smash** hoàn toàn bằng phần cứng trên chip **FPGA Cyclone II (Kit Altera DE2)**, sử dụng ngôn ngữ **Verilog HDL**. 

Toàn bộ logic trò chơi, xử lý va chạm vật lý, quản lý trạng thái, đồng bộ hóa tín hiệu VGA và hiển thị điểm số đều được tính toán và xử lý trực tiếp bằng mạch logic số mà không cần sử dụng vi xử lý phần mềm (Soft-core CPU) hay hệ điều hành.

---

## 🛠️ Kiến trúc hệ thống (System Architecture)

Hệ thống được tổ chức theo mô hình phân tầng xoay quanh module trung tâm (**Top-Level**), kết nối nhịp nhàng giữa các khối chức năng ngoại vi và logic nội bộ:

```text
                  ┌──────────────────────┐
                  │  Clock 50MHz & Keys  │
                  └──────────┬───────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────┐
│                   Top-Level Module                     │
│                 (BrickSmash_DE2.v)                     │
│                                                        │
│  ┌──────────────────┐        ┌──────────────────────┐  │
│  │ clk_divider.v    │───────►│  vga_sync.v          │  │
│  │ (25MHz & 60Hz)   │        │  (640x480 @ 60Hz)    │  │
│  └────────┬─────────┘        └──────────┬───────────┘  │
│           │                             │              │
│           ▼                             ▼              │
│  ┌──────────────────┐        ┌──────────────────────┐  │
│  │  game_logic.v    │◄──────►│   image_gen.v        │  │
│  │   (FSM & Physics)│        │  (Direct Boolean/MUX)│  │
│  └────────┬─────────┘        └──────────┬───────────┘  │
│           │ score                       │ RGB          │
│           ▼                             ▼              │
│  ┌──────────────────┐             [ VGA Monitor ]      │
│  │ hex_decoder.v    │                                  │
│  └────────┬─────────┘                                  │
│           │ BCD                                        │
│           ▼                                            │
│   [ 4x 7-Segment ]                                     │
└────────────────────────────────────────────────────────┘
```

### Chi tiết các Module chính:
1. **`clk_divider.v` (Bộ chia xung):** Hạ tần số gốc 50MHz thành xung **25MHz** phục vụ xuất hình VGA (Pixel Clock) và xung **60Hz** điều khiển nhịp độ (framerate) của logic game.
2. **`vga_sync.v` (Bộ đồng bộ VGA):** Tạo các tín hiệu quét ngang (`H-Sync`) và quét dọc (`V-Sync`) theo chuẩn VESA 640x480@60Hz, đồng thời quản lý tọa độ điểm ảnh hiện hành (`pixel_x`, `pixel_y`).
3. **`game_logic.v` (Bộ não FSM & Vật lý):** 
   - Quản lý Máy trạng thái hữu hạn (**FSM**) gồm 5 trạng thái: `S_START` (Màn hình chờ), `S_DELAY` (Đếm ngược 3 giây), `S_PLAY` (Đang chơi), `S_GAMEOVER` (Thua), và `S_WIN` (Chiến thắng).
   - Quản lý 120 viên gạch bằng mảng thanh ghi 120-bit, áp dụng thuật toán *Điểm dẫn đầu (Leading Edge)* để xử lý va chạm chính xác.
   - Tự động tăng độ khó (vận tốc bóng `dx`, `dy`) khi đạt các mốc điểm 400 và 800.
4. **`image_gen.v` (Bộ xuất hình ảnh):** Hoạt động như một bộ dồn kênh (MUX) kết hợp đại số Boolean để vẽ trực tiếp thanh chèo (paddle), quả bóng (ball), lưới gạch 6 hàng nhiều màu sắc và giao diện chữ/số thông báo (Arcade Font) lên màn hình VGA mà không cần VRAM.
5. **`hex_decoder.v` (Giải mã LED 7 đoạn):** Chuyển đổi giá trị điểm số qua phép chia tách thập phân (BCD) thành mã điều khiển Active-Low để hiển thị trực tiếp lên 4 cụm LED 7 đoạn (`HEX3` - `HEX0`).
6. **`BrickSmash_DE2.v` (Top-Level Module):** Đóng vai trò bo mạch chủ kết nối toàn bộ các khối phần cứng con với các chân tín hiệu vật lý trên kit Altera DE2.

---

## 📊 Kết quả tổng hợp phần cứng (Flow Summary)

Kết quả tổng hợp từ công cụ **Quartus II 64-Bit** trên mục tiêu phần cứng **Cyclone II (EP2C35F672C6)**:

* **Total Logic Elements:** 1,660 / 33,216 (~5%)
* **Total Combinational Functions:** 1,655 / 33,216 (~5%)
* **Dedicated Logic Registers:** 231 / 33,216 (<1%)
* **Total Pins:** 68 / 475 (14%)
* **Total Memory Bits / PLLs:** 0 (Thiết kế hoàn toàn bằng mạch logic tổ hợp và thanh ghi thuần túy, tối ưu hóa tài nguyên phần cứng tối đa).

---

## 🚀 Hướng phát triển tương lai (Future Works)
* **Tích hợp VRAM / Block RAM:** Sử dụng bộ nhớ trong chip để lưu trữ các sprite đồ họa chi tiết thay vì vẽ bằng logic Boolean thuần túy.
* **Hệ thống âm thanh:** Giao tiếp với chip Audio Codec (WM8731) qua chuẩn I2C/I2S để phát hiệu ứng âm thanh va chạm.
* **Mở rộng ngoại vi:** Hỗ trợ kết nối bàn phím/chuột qua cổng PS/2 để tăng trải nghiệm điều khiển.

---

## 👥 Thông tin nhóm tác giả (Author)
* **Thành viên thực hiện:** 
Nguyễn Thanh Hiếu -Trần Quang Nhất 
* **Mã lớp học phần:** Thiết kế hệ thống số với HDL
* **Đơn vị:** Khoa Kỹ thuật Máy tính, Trường Đại học Công nghệ Thông tin, ĐHQG-HCM (UIT).

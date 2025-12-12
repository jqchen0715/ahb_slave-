// `timescale 1ns / 1ps // 定义仿真时间单位和精度 (Defines simulation time unit and precision)
//////////////////////////////////////////////////////////////////////////////////
// Company:        // 公司名称 (Company Name)
// Engineer:       // 工程师 (Engineer Name)
//
// Create Date: 2024/04/13 09:33:37 // 创建日期 (Creation Date)
// Design Name: ahb_slave_top      // 设计名称 (Design Name)
// Module Name: ahb_slave_top      // 模块名称 (Module Name)
// Project Name:                    // 项目名称 (Project Name)
// Target Devices:                  // 目标器件 (Target Devices)
// Tool Versions:                   // 工具版本 (Tool Versions)
// Description:                     // 描述 (Description)
//   (Description remains the same)
// limitations: (局限性)
//   (Limitations remain the same)
// Revision: // 修订历史 (Revision History)
//   (Revision history remains the same)
// Additional Comments: // 附加评论 (Additional Comments)
//
//////////////////////////////////////////////////////////////////////////////////
module ahb_slave_top #(
    parameter T_ADDR_WID = 14 // 参数：内部目标接口地址总线宽度。
) (
    // --- AHB Interface Ports (AHB接口端口) ---
    // (AHB Ports remain the same)
    input         hresetn,
    input         hclk,
    input         hsel,
    input  [31:0] haddr,
    input  [ 1:0] htrans,
    input         hwrite,
    input  [ 2:0] hsize,
    input  [ 2:0] hburst,
    input  [31:0] hwdata,
    output [31:0] hrdata,
    output [ 1:0] hresp,
    output        hready,

    // --- Control/Status Ports (特定于应用的控制/状态端口) ---
    // (Control/Status Ports remain the same)
    output        data_ram_ctrl,
    output        conv_ram_ctrl,
    output        apu_ready,
    input         cal_cpl,
    output        int_cal,

    // --- RAM Interface Ports ---
    // (All RAM Interface Ports remain the same)
    // --- IR RAM Interface ---
    output        ir_ram_wen,
    output [ 3:0] ir_ram_waddr,
    output [31:0] ir_ram_wdata,
    output        ir_ram_ren,
    output [ 3:0] ir_ram_raddr,
    input  [31:0] ir_ram_rdata,
    // --- Input Feature Map RAM Interface ---
    output        in_ram_wen,
    output [ 9:0] in_ram_waddr,
    output [63:0] in_ram_wdata,
    output        in_ram_ren,
    output [ 9:0] in_ram_raddr,
    input  [63:0] in_ram_rdata,
    // --- Output Feature Map RAM Interface ---
    output        out_ram_wen,
    output [ 9:0] out_ram_waddr,
    output [63:0] out_ram_wdata,
    output        out_ram_ren,
    output [ 9:0] out_ram_raddr,
    input  [63:0] out_ram_rdata,
    // --- Convolution Weight/Bias RAM Interface ---
    output [ 5:0] conv_ram_sel,
    output        conv_ram_wen,
    output [ 7:0] conv_ram_waddr,
    output [63:0] conv_ram_wdata,
    output        conv_ram_ren,
    output [ 7:0] conv_ram_raddr,
    input  [63:0] conv_ram_rdata,
    // --- Batch Normalization Parameter RAM Interface ---
    output [ 5:0] bn_ram_sel,
    output        bn_ram_wen,
    output [ 4:0] bn_ram_waddr,
    output [12:0] bn_ram_wdata,
    output        bn_ram_ren,
    output [ 4:0] bn_ram_raddr,
    input  [12:0] bn_ram_rdata
);

  // ==========================================================
  // --- 用户自定义内部信号 (User-Defined Internal Signals) ---
  // ==========================================================

   wire [T_ADDR_WID-1:0] t_waddr;
   wire [T_ADDR_WID-1:0] t_raddr;
   wire                  t_wren;
   wire                  t_rden;
   wire [          31:0] t_wdata;
   wire [          31:0] t_rdata;
   wire [          10:0] ram_raddr;
   wire [          10:0] ram_waddr;
   wire                  ram_wen;
   wire                  ram_ren;
   wire [          31:0] ram_wdata;
   wire [          31:0] ram_rdata;
   wire [           7:0] ram_sel;

  // ==========================================================
  // --- Module Instantiations (模块实例化) ---
  // ==========================================================

  // 1. Instantiate the core AHB slave logic module
  ahb_slave #(
      .T_ADDR_WID(T_ADDR_WID)
  ) ahb_slave_inst (
      // Connect AHB interface ports (保持不变)
      .hresetn(hresetn),
      .hclk   (hclk),
      .hsel   (hsel),
      .haddr  (haddr),
      .htrans (htrans),
      .hwrite (hwrite),
      .hsize  (hsize),
      .hburst (hburst),
      .hwdata (hwdata),
      .hrdata (hrdata),
      .hresp  (hresp),
      .hready (hready),

      // Connect internal target interface to wires
      .t_waddr(/* TODO: 连接 t_waddr 内部线网 */),
      .t_raddr(/* TODO: 连接 t_raddr 内部线网 */),
      .t_wren (/* TODO: 连接 t_wren 内部线网 */),
      .t_rden (/* TODO: 连接 t_rden 内部线网 */),
      .t_wdata(/* TODO: 连接 t_wdata 内部线网 */),
      .t_rdata(/* TODO: 连接 t_rdata 内部线网 */)
  );

  // 2. Instantiate the Address Mapping and Control module
  addr_map #(
      .T_ADDR_WID(T_ADDR_WID)
  ) addr_map_inst (
      .clk          (hclk),    // 时钟输入 (保持不变)
      .rstn         (hresetn), // 复位输入 (保持不变)

      // Inputs from ahb_slave's target interface
      .t_waddr      (/* TODO: 连接 t_waddr 内部线网 */),
      .t_raddr      (/* TODO: 连接 t_raddr 内部线网 */),
      .t_wren       (/* TODO: 连接 t_wren 内部线网 */),
      .t_rden       (/* TODO: 连接 t_rden 内部线网 */),
      .t_wdata      (/* TODO: 连接 t_wdata 内部线网 */),
      .t_rdata      (/* TODO: 连接 t_rdata 内部线网 */), // 输出到 ahb_slave

      // Outputs to ram_mux
      .ram_waddr    (/* TODO: 连接 ram_waddr 内部线网 */),
      .ram_raddr    (/* TODO: 连接 ram_raddr 内部线网 */),
      .ram_wen      (/* TODO: 连接 ram_wen 内部线网 */),
      .ram_ren      (/* TODO: 连接 ram_ren 内部线网 */),
      .ram_wdata    (/* TODO: 连接 ram_wdata 内部线网 */),
      .ram_rdata    (/* TODO: 连接 ram_rdata 内部线网 */), // 从 ram_mux 输入
      .ram_sel      (/* TODO: 连接 ram_sel 内部线网 */),

      // Control and Status signals connections
      .data_ram_ctrl(/* TODO: 连接 data_ram_ctrl 顶层端口 */),
      .conv_ram_ctrl(/* TODO: 连接 conv_ram_ctrl 顶层端口 */),
      .apu_ready    (/* TODO: 连接 apu_ready 顶层端口 */),//
      .cal_cpl      (/* TODO: 连接 cal_cpl 顶层端口 */),
      .int_cal      (/* TODO: 连接 int_cal 顶层端口 */)//
  );

  // 3. Instantiate the RAM Multiplexer module
  ram_mux ram_mux_inst (
      .clk           (hclk),    // 时钟输入 (保持不变)
      .rstn          (hresetn), // 复位输入 (保持不变)

      // Generic RAM Interface Inputs (from addr_map)
      .ram_waddr     (/* TODO: 连接 ram_waddr 内部线网 */),
      .ram_raddr     (/* TODO: 连接 ram_raddr 内部线网 */),
      .ram_wen       (/* TODO: 连接 ram_wen 内部线网 */),
      .ram_ren       (/* TODO: 连接 ram_ren 内部线网 */),
      .ram_wdata     (/* TODO: 连接 ram_wdata 内部线网 */),
      .ram_rdata     (/* TODO: 连接 ram_rdata 内部线网 */), // 输出到 addr_map
      .ram_sel       (/* TODO: 连接 ram_sel 内部线网 */),

      // Specific RAM Interface Outputs/Inputs (连接到顶层端口)
      // IR RAM
      .ir_ram_wen    (/* TODO: 连接 ir_ram_wen 顶层端口 */),
      .ir_ram_waddr  (/* TODO: 连接 ir_ram_waddr 顶层端口 */),
      .ir_ram_wdata  (/* TODO: 连接 ir_ram_wdata 顶层端口 */),
      .ir_ram_ren    (/* TODO: 连接 ir_ram_ren 顶层端口 */),
      .ir_ram_raddr  (/* TODO: 连接 ir_ram_raddr 顶层端口 */),
      .ir_ram_rdata  (/* TODO: 连接 ir_ram_rdata 顶层端口 */),
      // IN RAM
      .in_ram_wen    (/* TODO: 连接 in_ram_wen 顶层端口 */),
      .in_ram_waddr  (/* TODO: 连接 in_ram_waddr 顶层端口 */),
      .in_ram_wdata  (/* TODO: 连接 in_ram_wdata 顶层端口 */),
      .in_ram_ren    (/* TODO: 连接 in_ram_ren 顶层端口 */),
      .in_ram_raddr  (/* TODO: 连接 in_ram_raddr 顶层端口 */),
      .in_ram_rdata  (/* TODO: 连接 in_ram_rdata 顶层端口 */),
      // OUT RAM
      .out_ram_wen   (/* TODO: 连接 out_ram_wen 顶层端口 */),
      .out_ram_waddr (/* TODO: 连接 out_ram_waddr 顶层端口 */),
      .out_ram_wdata (/* TODO: 连接 out_ram_wdata 顶层端口 */),
      .out_ram_ren   (/* TODO: 连接 out_ram_ren 顶层端口 */),
      .out_ram_raddr (/* TODO: 连接 out_ram_raddr 顶层端口 */),
      .out_ram_rdata (/* TODO: 连接 out_ram_rdata 顶层端口 */),
      // CONV RAM
      .conv_ram_sel  (/* TODO: 连接 conv_ram_sel 顶层端口 */),
      .conv_ram_wen  (/* TODO: 连接 conv_ram_wen 顶层端口 */),
      .conv_ram_waddr(/* TODO: 连接 conv_ram_waddr 顶层端口 */),
      .conv_ram_wdata(/* TODO: 连接 conv_ram_wdata 顶层端口 */),
      .conv_ram_ren  (/* TODO: 连接 conv_ram_ren 顶层端口 */),
      .conv_ram_raddr(/* TODO: 连接 conv_ram_raddr 顶层端口 */),
      .conv_ram_rdata(/* TODO: 连接 conv_ram_rdata 顶层端口 */),
      // BN RAM
      .bn_ram_sel    (/* TODO: 连接 bn_ram_sel 顶层端口 */),
      .bn_ram_wen    (/* TODO: 连接 bn_ram_wen 顶层端口 */),
      .bn_ram_waddr  (/* TODO: 连接 bn_ram_waddr 顶层端口 */),
      .bn_ram_wdata  (/* TODO: 连接 bn_ram_wdata 顶层端口 */),
      .bn_ram_ren    (/* TODO: 连接 bn_ram_ren 顶层端口 */),
      .bn_ram_raddr  (/* TODO: 连接 bn_ram_raddr 顶层端口 */),
      .bn_ram_rdata  (/* TODO: 连接 bn_ram_rdata 顶层端口 */)
  );

endmodule
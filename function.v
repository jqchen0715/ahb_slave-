//---------------------------------------------------------
//             __    __    __    __    __    _
// clk      __|  |__|  |__|  |__|  |__|  |__|
//             _____             _____
// t_addr   xxx_____xxxxxxxxxxxxx_____xxx
//             _____
// t_rden   __|     |____________________
//                   _____
// t_rdata  xxxxxxxxx_____xxxxxxxxxxxxxxx
//                               _____
// t_wren   ____________________|     |__
//                               _____
// t_wdata  xxxxxxxxxxxxxxxxxxxxx_____xxxx
//----------------------------------------------------------
// 模块名称: addr_map
// 功能描述:
// 1. 地址映射: 将来自 AHB Slave 接口的目标地址 (t_addr) 映射到内部寄存器空间或 RAM 空间。
// 2. 寄存器访问: 处理对控制寄存器 (RAM_CTRL_ADDR)、选择寄存器 (RAM_SEL_ADDR) 和状态寄存器 (CPL_ADDR) 的读写操作。
// 3. RAM 访问信号生成: 当访问地址位于 RAM 空间时，生成传递给 RAM Mux 的读写控制信号、地址和数据。
// 4. 读数据路由: 根据读取的地址，将内部寄存器的值或来自 RAM Mux 的数据 (ram_rdata) 返回给 AHB Slave (t_rdata)。
module addr_map #(
    parameter T_ADDR_WID = 14 // 参数: AHB 地址宽度 (这里是 Slave 内部使用的地址宽度)
) (
    // --- 输入端口 ---
    input                       clk,            // 时钟信号
    input                       rstn,           // 异步复位信号 (低有效)
    input      [T_ADDR_WID-1:0] t_waddr,      // 目标写地址 (来自 ahb_slave)
    input      [T_ADDR_WID-1:0] t_raddr,      // 目标读地址 (来自 ahb_slave)
    input                       t_wren,         // 目标写使能 (来自 ahb_slave, 在 hready 为高且写传输时有效)
    input                       t_rden,         // 目标读使能 (来自 ahb_slave, 在 hready 为高且读传输时有效)
    input      [          31:0] t_wdata,      // 目标写数据 (来自 ahb_slave 的 hwdata)
    input      [          31:0] ram_rdata,    // 从 RAM Mux 读回的数据

    // --- 输出端口 ---
    output reg [          31:0] t_rdata,      // 目标读数据 (返回给 ahb_slave 的 hrdata)
    output     [          10:0] ram_waddr,    // 发往 RAM Mux 的写地址 (取 t_waddr 的中间位)
    output     [          10:0] ram_raddr,    // 发往 RAM Mux 的读地址 (取 t_raddr 的中间位)
    output                      ram_wen,        // 发往 RAM Mux 的写使能
    output                      ram_ren,        // 发往 RAM Mux 的读使能
    output     [          31:0] ram_wdata,    // 发往 RAM Mux 的写数据
    output     [           7:0] ram_sel,      // 发往 RAM Mux 的 RAM 选择信号
    output                      data_ram_ctrl,// 数据 RAM 控制信号 (来自内部控制寄存器)
    output                      conv_ram_ctrl,// 卷积 RAM 控制信号 (来自内部控制寄存器)
    output reg apu_ready,

    input       cal_cpl,       // 计算完成状态信号 (来自外部模块)
    output   int_cal
);

  // --- 内部参数定义 ---
  localparam RAM_CTRL_ADDR = 14'h2000; // RAM 控制寄存器地址
  localparam RAM_SEL_ADDR  = 14'h2004; // RAM 选择寄存器地址
  localparam APU_READY_ADDR = 14'h2008;
  localparam CPL_ADDR      = 14'h200C; // 完成状态寄存器地址


  // --- 内部信号声明 ---
  reg  [           7:0] ram_sel_reg;  // 存储 RAM 选择值的寄存器
  reg  [           1:0] ram_ctrl_reg; // 存储 RAM 控制值的寄存器
  wire                  ram_space;    // 标志位，指示当前访问地址是否在 RAM 地址空间内
  reg  [T_ADDR_WID-1:0] t_raddr_d;    // 延迟一拍的读地址，用于同步读取寄存器或 RAM 数据
  reg                   cal_cpl_r;
  reg                   cal_cpl_r_d;

  assign int_cal = cal_cpl_r;
  // --- 逻辑实现 ---
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      cal_cpl_r <= 'h0;
    end else if (cal_cpl) begin
      cal_cpl_r <= 1'b1;
    end else if(t_raddr == CPL_ADDR && t_rden == 1'b1) begin
      cal_cpl_r <= 1'b0;
    end
  end
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      cal_cpl_r_d <= 'h0;
    end else  begin
      cal_cpl_r_d <= cal_cpl_r;
    end
  end
  // 寄存器 t_raddr_d: 在 t_rden 有效时，锁存当前的读地址 t_raddr
  // 目的是为了在下一个时钟周期，根据这个锁存的地址来决定 t_rdata 的来源
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      t_raddr_d <= 'h0;
    end else if (t_rden) begin 
        // TODO当读使能有效时锁存地址
      
    end
  end

  // 根据延迟后的读地址 t_raddr_d 决定输出的读数据 t_rdata
  always @(*) begin
    if (/*TODO*/) begin// 若地址在 RAM 空间 (0x0000 - 0x1FFF)?
      t_rdata = ram_rdata; // 数据来自 RAM Mux
    end else if (t_raddr_d == RAM_CTRL_ADDR) begin
      // 地址是 RAM 控制寄存器地址
      t_rdata = /*TODO*/; // 返回控制寄存器的值 (低2位有效，高位补0)
    end else if (t_raddr_d == RAM_SEL_ADDR) begin
      // 地址是 RAM 选择寄存器地址
      t_rdata = /*TODO*/; // 返回选择寄存器的值 (低8位有效，高位补0)
    end else if (/*TODO*/) begin
      // 地址是完成状态寄存器地址
      t_rdata = {31'b0, cal_cpl_r_d}; // 返回外部输入的完成状态 (低2位有效)
    end else begin
      // 地址未定义或超出范围
      t_rdata = 32'haabbccdd; // 返回一个固定的调试值
    end
  end

  // 时序逻辑: 更新内部控制寄存器和选择寄存器
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      // 复位状态
      ram_ctrl_reg <= 'h0;
      ram_sel_reg  <= 'h0;
      apu_ready    <= 1'b0;
    end else if (t_wren) begin // 当写使能有效时
      // 检查写地址是否匹配控制寄存器地址
      if (t_waddr == RAM_CTRL_ADDR) begin
        /*TODO*/; // 更新控制寄存器 (只取低2位)
      end
      // 检查写地址是否匹配选择寄存器地址
      if (t_waddr == RAM_SEL_ADDR) begin
        /*TODO*/ // 更新选择寄存器 (只取低8位)
      end
      if (t_waddr == APU_READY_ADDR) begin
        apu_ready <= ram_wdata[0];
      end else begin
        apu_ready <= 1'b0;
      end
    end
  end

  // --- 输出信号赋值 ---

  // 判断访问地址是否在 RAM 空间 (地址小于 RAM_CTRL_ADDR)
  assign ram_space     = /*TODO*/;

  // RAM 写使能: 仅当 t_wren 有效且地址在 RAM 空间内时有效
  assign ram_wen       = /*TODO*/;
  // RAM 读使能: 仅当 t_rden 有效且地址在 RAM 空间内时有效 
  assign ram_ren       = /*TODO*/; 

  // RAM 写地址: 使用目标写地址的 [12:2] 位 (共 11 位)
  // AHB 地址是字节地址，而 RAM 通常按字寻址。这里假设 RAM 接口需要 32 位字地址。
  // t_waddr[1:0] 用于区分字内的字节，这里忽略，因为限制只支持字访问。
  // t_waddr[12:2] 提取出 11 位作为 RAM 的字地址。
  assign ram_waddr     = t_waddr[12:2];
  // RAM 读地址: 使用目标读地址的 [12:2] 位 (共 11 位)
  assign ram_raddr     = t_raddr[12:2];

  // RAM 写数据: 直接传递目标写数据
  assign ram_wdata     = t_wdata;

  // 输出控制信号: 来自内部控制寄存器
  assign data_ram_ctrl = ram_ctrl_reg[0];
  assign conv_ram_ctrl = ram_ctrl_reg[1];

  // 输出 RAM 选择信号: 来自内部选择寄存器
  assign ram_sel       = ram_sel_reg;

endmodule


// 模块名称: ram_mux
// 功能描述:
// 1. RAM 多路选择器: 根据输入的 ram_sel 信号，将来自 addr_map 的 RAM 访问请求路由到具体的物理 RAM 块 (IR, IN, OUT, CONV, BN)。
// 2. 数据宽度适配: 处理 32 位 AHB 访问与不同宽度 RAM (如 64 位 IN/OUT/CONV RAM, 13 位 BN RAM) 之间的转换。
//    - 对于 64 位写: 分两次 32 位写入，通过 ram_waddr[0] 区分高低 32 位，内部寄存器 ram_wdata_r 暂存低 32 位。
//    - 对于 64 位读: 根据 ram_raddr[0] (延迟后为 ram_raddr_d[0]) 选择返回高 32 位或低 32 位给 ram_rdata。
//    - 对于 13 位 BN RAM: 写入时取 ram_wdata 低 13 位，读取时将 13 位数据零扩展到 32 位。
// 3. 地址映射: 将来自 addr_map 的 11 位 ram_waddr/ram_raddr 进一步映射到各 RAM 的具体地址位。
module ram_mux (
    // --- 输入端口 ---
    input             clk,            // 时钟信号
    input             rstn,           // 异步复位信号 (低有效)
    input      [10:0] ram_waddr,    // 来自 addr_map 的 RAM 写地址 (11 位)
    input      [10:0] ram_raddr,    // 来自 addr_map 的 RAM 读地址 (11 位)
    input             ram_wen,        // 来自 addr_map 的 RAM 写使能
    input             ram_ren,        // 来自 addr_map 的 RAM 读使能
    input      [31:0] ram_wdata,    // 来自 addr_map 的 RAM 写数据 (32 位)
    input      [ 7:0] ram_sel,      // 来自 addr_map 的 RAM 选择信号

    // --- 输出端口 ---
    output reg [31:0] ram_rdata,    // 复用后的读数据，返回给 addr_map (32 位)

    // --- IR RAM 接口 --- (Instruction RAM, 假设是 16x32bit)
    output            ir_ram_wen,     // IR RAM 写使能
    output     [ 3:0] ir_ram_waddr,   // IR RAM 写地址 (4 位)
    output     [31:0] ir_ram_wdata,   // IR RAM 写数据 (32 位)
    output            ir_ram_ren,     // IR RAM 读使能
    output     [ 3:0] ir_ram_raddr,   // IR RAM 读地址 (4 位)
    input      [31:0] ir_ram_rdata,   // 从 IR RAM 读回的数据

    // --- IN RAM 接口 --- (Input Feature Map RAM, 假设是 1024x64bit)
    output            in_ram_wen,     // IN RAM 写使能 (对应 64 位写完成)
    output     [ 9:0] in_ram_waddr,   // IN RAM 写地址 (10 位)
    output     [63:0] in_ram_wdata,   // IN RAM 写数据 (64 位)
    output            in_ram_ren,     // IN RAM 读使能
    output     [ 9:0] in_ram_raddr,   // IN RAM 读地址 (10 位)
    input      [63:0] in_ram_rdata,   // 从 IN RAM 读回的数据

    // --- OUT RAM 接口 --- (Output Feature Map RAM, 假设是 1024x64bit)
    output            out_ram_wen,    // OUT RAM 写使能 (对应 64 位写完成)
    output     [ 9:0] out_ram_waddr,  // OUT RAM 写地址 (10 位)
    output     [63:0] out_ram_wdata,  // OUT RAM 写数据 (64 位)
    output            out_ram_ren,    // OUT RAM 读使能
    output     [ 9:0] out_ram_raddr,  // OUT RAM 读地址 (10 位)
    input      [63:0] out_ram_rdata,  // 从 OUT RAM 读回的数据

    // --- CONV RAM 接口 --- (Convolution Weight/Bias RAM, 假设有 64 组, 每组 256x64bit)
    output     [ 5:0] conv_ram_sel,   // CONV RAM 组选择 (6 位)
    output            conv_ram_wen,   // CONV RAM 写使能 (对应 64 位写完成)
    output     [ 7:0] conv_ram_waddr, // CONV RAM 写地址 (8 位)
    output     [63:0] conv_ram_wdata, // CONV RAM 写数据 (64 位)
    output            conv_ram_ren,   // CONV RAM 读使能
    output     [ 7:0] conv_ram_raddr, // CONV RAM 读地址 (8 位)
    input      [63:0] conv_ram_rdata, // 从 CONV RAM 读回的数据

    // --- BN RAM 接口 --- (Batch Normalization Parameter RAM, 假设有 64 组, 每组 16x13bit)
    output     [ 5:0] bn_ram_sel,     // BN RAM 组选择 (6 位)
    output            bn_ram_wen,     // BN RAM 写使能
    output     [ 4:0] bn_ram_waddr,   // BN RAM 写地址 (5 位)
    output     [12:0] bn_ram_wdata,   // BN RAM 写数据 (13 位)
    output            bn_ram_ren,     // BN RAM 读使能
    output     [ 4:0] bn_ram_raddr,   // BN RAM 读地址 (5 位)
    input      [12:0] bn_ram_rdata    // 从 BN RAM 读回的数据
);

  // --- 内部信号声明 ---
  reg [31:0] ram_wdata_r; // 寄存器，用于暂存 64 位写操作的第一个 32 位数据 (低位)
  reg [10:0] ram_raddr_d; // 寄存器，延迟一拍的 RAM 读地址，用于同步选择 64 位读操作的高低位

  // --- 逻辑实现 ---

  // 时序逻辑: 暂存 64 位写操作的低 32 位数据
  // 当 ram_wen 有效且 ram_waddr[0] 为 0 时 (表示是 64 位写操作的第一拍，写入低 32 位)
  // 将 ram_wdata 存入 ram_wdata_r
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      ram_wdata_r <= 'h0;
    end else if (ram_wen & (!ram_waddr[0])) begin // 第一个 32 位写 (地址最低位为 0)
      ram_wdata_r <= ram_wdata;
    end
  end

  // 时序逻辑: 延迟 RAM 读地址
  // 当 ram_ren 有效时，锁存当前的 ram_raddr 到 ram_raddr_d
  // 目的是让 ram_rdata 的多路选择逻辑使用与实际 RAM 读取数据对应的地址进行判断
  always @(posedge clk or negedge rstn) begin
    /*TODO*/
  end
//************************************************************************
//此处assign语句为思考题部分，无需改动，请阅读理解并绘出电路示意图，代码注释仅供参考
  // --- RAM 选择译码 ---
  wire bn_sel;   // 标志位: 当前选中 BN RAM 组
  wire conv_sel; // 标志位: 当前选中 CONV RAM 组

  // 根据 ram_sel 的高两位判断是否选中 BN RAM 组 (00xx_xxxx)
  assign bn_sel         = (ram_sel[7:6] == 2'b00) ? 1'b1 : 1'b0;
  // BN RAM 组内选择信号: 直接使用 ram_sel 的低 6 位
  assign bn_ram_sel     = ram_sel[5:0];
  // BN RAM 写使能: 仅当选中 BN RAM 组且 ram_wen 有效时
  assign bn_ram_wen     = bn_sel ? ram_wen : 1'b0;
  // BN RAM 写地址: 使用 ram_waddr 的低 5 位
  assign bn_ram_waddr   = bn_sel ? ram_waddr[4:0] : 'h0;
  // BN RAM 写数据: 使用 ram_wdata 的低 13 位
  assign bn_ram_wdata   = bn_sel ? ram_wdata[12:0] : 'h0;
  // BN RAM 读使能: 仅当选中 BN RAM 组且 ram_ren 有效时
  assign bn_ram_ren     = bn_sel ? ram_ren : 'h0;
  // BN RAM 读地址: 使用 ram_raddr 的低 5 位
  assign bn_ram_raddr   = bn_sel ? ram_raddr[4:0] : 'h0;

  // 根据 ram_sel 的高两位判断是否选中 CONV RAM 组 (01xx_xxxx)
  assign conv_sel       = (ram_sel[7:6] == 2'b01) ? 1'b1 : 1'b0;
  // CONV RAM 组内选择信号: 直接使用 ram_sel 的低 6 位
  assign conv_ram_sel   = ram_sel[5:0];
  // CONV RAM 写使能: 仅当选中 CONV RAM 组, ram_wen 有效, 且是 64 位写的第二拍 (ram_waddr[0] == 1) 时有效
  assign conv_ram_wen   = conv_sel ? (ram_wen & ram_waddr[0]) : 1'b0;
  // CONV RAM 写地址: 使用 ram_waddr 的 [8:1] 位 (8 位地址)
  assign conv_ram_waddr = conv_sel ? ram_waddr[8:1] : 'h0;
  // CONV RAM 写数据: 组合当前拍的 ram_wdata (高 32 位) 和上一拍暂存的 ram_wdata_r (低 32 位) 形成 64 位数据
  assign conv_ram_wdata = conv_sel ? {ram_wdata, ram_wdata_r} : 'h0;
  // CONV RAM 读使能: 仅当选中 CONV RAM 组且 ram_ren 有效时
  assign conv_ram_ren   = conv_sel ? ram_ren : 1'b0;
  // CONV RAM 读地址: 使用 ram_raddr 的 [8:1] 位
  assign conv_ram_raddr = conv_sel ? ram_raddr[8:1] : 'h0;

  // IN RAM 访问控制 (当 ram_sel == 8'd128, 即 1000_0000)
  // IN RAM 写使能: 仅当选中 IN RAM, ram_wen 有效, 且是 64 位写的第二拍 (ram_waddr[0] == 1) 时有效
  assign in_ram_wen     = (ram_sel == 8'd128) ? (ram_wen & ram_waddr[0]) : 1'b0;
  // IN RAM 写地址: 使用 ram_waddr 的 [10:1] 位 (10 位地址)
  assign in_ram_waddr   = (ram_sel == 8'd128) ? ram_waddr[10:1] : 'h0;
  // IN RAM 写数据: 组合当前拍的 ram_wdata (高 32 位) 和上一拍暂存的 ram_wdata_r (低 32 位) 形成 64 位数据
  assign in_ram_wdata   = (ram_sel == 8'd128) ? {ram_wdata, ram_wdata_r} : 'h0;
  // IN RAM 读使能: 仅当选中 IN RAM 且 ram_ren 有效时
  assign in_ram_ren     = (ram_sel == 8'd128) ? ram_ren : 1'b0;
  // IN RAM 读地址: 使用 ram_raddr 的 [10:1] 位
  assign in_ram_raddr   = (ram_sel == 8'd128) ? ram_raddr[10:1] : 'h0;

  // OUT RAM 访问控制 (当 ram_sel == 8'd129, 即 1000_0001)
  // OUT RAM 写使能: 仅当选中 OUT RAM, ram_wen 有效, 且是 64 位写的第二拍 (ram_waddr[0] == 1) 时有效
  assign out_ram_wen    = (ram_sel == 8'd129) ? (ram_wen & ram_waddr[0]) : 1'b0;
  // OUT RAM 写地址: 使用 ram_waddr 的 [10:1] 位 (10 位地址)
  assign out_ram_waddr  = (ram_sel == 8'd129) ? ram_waddr[10:1] : 'h0;
  // OUT RAM 写数据: 组合当前拍的 ram_wdata (高 32 位) 和上一拍暂存的 ram_wdata_r (低 32 位) 形成 64 位数据
  assign out_ram_wdata  = (ram_sel == 8'd129) ? {ram_wdata, ram_wdata_r} : 'h0;
  // OUT RAM 读使能: 仅当选中 OUT RAM 且 ram_ren 有效时
  assign out_ram_ren    = (ram_sel == 8'd129) ? ram_ren : 1'b0;
  // OUT RAM 读地址: 使用 ram_raddr 的 [10:1] 位
  assign out_ram_raddr  = (ram_sel == 8'd129) ? ram_raddr[10:1] : 'h0;

  // IR RAM 访问控制 (当 ram_sel == 8'd130, 即 1000_0010)
  // IR RAM 写使能: 仅当选中 IR RAM 且 ram_wen 有效时 (IR RAM 是 32 位，直接写)
  assign ir_ram_wen     = (ram_sel == 8'd130) ? ram_wen : 1'b0;
  // IR RAM 写地址: 使用 ram_waddr 的低 4 位
  assign ir_ram_waddr   = (ram_sel == 8'd130) ? ram_waddr[3:0] : 'h0;
  // IR RAM 写数据: 直接使用 ram_wdata (32 位)
  assign ir_ram_wdata   = (ram_sel == 8'd130) ? ram_wdata : 'h0;
  // IR RAM 读使能: 仅当选中 IR RAM 且 ram_ren 有效时
  assign ir_ram_ren     = (ram_sel == 8'd130) ? ram_ren : 'h0;
  // IR RAM 读地址: 使用 ram_raddr 的低 4 位
  assign ir_ram_raddr   = (ram_sel == 8'd130) ? ram_raddr[3:0] : 'h0;
//此处assign语句为思考题部分，无需改动，请阅读理解并绘出电路示意图，代码注释仅供参考
//************************************************************************

  // 组合逻辑: 根据选择的 RAM 和读地址，将对应 RAM 的读数据发送回 addr_map
  always @(*) begin
    if (bn_sel) begin
      // 选中 BN RAM: 返回 BN RAM 读数据，前位补零，扩展到 32 位
      ram_rdata = /*TODO*/; // bn_ram_rdata 是 13 位
    end 
    else if (conv_sel) begin
      // 选中 CONV RAM (64 位):，根据延迟后的读地址最低位选择高/低 32 位
      ram_rdata = (!ram_raddr_d[0]) ? conv_ram_rdata[31:0] : conv_ram_rdata[63:32];
    end 
    else if (ram_sel == 8'd128) begin // 选中 IN RAM (64 位)，根据延迟后的读地址最低位选择高/低 32 位
        if (!ram_raddr_d[0]) begin // 地址最低位为 0, 读in_ram_rdata低 32 位；地址最低位为 1, 读高 32 位
            /*TODO*/
        end
    end 
    else if (ram_sel == 8'd129) begin // 选中 OUT RAM (64 位),根据延迟后的读地址最低位选择高/低 32 位
        if (!ram_raddr_d[0]) begin //同上
            /*TODO*/
        end
    end 
    else if (ram_sel == 8'd130) begin // 选中 IR RAM (32 位)
      // 直接返回 IR RAM 读数据
      ram_rdata = ir_ram_rdata;
    end 
    else begin
      // 未选中任何已定义的 RAM 或 ram_sel 无效
      ram_rdata = 'h0; // 返回 0
    end
  end

endmodule
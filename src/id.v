`include "../inc/defines.v"

module id (
        input   wire                    rst,
        input   wire[`InstAddrBus]      pc_i,
        input   wire[`InstBus]          inst_i,

        input   wire[`RegBus]           reg1_data_i,
        input   wire[`RegBus]           reg2_data_i,

        output  reg                     reg1_read_o,
        output  reg                     reg2_read_o,
        output  reg[`RegAddrBus]        reg1_addr_o,
        output  reg[`RegAddrBus]        reg2_addr_o,

        output  reg[`AluOpBus]          aluop_o,
        output  reg[`AluSelBus]         alusel_o,
        output  reg[`RegBus]            reg1_o,
        output  reg[`RegBus]            reg2_o,
        output  reg[`RegAddrBus]        waddr_o,
        output  reg                     wreg_o,

        // Execte stage produce data
        input   wire                    ex_wreg_i,
        input   wire[`RegBus]           ex_wdata_i,
        input   wire[`RegAddrBus]       ex_waddr_i,

        // Memory stage produce data
        input   wire                    mem_wreg_i,
        input   wire[`RegBus]           mem_wdata_i,
        input   wire[`RegAddrBus]       mem_waddr_i
);

wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];

reg[`RegBus]    imm;

reg instvalid;

always @(*)begin
        if(rst == `RstEnable) begin
                aluop_o = `EXE_NOP_OP;
                alusel_o = `EXE_RES_NOP;
                waddr_o = `NOPRegAddr;
                wreg_o = `WriteDisable;
                instvalid = `InstValid;
                reg1_read_o = `ReadDisable;
                reg2_read_o = `ReadDisable;
                reg1_addr_o = `NOPRegAddr;
                reg2_addr_o = `NOPRegAddr;
                imm = 32'h0;
        end else begin
                aluop_o = `EXE_NOP_OP;
                alusel_o = `EXE_RES_NOP;
                waddr_o = inst_i[15:11];
                wreg_o = `WriteDisable;
                instvalid = `InstInvalid;
                reg1_read_o = `ReadDisable;
                reg2_read_o = `ReadDisable;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                imm = `ZeroWord;

                case(op)
                        `EXE_ORI: begin
                                wreg_o = `WriteEnable;
                                aluop_o = `EXE_OR_OP;
                                alusel_o = `EXE_RES_LOGIC;
                                reg1_read_o = `ReadEnable;
                                reg2_read_o = `ReadDisable;
                                imm = {16'h0, inst_i[15:0]};
                                waddr_o = inst_i[20:16];
                                instvalid = `InstValid;
                        end
                        default: begin
                        end
                endcase
        end
end

always @(*) begin
        if(rst == `RstEnable) begin
                reg1_o = `ZeroWord;
        end else if( (reg1_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_waddr_i == reg1_addr_o) ) begin
                // A instruction write the register data in execte stage, if other instruction need the register data in decode stage
                reg1_o = ex_wdata_i;
        end else if( (reg1_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_waddr_i == reg1_addr_o) ) begin
                // The same as above
                reg1_o = mem_wdata_i;
        end else if(reg1_read_o == `ReadEnable) begin
                reg1_o = reg1_data_i;
        end else if(reg1_read_o == `ReadDisable) begin
                reg1_o = imm;
        end else begin
                reg1_o = `ZeroWord;
        end
end

always @(*) begin
        if(rst == `RstEnable) begin
                reg2_o = `ZeroWord;
        end else if( (reg2_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_waddr_i == reg2_addr_o) ) begin
                // A instruction write the register data in execte stage, if other instruction need the register data in decode stage
                reg2_o = ex_wdata_i;
        end else if( (reg2_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_waddr_i == reg2_addr_o) ) begin
                // The same as above
                reg2_o = mem_wdata_i;
        end else if(reg2_read_o == `ReadEnable) begin
                reg2_o = reg2_data_i;
        end else if(reg2_read_o == `ReadDisable) begin
                reg2_o = imm;
        end else begin
                reg2_o = `ZeroWord;
        end
end

endmodule
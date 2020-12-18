`include "../inc/defines.v"

module inst_mem (
    input   wire                    ce,
    input   wire[`InstAddrBus]      addr,
    output  reg[`InstBus]           inst
);

reg[`InstBus]   mem[0:`InstMemNum-1];

initial begin
    $readmemh ("./mem/inst.mem", mem);
    //inst_mem[0] = 32'h34011100;
    //inst_mem[1] = 32'h34020020;
    //inst_mem[2] = 32'h3403ff00;
    //inst_mem[3] = 32'h3404ffff;
end

always @(*) begin
    if(ce == `ChipDisable) begin
        inst = `ZeroWord;
    end else begin
        inst = mem[addr[`InstMemNumLog2+1 : 2]];
    end
end

endmodule
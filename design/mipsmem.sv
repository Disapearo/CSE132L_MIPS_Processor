
module dmem(input  logic        ref_clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);
`ifdef sim
  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge ref_clk)
    if (we)
      RAM[a[31:2]] <= wd;
`else

   SRAM1RW512x32 RAM (
			.A(a[8:0]),
			.CE(1'b1),
			.WEB(~we),
			.OEB(we),
			.CSB(1'b0),
			.I(wd),
			.O(rd)
			);


`endif
endmodule


module basicgates (
    an,
    o,
    nt,
    xr,
    xnr,
    a,
    b
);
  input a, b;
  output an, o, nt, xr, xnr;
  and a1 (an, a, b);
  or o1 (o, a, b);
  not n1 (nt, a);
  xor x1 (xr, a, b);
  xnor xn1 (xnr, a, b);
endmodule

module basicgates_tb ();
  wire an, o, nt, xr, xnr;
  reg a, b;
  basicgates dut (
      an,
      o,
      nt,
      xr,
      xnr,
      a,
      b
  );
  initial begin
    a = 1'b0;
    b = 1'b0;
    #5 a = 1'b0;
    b = 1'b1;
    #5 a = 1'b1;
    b = 1'b0;
    #5 a = 1'b1;
    b = 1'b1;
  end
endmodule

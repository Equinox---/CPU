module arithtb;
    reg[31:0]A=32'd0,B=32'd0;
    wire [31:0]S;
    reg[5:0]ALUFun=6'b0;
    reg Sign=0;
    wire Z,V,N;
    integer true;
    arith aritb1(A, B, ALUFun, Sign, S, Z, V, N);
    always #50 ALUFun[0]=~ALUFun[0];
    always begin
        #50 true=A-B;
        #50 true=A+B;
    end        
    always begin
        #100 A=$random;
        B=$random;
    end
endmodule

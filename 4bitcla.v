module adder4cla(s,co,a,b,cin);
    input cin;
    input [3:0]a, b;
    output [3:0]s;
    output co;
    wire g0,g1,g2,g3,p0,p1,p2,p3,co0,co1,co2;
    wire t0,t1,t2,t3,r0,r1,s0,s1,s2,q;
    and(g0,a[0],b[0]);
    and(g1,a[1],b[1]);
    and(g2,a[2],b[2]);
    and(g3,a[3],b[3]);
    xor(p0,a[0],b[0]);
    xor(p1,a[1],b[1]);
    xor(p2,a[2],b[2]);
    xor(p3,a[3],b[3]);
    and(t0, p3, g2);
    and(t1,p3,p2,g1);
    and(t2,p3,p2,p1,g0);
    and(t3,p3,p2,p1,p0,cin);
    and(s0,p2,g1);
    and(s1,p2,p1,g0);
    and(s2,p2,p1,p0,cin);
    and(r0,p1,g0);
    and(r1,p1,p0,cin);
    and(q,p0,cin);
    or(co0,q,g0);
    or(co1,g1,r0,r1);
    or(co2,g2,s0,s1,s2);
    or(co,g3,t0,t1,t2,t3);
    xor(s[0],p0,cin);
    xor(s[1],p1,co0);
    xor(s[2],p2,co1);
    xor(s[3],p3,co2);
endmodule

// advanced digital project
// Name: Masa Ahmad Ali Jalamneh
// Id: 1212145
// Section: 3
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////

module fulladd (c_in, x, y, s, c_out);
  input c_in, x, y;
  output s, c_out;
  
  assign s = x ^ y ^ c_in;
  assign c_out = (x & y) | (x & c_in) | (y & c_in);
       
endmodule


///////////////////////////////////
///////////////////////////////////

module adder(X, Y, S);
  input [31:0] X;
  input [31:0] Y;
  output [31:0] S;

  wire [32:0] C;
  genvar i;
 
  assign C[0] = 1'b0;

  generate
    for (i = 0; i <= 31; i = i + 1) 
      begin : addbit 
        fulladd add (.c_in(C[i]), .x(X[i]), .y(Y[i]), .s(S[i]), .c_out(C[i+1]));
      end
  endgenerate

endmodule


///////////////////////////////////
///////////////////////////////////

module subtractor(X1, Y1, S1);
  input [31:0] X1, Y1;
  output [31:0] S1;

  wire [32:0] C;
  genvar i;

  assign C[0] = 1'b1;

  generate
    for (i = 0; i <= 31; i = i + 1) 
      begin : addbit 
        fulladd sub (.c_in(C[i]), .x(X1[i]), .y(~Y1[i]), .s(S1[i]), .c_out(C[i+1]));
      end
  endgenerate

endmodule

///////////////////////////////////
///////////////////////////////////

module absolute(in, result);
  input signed [31:0] in;
  output reg [31:0] result;
  always @(in)begin
    if(in < 0) begin
        assign result = - in ; 
    end
  else
    begin
      assign result = in;
    end
  end
endmodule

///////////////////////////////////
///////////////////////////////////

module negative_multiplication(in, result);
  input signed [31:0] in;
  output reg [31:0] result;
  always @(in)begin
     
    assign result = - in ; 
    
  end
endmodule

///////////////////////////////////
///////////////////////////////////

module maximum(A, B, result);
  input [31:0] A, B;
  output reg [31:0] result;
  
  reg [31:0] sub_value;
  subtractor sub1(.X1(A), .Y1(B), .S1(sub_value));
  
  always @(A, B)begin
    if(sub_value < 0) begin
       assign  result = B ; 
    end
    else begin
      assign result = A;
    end 
  end
endmodule

///////////////////////////////////
///////////////////////////////////

module minimum(A, B, result);
  input [31:0] A, B;
  output reg [31:0] result;
  
  reg signed [31:0] sub_value;
  subtractor sub1(.X1(A), .Y1(B), .S1(sub_value));
  
  always @(A, B)begin
    if(sub_value < 0) begin
       assign  result = A ; 
    end
    else begin
      assign result = B;
    end 
  end
endmodule

///////////////////////////////////
///////////////////////////////////

module alu (opcode, a, b, result );
  input [5:0] opcode;
  input [31:0] a;
  input [31:0] b;
  output reg [31:0] result;
  
  // operations results (local registers)
  reg [31:0] adder_result, subtractor_result, abs_result, neg_result, max_result, min_result, 	avg_result, not_a_result, or_result, and_result, xor_result ;
  // operations  : 
   adder adder_inst (.X(a), .Y(b), .S(adder_result));              // call adder module
   subtractor sub_inst (.X1(a), .Y1(b), .S1(subtractor_result));   // call sbutractor module 
   absolute abs_inst (.in(a),.result(abs_result));                 // call absolute module
   assign neg_result = - a;                                        // negative multiplication 
   maximum max (.A(a), .B(b), .result(max_result));                // call maximum module
   minimum min (.A(a), .B(b), .result(min_result));                // call minimum module
   assign avg_result= (adder_result / 2);                          // average operation 
   assign not_a_result[31:0]= ~a[31:0];                            // NOT a operation 
   assign or_result[31:0] = a[31:0] | b[31:0];                     // OR a,b operation 
   assign and_result[31:0]= a[31:0] & b[31:0];                     // AND a,b operation 
   assign xor_result[31:0]= a[31:0] ^ b[31:0];                     // XOR a,b operation 
   
  always @(a, b)
    begin 
      case({opcode}) 
        6'b000011: assign result = adder_result;         // opcode= 3 => a+b
        6'b001111: assign result = subtractor_result;    // opcode=15 => a-b
        6'b001101: assign result = abs_result;           // opcode=13 => |a|
        6'b001100: assign result = neg_result;           // opcode=12 => -a
        6'b000111: assign result = max_result;           // opcode= 7 => max(a,b)
        6'b000001: assign result = min_result;           // opcode= 1 => min(a,b)
        6'b001001: assign result = avg_result;           // opcode= 9 => avg(a,b)
        6'b001010: assign result = not_a_result;         // opcode=10 => not(a)
        6'b001110: assign result = or_result;            // opcode=14 => a / b
        6'b001011: assign result = and_result;           // opcode=11 => a & b
        6'b000101: assign result = xor_result;           // opcode= 5 => a ^ b
	    default:   assign result = 32'hxxxxxxxx;		 // otherwise => invalid opcode => dont care
        endcase 
      end
endmodule

///////////////////////////////////
///////////////////////////////////

module reg_file (clk, valid_opcode, addr1, addr2, addr3, in , out1, out2);
 input clk;
 input valid_opcode;
 input [4:0] addr1, addr2, addr3;
 input [31:0] in;
 output reg [31:0] out1, out2;
  
  reg [4:0] ID [31:0];
  reg [31:0] item [31:0]; 
 
 ////// The initial values stored in the reg_file: 
  initial 
    begin 
      ID[0]  = 5'b00000;  item[0]  = 32'h00000000;   //0  -> d: 0     // h:0
      ID[1]  = 5'b00001;  item[1]  = 32'h00001066;   //1  -> d: 4198  // h:1066
      ID[2]  = 5'b00010;  item[2]  = 32'h000015dc;   //2  -> d: 5596  // h:15dc
      ID[3]  = 5'b00011;  item[3]  = 32'h0000385a;   //3  -> d: 14426 // h:385a
      ID[4]  = 5'b00100;  item[4]  = 32'h00001dbc;   //4  -> d: 7612  // h:1dbc
      ID[5]  = 5'b00101;  item[5]  = 32'h000019ee;   //5  -> d: 6638  // h:19ee
      ID[6]  = 5'b00110;  item[6]  = 32'h00002738;   //6  -> d: 10040 // h:2738
      ID[7]  = 5'b00111;  item[7]  = 32'h00000f5a;   //7  -> d: 3930  // h:f5a
      ID[8]  = 5'b01000;  item[8]  = 32'h00001036;   //8  -> d: 4150  // h:1036
      ID[9]  = 5'b01001;  item[9]  = 32'h00001906;   //9  -> d: 6406  // h:1906
      ID[10] = 5'b01010;  item[10] = 32'h00001518;   //10 -> d: 5400  // h:1518
      ID[11] = 5'b01011;  item[11] = 32'h0000127c;   //11 -> d: 8572  // h:217c
      ID[12] = 5'b01100;  item[12] = 32'h00003fc4;   //12 -> d: 16324 // h:3fc4
      ID[13] = 5'b01101;  item[13] = 32'h00002288;   //13 -> d: 8840  // h:2288
      ID[14] = 5'b01110;  item[14] = 32'h00002042;   //14 -> d: 8258  // h:2042
      ID[15] = 5'b01111;  item[15] = 32'h00002bdc;   //15 -> d: 11228 // h:2bdc
      ID[16] = 5'b10000;  item[16] = 32'h0000210e;   //16 -> d: 8462  // h:210e
      ID[17] = 5'b10001;  item[17] = 32'h000033e4;   //17 -> d:13284  // h:33e4
      ID[18] = 5'b10010;  item[18] = 32'h00001244;   //18 -> d: 4676  // h:1244
      ID[19] = 5'b10011;  item[19] = 32'h00000f8c;   //19 -> d: 3980  // h:f8c
      ID[20] = 5'b10100;  item[20] = 32'h00001602;   //20 -> d: 5634  // h:1602
      ID[21] = 5'b10101;  item[21] = 32'h00001dd0;   //21 -> d: 7632  // h:1dd0
      ID[22] = 5'b10110;  item[22] = 32'h00002676;   //22 -> d: 9846  // h:2676
      ID[23] = 5'b10111;  item[23] = 32'h00001542;   //23 -> d: 5442  // h:1542
      ID[24] = 5'b11000;  item[24] = 32'h000030c8;   //24 -> d: 12488 // h:30c8
      ID[25] = 5'b11001;  item[25] = 32'h00001a00;   //25 -> d: 6656  // h:1a00
      ID[26] = 5'b11010;  item[26] = 32'h00000340;   //26 -> d: 832   // h:340
      ID[27] = 5'b11011;  item[27] = 32'h00001238;   //27 -> d: 4664  // h:1238
      ID[28] = 5'b11100;  item[28] = 32'h00001a8e;   //28 -> d: 6798  // h:1a8e
      ID[29] = 5'b11101;  item[29] = 32'h00003756;   //29 -> d: 14166 // h:3756
      ID[30] = 5'b11110;  item[30] = 32'h00000cae;   //30 -> d: 3246  // h:cae
      ID[31] = 5'b11111;  item[31] = 32'h00000000;   //31 -> d: 0     // h:0
        
  end
 ////// End of initial values.
    
  always @( posedge clk, valid_opcode, addr1, addr2, addr3, in ) begin
    
     if (valid_opcode) begin  

      
       for (int i = 0; i <= 31; i = i + 1)begin 
         
             if (addr1 == ID[i]) begin
               out1 <= item[i];
              end
             if (addr2 == ID[i]) begin
               out2 <= item[i];
              end
             if (addr3 == ID[i]) begin
               #10
               item[i] <= in;
             end
       end
        
    end 
    else begin 
     	 out1 <= 32'hxxxxxxxx;
     	 out2 <= 32'hxxxxxxxx;
    end
 
  end


  
endmodule

///////////////////////////////////
///////////////////////////////////

module mp_top (clk, instruction , result);
 input clk;
 input [31:0] instruction;
 output reg [31:0] result;
  
  
   reg [5:0] opcode;				// as input for the alu module
   reg valid_opcode;       				// as Enable for the reg_file module
   reg [4:0] addr1, addr2, addr3; // as inputs for the reg_file module
   reg [31:0] reg_out1, reg_out2, reg_in;// as outputs from the reg_file module inputs for the alu module
  
  
   reg [5:0] stored_opcodes [10:0]; // to check the validity (work as Enable)
   initial begin
    stored_opcodes[0]  =  6'b000011 ;
    stored_opcodes[1]  =  6'b001111 ;
    stored_opcodes[2]  =  6'b001101 ;
    stored_opcodes[3]  =  6'b001100 ;
    stored_opcodes[4]  =  6'b000111 ;
    stored_opcodes[5]  =  6'b000001 ;
    stored_opcodes[6]  =  6'b001001 ;
    stored_opcodes[7]  =  6'b001010 ;
    stored_opcodes[8]  =  6'b001110 ;
    stored_opcodes[9]  =  6'b001011 ;
    stored_opcodes[10] =  6'b000101 ;
   end 
  
   reg_file r_f (
      .clk(clk),
      .valid_opcode(valid_opcode),
      .addr1(addr1),
      .addr2(addr2),
      .addr3(addr3),
      .in(reg_in),
      .out1(reg_out1),
      .out2(reg_out2)
    );
    
   alu alu1 ( 
      .opcode(opcode),
      .a(reg_out1),
      .b(reg_out2),
      .result(reg_in)
  	);
    
  
  
  always @(posedge clk, instruction)begin
    
    opcode <= instruction[5:0];
    valid_opcode <= 1'b0;

    for (int i = 0; i <= 10; i = i + 1)begin 
         
       if (opcode == stored_opcodes[i]) begin
               valid_opcode <= 1'b1;
       end
       
     end 
    
    addr1 <= instruction[10:6];
    addr2 <= instruction[15:11];
    
    addr3 <= instruction[20:16];
    #10
    result = reg_in;
   
  end 

endmodule      
   
///////////////////////////////////
///////////////////////////////////

//
//
// end of design module
//
//
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//
//
// testbench code begin here:
//
//

///////////////////////////////////
///////////////////////////////////
module testbench();
  
  //-----------------------------//
  //-----------------------------//
  reg [5:0] stored_opcodes [10:0]; // to check the opcodes validity (print with instructions)
  initial begin
    stored_opcodes[0]  =  6'b000011 ;
    stored_opcodes[1]  =  6'b001111 ;
    stored_opcodes[2]  =  6'b001101 ;
    stored_opcodes[3]  =  6'b001100 ;
    stored_opcodes[4]  =  6'b000111 ;
    stored_opcodes[5]  =  6'b000001 ;
    stored_opcodes[6]  =  6'b001001 ;
    stored_opcodes[7]  =  6'b001010 ;
    stored_opcodes[8]  =  6'b001110 ;
    stored_opcodes[9]  =  6'b001011 ;
    stored_opcodes[10] =  6'b000101 ;
  end 
  //-----------------------------//
  //-----------------------------//
  
  //----signals declaration for connecting design module----//
  reg clk;
  reg [31:0] instruction;
  wire [31:0] result;
  reg [5:0] opcode;
  reg [31:0] expected_result [13:0];
  reg valid_opcode;
  reg pass;
  
  //----design module----//
  mp_top uut (
    .clk(clk),
    .instruction(instruction),
    .result(result)
      );

  //-----------------------------//
  //-----------------------------//
  reg [31:0] instructions_array [13:0];
  initial begin
    instructions_array[0]= 32'h00000000; expected_result[0]= 32'hXXXXXXXX;   //invalid
    instructions_array[1]= 32'h001f1043; expected_result[1]= 32'h00002642;   // +
    instructions_array[2]= 32'h00001841; expected_result[2]= 32'h00001066;   // min()
    instructions_array[3]= 32'h00047a85; expected_result[3]= 32'h00003ec4;   // XOR
    instructions_array[4]= 32'h00047a88; expected_result[4]= 32'hXXXXXXXX;   // invalid
    instructions_array[5]= 32'h00001049; expected_result[5]= 32'h00001321;   // avg()
    instructions_array[6]= 32'h0003080d; expected_result[6]= 32'h00001321;   // | |
    instructions_array[7]= 32'h001def0c; expected_result[7]= 32'hffffe572;   // -(a)
    instructions_array[8]= 32'h00006b0f; expected_result[8]= 32'h00001d3c;   // -
    instructions_array[9]= 32'h001f020a; expected_result[9]= 32'hffffefc9;   // not
    instructions_array[10]= 32'h0013944e; expected_result[10]= 32'h000033e4; // OR
    instructions_array[11]= 32'h00005247; expected_result[11]= 32'h00001906; //max()
    instructions_array[12]= 32'h00047a82; expected_result[12]= 32'hXXXXXXXX; // invalid
    instructions_array[13]= 32'h0000ce0b; expected_result[13]= 32'h00001000; // AND
  end
  //-----------------------------//
  //-----------------------------//
  
  
  // clock generation 
    always begin 
      #10 clk = ~clk;
     end

    initial begin 
    // Initialize Inputs
    clk = 1;
	pass = 1'b1;
    $dumpfile("dump.vcd"); 
      $dumpvars;
     
    $display("\n");	  
    $monitor(" -> instruction=%b, -> result=%h",instruction, result);
     
    #100
     
     for (int j = 0; j <= 13; j = j + 1)begin 
       
     #100
       instruction = instructions_array[j];
     #100

       opcode = instruction[5:0];
       valid_opcode = 1'b0;

       for (int i = 0; i <=10; i = i + 1)begin 
         
          if (opcode == stored_opcodes[i]) begin
                 valid_opcode = 1'b1;
          end
       
       end 
       if(valid_opcode) begin
       
         if (expected_result[j] == result)
           $display(" correct \n ");
         else
           begin
             pass= 1'b0;
             $display(" incorrect");
           end 
         end
       else 
         $display(" invalid opcode \n");
     end 
     
      // Add some delay to observe results
      #1000;
     if (pass)
       $display(" ==> PASS ( This program works correctly ) \n");
     else
       $display(" ==> FAIL (This program does NOT work correctly!!! \n )");
     
      
      $finish; // Finish simulation
      
   end
   
  
  
endmodule 

//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//////////////////////////////////////////
//
//
// end of testbench code
//
//
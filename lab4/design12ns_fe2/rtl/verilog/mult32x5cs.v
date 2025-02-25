/////////////////////////////////////////////////////////////
//	32x5 Booth Multiplier with sum and carry out      //
/////////////////////////////////////////////////////////////


// Booth bit-pair recoding
// Inputs extended to 6/33-bit to handle unsigned multiply
// Adds one PP for the case of unsigned with MSB=1, total of 3 PP

// Partial products (PP) are extended to 34 bits to accomodate +-2x Booth codes
// Sign extension elimination employed: prefix 111..11 for all PPs, +1 nullifies it for positives (achieved
//   logically-correct arithmetic by inverting the sign bit of the each PP)
// PP0 has a partial sign extension constant, to avoid adding a 10th partial product at its MSB position
//   PP0 sign is not inverted and the next two bits are set to '00' for the constant calculation.
// The constant is as follows:  01010101AB, where A and B are the two bit position immediately after the
//   sign bit of PP0 and they are set as follows:
//   If sign of PP0 is '1' then AB = '01', else AB = '10'
//   This recoding on-the-fly to correct PP0 sign is not a critical path as it executes in parallel with the
//   multi-bit invert and/or shift of the booth select logic




module mult32x5cs (
		res_sum, res_carry,
		dataa, datab, signed_op_a, signed_op_b
		);

parameter AIN = 5;
parameter BIN = 32;

output  [(BIN+AIN-1):0]	res_sum,
			res_carry;
input   [(AIN-1):0]	dataa;
input   [(BIN-1):0]	datab;
input			signed_op_a;   // 1 = signed multiply
input			signed_op_b;

wire    [(AIN-1):0]	a = dataa;
wire    [(BIN):0]	b = signed_op_b ? {datab[(BIN-1)], datab[(BIN-1):0]} : {1'b0, datab[(BIN-1):0]} ;


// wire    [1.5 * (AIN+2) - 1:0] booth_op;
reg     [9:0]		booth_op;   // expand bit pair to three bits (one overlapping bit)
   
// expand to 3 bit overlapping fields

always @ (a or signed_op_a)
begin
        booth_op[2:0]   = {a[ 1: 0],1'b0};
        booth_op[5:3]   =  a[ 3: 1];
        booth_op[8:6]   =  signed_op_a ? {a[4],a[4:3]} : {1'b0,a[4:3]} ; 
end


wire    [5:0] add_one = { booth_sign(booth_op[8:6]),
                          booth_sign(booth_op[5:3]),
                          booth_sign(booth_op[2:0])
			};




// function is used to add a 1 at LSB of all negative partial (Booth bit-pair) multipliers to complete operation (-A = ~A + 1)

function [1:0] booth_sign;
input    [2:0] booth_op;
begin
        casex (booth_op) // synopsys parallel_case
                3'b100 :         booth_sign = 2'b01 ;   // -2
                3'b101, 3'b110 : booth_sign = 2'b01 ;   // -1
                3'b000, 3'b001, 3'b010, 3'b011, 3'b111 :
		                 booth_sign = 2'b00 ;   //  0 or positive
                default :        booth_sign = 2'bx  ;
        endcase
end
endfunction
 



function [(BIN+2):0]    booth_operand;   // one bit added for 2x, one bit for added '1' at MSB+1 for sign extension constant
input    [(BIN):0]      bop;
input    [2:0]          booth_op;

// multiplicand is 25 bits (adds 0 for unsigned), booth_operand is 27 bits
// sign extension elimination, add two bits: invert sign bit at position MSB and append '1' to MSB+1 position
// PP0 does not invert sign, see later details for a 'trick fix'

begin
        casex (booth_op) // synopsys full_case parallel_case
                3'b000:   booth_operand = {2'b11,              {(BIN+1){1'b0}}      };  // +0
                3'b001:   booth_operand = {1'b1 , ~bop[(BIN)],  bop[(BIN):0]        };  // +x
                3'b010:   booth_operand = {1'b1 , ~bop[(BIN)],  bop[(BIN):0]        };  // +x
                3'b011:   booth_operand = {1'b1 , ~bop[(BIN)],  bop[(BIN-1):0], 1'b0};  // +2x

                3'b100:   booth_operand = {1'b1 ,  bop[(BIN)], ~bop[(BIN-1):0], 1'b1};  // -2x
                3'b101:   booth_operand = {1'b1 ,  bop[(BIN)], ~bop[(BIN):0]        };  // -x
                3'b110:   booth_operand = {1'b1 ,  bop[(BIN)], ~bop[(BIN):0]        };  // -x
                3'b111:   booth_operand = {2'b11,              {(BIN+1){1'b0}}      };  // +0
		default : booth_operand = {(BIN+3){1'bx}} ;
        endcase
end
endfunction






/////////////////////////////////////////////////////////////////////////////





// Generation of partial products with "sign extension elimination" prefix:
// Add two bits: invert sign bit at position MSB and append '1' to MSB+1 position

// PP0 must be corrected: standard algorithm requires adding '1' at to PP0 position MSB (sign extension constant 10101011);
//   this would require adding a 10th PP at that bit position and increase critical path.
// Trick fix: PP0 sign is not inverted and only a partial sign extension is appended to it, in the following format:
//        11111..1110[PP0_sgn][PP0...]
// If PP0_sgn is 1 then we need to convert the 0 to 1.
// If PP0_sgn is 0 then we need to add +1 at the next position (i.e. the first 1) to nullify the string of 1's.
// This may seem complex but it ends up being quite simple. Re-calculating the sign extension constant for all 9 PPs gives
//    us a very simple 10101010..101000 (last zero aligns with PP0_sgn). This constant treats all PPs other than PP0 just
//    like the "standard" algorithm, i.e. invert the sign bit and append 1 at the next bit position.
// Since only 00 is appended to the PP0 extension, correcting it as outlined above is simple and basically converts these
// two bits to 10 (PP0_sgn==0) or 01 (PP0_sgn==1). PP0_sgn is pre-calculated, although synthesis may speed it up anyway.
// This is a simple modification which retains the structure of 9 PPs and therefore the first level of the
//   Wallace tree is made of CSA3_to_2 only.
// Timing budget is not increased (same as the "textbook" sign extension elimination algorithm).


// op1_1 is PP0
wire [(BIN+2):0]  op1_1_pre  = booth_operand(b,booth_op[2:0]);   // before correction for PP0

// speed up calculation of the sign rather than wait for the (slow) mux logic
wire              op1_1_sgn  = ((booth_op[2:0] == 3'b0) || (booth_op[2:0] == 3'b111)) ?  1'b0 :
                               add_one[0] ^ b[BIN];              // add_one[0]:  1 = negative code (-x, -2x)
                                                                 // b[32] is the sign bit of multiplicand:  1 = negative

// sign bit extends to 3 bits to perform the modified sign extension algorithm (bits AB replace the "standard" constant)
wire [(BIN+3):0]  op1_1      = {~op1_1_sgn,op1_1_sgn,op1_1_sgn,op1_1_pre[(BIN):0]};




// All other PPs conform to the standard algorithm including +1 for negating previous PP and sign extension elimination constant
// Note that PPs extend beyond the range of the result components, so we can compute overflow


wire [(BIN+4):0]  op1_2  = { booth_operand(b,booth_op[5:3]),   add_one[1:0]         };

// length of booth_operand plus 2 LSB for "add_one" from op_1_2 plus proper shift to place it at the correct (radix-4) bit position
wire [(BIN+6):0]  op1_3  = { booth_operand(b,booth_op[8:6]),   add_one[3:2],    2'b0};

wire [(BIN+6):0]  op1_4  = { add_one[5:4],    4'b0};   // contains +1 for negative op1_3, may contain '1' at bit position 4



/////////////////////////////////////////////////////////////////////////////


/* Wallace Tree, stage 1:  4 PP, 1x CSA42 */


wire [(BIN+7):0] L1T0  =  {    op1_1  &  op1_2  | op1_1  & op1_3  |   op1_2  & op1_3  , 1'b0 } ;   // intermediate carry

wire [(BIN+7):0] op2_1 =       op1_1  ^  op1_2  ^ op1_3  ^ op1_4  ^   L1T0 ;             // sum

wire [(BIN+7):0] op2_2 =  {  ( op1_1  ^  op1_2  ^ op1_3  ^ op1_4  ) & L1T0  |
                            ~( op1_1  ^  op1_2  ^ op1_3  ^ op1_4  ) & op1_4  , 1'b0 } ;  // carry


/* Output */

assign  res_sum   = op2_1[(BIN+AIN-1):0] ;
assign  res_carry = op2_2[(BIN+AIN-1):0] ;


endmodule  // mult32x5cs



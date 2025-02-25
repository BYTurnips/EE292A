// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 1995-2012 ARC International (Unpublished)
// All Rights Reserved.
//
// This document, material and/or software contains confidential
// and proprietary information of ARC International and is
// protected by copyright, trade secret and other state, federal,
// and international laws, and may be embodied in patents issued
// or pending.  Its receipt or possession does not convey any
// rights to use, reproduce, disclose its contents, or to
// manufacture, or sell anything it may describe.  Reverse
// engineering is prohibited, and reproduction, disclosure or use
// without specific written authorization of ARC International is
// strictly forbidden.  ARC and the ARC logotype are trademarks of
// ARC International.
// 
// ARC Product:  ARC 600 Architecture v4.9.7
// File version:  600 Architecture IP Library version 4.9.7, file revision 
// ARC Chip ID:  0
//
// Description:
//
// This package contains constants and functions to be used with
// the arcutil package.
//

//synopsys translate_off

//=============================================================================-

    // This function returns true if the single-bit input is either zero
    // or one, and false if the bit is x or z. Note the use of the '!=='
    // operator, which is necessary to check an x or z in Verilog.
    function chk_x;
        input   bit_to_check;

        begin
        
            if (bit_to_check !== 1'b 0 &&
                bit_to_check !== 1'b 1)
            begin
               chk_x = 1'b 0;
            end
            else
            begin
               chk_x = 1'b 1;
            end
        end
    endfunction

    // This function checks a vector and returns true if the vector contains
    // no x or z bits. The first parameter is the vector to check and the
    // second is the number of bits on which the check should be performed.
    function chk_vec;
        input [31:0] vec_to_check;
        input        bits_to_check;

        integer      bits_to_check;
        integer      i;
        reg          result;

        begin
            result = 1'b 1;
            for (i = 0; i < bits_to_check; i = i + 1)
                result = result && chk_bit(vec_to_check[i]);
            chk_vec = result;
        end
    endfunction

    function chk_bit;
        input    bit_to_check;

        begin
        
            if (bit_to_check !== 1'b 0 &&
                bit_to_check !== 1'b 1)
            begin
               chk_bit = 1'b 0;
            end
            else
            begin
               chk_bit = 1'b 1;
            end
        end
    endfunction

//=============================================================================-


    function  time2str_f;

         input    t;

         integer  i;

         begin
            begin
               //  convert time to integer
               i = t / 1;
               time2str_f = i;
            end
        end
    endfunction

//=============================================================================-

    // Return the string when the enable is true

    function dostr1;

        input en;
        input signame;

        begin
           if (en == 1)  
              dostr1 = signame;
           else
              dostr1 = " ";
        end
    endfunction

//=============================================================================-

//synopsys translate_on

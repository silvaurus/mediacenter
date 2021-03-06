LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

-- ******************************************************************************
-- * License Agreement                                                          *
-- *                                                                            *
-- * Copyright (c) 1991-2013 Altera Corporation, San Jose, California, USA.     *
-- * All rights reserved.                                                       *
-- *                                                                            *
-- * Any megafunction design, and related net list (encrypted or decrypted),    *
-- *  support information, device programming or simulation file, and any other *
-- *  associated documentation or information provided by Altera or a partner   *
-- *  under Altera's Megafunction Partnership Program may be used only to       *
-- *  program PLD devices (but not masked PLD devices) from Altera.  Any other  *
-- *  use of such megafunction design, net list, support information, device    *
-- *  programming or simulation file, or any other related documentation or     *
-- *  information is prohibited for any other purpose, including, but not       *
-- *  limited to modification, reverse engineering, de-compiling, or use with   *
-- *  any other silicon devices, unless such use is explicitly licensed under   *
-- *  a separate agreement with Altera or a megafunction partner.  Title to     *
-- *  the intellectual property, including patents, copyrights, trademarks,     *
-- *  trade secrets, or maskworks, embodied in any such megafunction design,    *
-- *  net list, support information, device programming or simulation file, or  *
-- *  any other related documentation or information provided by Altera or a    *
-- *  megafunction partner, remains with Altera, the megafunction partner, or   *
-- *  their respective licensors.  No other licenses, including any licenses    *
-- *  needed under any third party's intellectual property, are provided herein.*
-- *  Copying or modifying any file, or portion thereof, to which this notice   *
-- *  is attached violates this copyright.                                      *
-- *                                                                            *
-- * THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   *
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    *
-- * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    *
-- * FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS  *
-- * IN THIS FILE.                                                              *
-- *                                                                            *
-- * This agreement shall be governed in all respects by the laws of the State  *
-- *  of California and by the laws of the United States of America.            *
-- *                                                                            *
-- ******************************************************************************

-- ******************************************************************************
-- *                                                                            *
-- *   This module counts which bits for serial audio transfers. The module     *
-- * assume that the data format is I2S, as it is described in the audio        *
-- * chip's datasheet.                                                          *
-- *                                                                            *
-- ******************************************************************************

ENTITY altera_up_audio_bit_counter IS 

-- *****************************************************************************
-- *                             Generic Declarations                          *
-- *****************************************************************************
	
GENERIC (
	
	BIT_COUNTER_INIT	:STD_LOGIC_VECTOR( 4 DOWNTO  0)	:= "01111"
	
);
-- *****************************************************************************
-- *                             Port Declarations                             *
-- *****************************************************************************
PORT (

	-- Inputs
	clk									:IN		STD_LOGIC;
	reset									:IN		STD_LOGIC;
	
	bit_clk_rising_edge				:IN		STD_LOGIC;
	bit_clk_falling_edge				:IN		STD_LOGIC;
	left_right_clk_rising_edge		:IN		STD_LOGIC;
	left_right_clk_falling_edge	:IN		STD_LOGIC;

	-- Bidirectionals

	-- Outputs
	counting								:BUFFER	STD_LOGIC

);

END altera_up_audio_bit_counter;

ARCHITECTURE Behaviour OF altera_up_audio_bit_counter IS
-- *****************************************************************************
-- *                           Constant Declarations                           *
-- *****************************************************************************

-- *****************************************************************************
-- *                       Internal Signals Declarations                       *
-- *****************************************************************************
	
	-- Internal Wires
	SIGNAL	reset_bit_counter	:STD_LOGIC;
	
	-- Internal Registers
	SIGNAL	bit_counter			:STD_LOGIC_VECTOR( 4 DOWNTO  0);	
	
	-- State Machine Registers
	
	
-- *****************************************************************************
-- *                          Component Declarations                           *
-- *****************************************************************************
BEGIN
-- *****************************************************************************
-- *                         Finite State Machine(s)                           *
-- *****************************************************************************


-- *****************************************************************************
-- *                             Sequential Logic                              *
-- *****************************************************************************

	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			IF (reset = '1') THEN
				bit_counter <= B"00000";
			ELSIF (reset_bit_counter = '1') THEN
				bit_counter <= BIT_COUNTER_INIT;
			ELSIF ((bit_clk_falling_edge = '1') AND (bit_counter /= B"00000")) THEN
				bit_counter <= bit_counter - B"00001";
			END IF;
		END IF;
	END PROCESS;


	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN
			IF (reset = '1') THEN
				counting <= '0';
			ELSIF (reset_bit_counter = '1') THEN
				counting <= '1';
			ELSIF ((bit_clk_falling_edge = '1') AND (bit_counter = B"00000")) THEN
				counting <= '0';
			END IF;
		END IF;
	END PROCESS;


-- *****************************************************************************
-- *                            Combinational Logic                            *
-- *****************************************************************************

	reset_bit_counter <= left_right_clk_rising_edge OR 
								left_right_clk_falling_edge;

-- *****************************************************************************
-- *                          Component Instantiations                         *
-- *****************************************************************************


END Behaviour;

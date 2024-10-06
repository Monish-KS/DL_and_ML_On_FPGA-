-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\DNN_Simulation_Model\OutputLayer.vhd
-- Created: 2024-08-06 14:39:05
-- 
-- Generated by MATLAB 24.1, HDL Coder 24.1, and Simulink 24.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: OutputLayer
-- Source Path: DNN_Simulation_Model/DNN_Subsystem/OutputLayer
-- Hierarchy Level: 1
-- Model version: 1.24
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.DNN_Subsystem_pkg.ALL;

ENTITY OutputLayer IS
  PORT( Bias                              :   IN    std_logic_vector(4 DOWNTO 0);  -- sfix5_En3
        Weight                            :   IN    vector_of_std_logic_vector6(0 TO 3);  -- sfix6_En2 [4]
        X                                 :   IN    vector_of_std_logic_vector16(0 TO 3);  -- sfix16_En14 [4]
        ytan                              :   OUT   std_logic_vector(15 DOWNTO 0)  -- sfix16_En14
        );
END OutputLayer;


ARCHITECTURE rtl OF OutputLayer IS

  -- Signals
  SIGNAL Bias_signed                      : signed(4 DOWNTO 0);  -- sfix5_En3
  SIGNAL Weight_signed                    : vector_of_signed6(0 TO 3);  -- sfix6_En2 [4]
  SIGNAL X_signed                         : vector_of_signed16(0 TO 3);  -- sfix16_En14 [4]
  SIGNAL ytan_tmp                         : signed(15 DOWNTO 0);  -- sfix16_En14

BEGIN
  Bias_signed <= signed(Bias);

  outputgen1: FOR k1 IN 0 TO 3 GENERATE
    Weight_signed(k1) <= signed(Weight(k1));
  END GENERATE;

  outputgen: FOR k1 IN 0 TO 3 GENERATE
    X_signed(k1) <= signed(X(k1));
  END GENERATE;

  OutputLayer_1_output : PROCESS (Bias_signed, Weight_signed, X_signed)
    VARIABLE PM : signed(15 DOWNTO 0);
    VARIABLE WS : signed(15 DOWNTO 0);
    VARIABLE prodAB : signed(21 DOWNTO 0);
    VARIABLE c : signed(23 DOWNTO 0);
    VARIABLE y : signed(15 DOWNTO 0);
    VARIABLE add_cast : signed(16 DOWNTO 0);
    VARIABLE add_cast_0 : signed(16 DOWNTO 0);
    VARIABLE add_temp : signed(16 DOWNTO 0);
    VARIABLE add_cast_1 : vector_of_signed25(0 TO 3);
    VARIABLE add_cast_2 : vector_of_signed25(0 TO 3);
    VARIABLE add_temp_0 : vector_of_signed25(0 TO 3);
    VARIABLE mul_temp : signed(31 DOWNTO 0);
    VARIABLE add_cast_3 : signed(32 DOWNTO 0);
    VARIABLE add_temp_1 : signed(32 DOWNTO 0);
    VARIABLE mul_temp_0 : signed(31 DOWNTO 0);
    VARIABLE add_cast_4 : signed(32 DOWNTO 0);
    VARIABLE add_temp_2 : signed(32 DOWNTO 0);
    VARIABLE mul_temp_1 : signed(31 DOWNTO 0);
    VARIABLE add_cast_5 : signed(32 DOWNTO 0);
    VARIABLE add_temp_3 : signed(32 DOWNTO 0);
  BEGIN
    prodAB := to_signed(16#000000#, 22);
    mul_temp := to_signed(0, 32);
    add_temp_1 := to_signed(0, 33);
    mul_temp_0 := to_signed(0, 32);
    add_temp_2 := to_signed(0, 33);
    mul_temp_1 := to_signed(0, 32);
    add_temp_3 := to_signed(0, 33);
    add_cast_3 := to_signed(0, 33);
    add_cast_4 := to_signed(0, 33);
    add_cast_5 := to_signed(0, 33);
    c := to_signed(16#000000#, 24);

    FOR k IN 0 TO 3 LOOP
      prodAB := Weight_signed(k) * X_signed(k);
      add_cast_1(k) := resize(c, 25);
      add_cast_2(k) := resize(prodAB, 25);
      add_temp_0(k) := add_cast_1(k) + add_cast_2(k);
      IF (add_temp_0(k)(24) = '0') AND (add_temp_0(k)(23) /= '0') THEN 
        c := X"7FFFFF";
      ELSIF (add_temp_0(k)(24) = '1') AND (add_temp_0(k)(23) /= '1') THEN 
        c := X"800000";
      ELSE 
        c := add_temp_0(k)(23 DOWNTO 0);
      END IF;
    END LOOP;

    IF ((c(23) = '0') AND (c(22 DOWNTO 21) /= "00")) OR ((c(23) = '0') AND (c(21 DOWNTO 6) = X"7FFF")) THEN 
      PM := X"7FFF";
    ELSIF (c(23) = '1') AND (c(22 DOWNTO 21) /= "11") THEN 
      PM := X"8000";
    ELSE 
      PM := c(21 DOWNTO 6) + ('0' & c(5));
    END IF;
    add_cast := resize(PM, 17);
    add_cast_0 := resize(Bias_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0', 17);
    add_temp := add_cast + add_cast_0;
    IF (add_temp(16) = '0') AND (add_temp(15) /= '0') THEN 
      WS := X"7FFF";
    ELSIF (add_temp(16) = '1') AND (add_temp(15) /= '1') THEN 
      WS := X"8000";
    ELSE 
      WS := add_temp(15 DOWNTO 0);
    END IF;
    --Slopes and Offsets
    -- Piecewise Linear Approximation of Sigmoid Function 
    IF WS < to_signed(-16#0C00#, 16) THEN 
      y := to_signed(-16#0400#, 16);
    ELSIF WS < to_signed(-16#0800#, 16) THEN 
      mul_temp := to_signed(16#004A#, 16) * WS;
      add_cast_3 := resize(mul_temp, 33);
      add_temp_1 := add_cast_3 + to_signed(230400, 33);
      y := add_temp_1(25 DOWNTO 10);
    ELSIF (WS >= to_signed(-16#0800#, 16)) AND (WS <= to_signed(16#0800#, 16)) THEN 
      mul_temp_0 := to_signed(16#00D7#, 16) * WS;
      add_cast_4 := resize(mul_temp_0, 33);
      add_temp_2 := add_cast_4 + to_signed(524288, 33);
      y := add_temp_2(25 DOWNTO 10);
    ELSIF WS < to_signed(16#0C00#, 16) THEN 
      mul_temp_1 := to_signed(16#004A#, 16) * WS;
      add_cast_5 := resize(mul_temp_1, 33);
      add_temp_3 := add_cast_5 + to_signed(818176, 33);
      y := add_temp_3(25 DOWNTO 10);
    ELSE 
      y := to_signed(16#0400#, 16);
    END IF;
    --Saturation between 0 to +1
    -- Saturation between 0
    IF y <= to_signed(16#0000#, 16) THEN 
      y := to_signed(16#0000#, 16);
    ELSIF y >= to_signed(16#0400#, 16) THEN 
      y := to_signed(16#0400#, 16);
    END IF;
    IF (y(15) = '0') AND (y(14 DOWNTO 11) /= "0000") THEN 
      ytan_tmp <= X"7FFF";
    ELSIF (y(15) = '1') AND (y(14 DOWNTO 11) /= "1111") THEN 
      ytan_tmp <= X"8000";
    ELSE 
      ytan_tmp <= y(11 DOWNTO 0) & '0' & '0' & '0' & '0';
    END IF;
  END PROCESS OutputLayer_1_output;


  ytan <= std_logic_vector(ytan_tmp);

END rtl;


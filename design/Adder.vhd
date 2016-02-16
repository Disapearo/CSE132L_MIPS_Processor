library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
        generic(
                addr_size : integer := 32
        );
        port(
                oldcounter :    in std_logic_vector(addr_size - 1 downto 0);
                inc :   in std_logic_vector(addr_size - 1 downto 0);
                newcounter :    out std_logic_vector(addr_size - 1 downto 0)
        );
end adder;

architecture simple of adder is
BEGIN
        newcounter <= std_logic_vector(unsigned(oldcounter) + unsigned(inc));
end simple;

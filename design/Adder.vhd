library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;


-- NOTE: Can't we hardcode a lot of these values? Should we expect a change in Address size?

entity adder is
        generic(
                addr_size : integer
        );
        port(
                oldcounter :    in std_logic_vector(addr_size - 1 downto 0);
                inc :   in std_logic_vector(addr_size - 1 downto 0);
                newcounter :    out std_logic_vector(addr_size - 1 downto 0)
        );
end adder;

architecture simple of adder is
BEGIN
        newcounter <= to_std_logic_vector((to_integer(unsigned(oldcounter)) + to_integer(unsigned(inc))), addr_size);
end simple;

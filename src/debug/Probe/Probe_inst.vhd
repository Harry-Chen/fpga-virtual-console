	component Probe is
		port (
			source : out std_logic_vector(15 downto 0);                     -- source
			probe  : in  std_logic_vector(127 downto 0) := (others => 'X')  -- probe
		);
	end component Probe;

	u0 : component Probe
		port map (
			source => CONNECTED_TO_source, -- sources.source
			probe  => CONNECTED_TO_probe   --  probes.probe
		);


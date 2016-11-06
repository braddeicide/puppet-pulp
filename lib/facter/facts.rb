Facter.add(:home) do
  setcode do
    home = `/bin/sh -c "echo $HOME"`
    if $?.success? && !home.empty?
      ret = home.chomp
    end
    ret
  end
end


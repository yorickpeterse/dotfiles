function restart-cinnamon
    nohup cinnamon --replace 2>&1 > /dev/null < /dev/null &
end

function restart-cinnamon
    nohup cinnamon --replace -d :0 2>&1 > /dev/null < /dev/null &
end

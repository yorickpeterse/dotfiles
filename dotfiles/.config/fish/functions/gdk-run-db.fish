function gdk-run-db
    env port=3000 foreman start -c redis=1,postgresql=1
end


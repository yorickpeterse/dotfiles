function gdk-run
    env port=3000 foreman start -c redis=1,postgresql=1,gitaly=1,gitlab-workhorse=1,rails-web=1
end

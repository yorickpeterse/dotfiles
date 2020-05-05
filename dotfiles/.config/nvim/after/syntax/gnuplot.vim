" Treat gnuplot strings as actual strings opposed to comments.
syn region String  start=+"+ skip=+\\"+ end=+"+
syn region String  start=+'+            end=+'+

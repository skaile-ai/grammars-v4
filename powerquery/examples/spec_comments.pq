// leading comment
let
    /* block
       comment */ Source = 1, // trailing
    /** starred **/ Next = Source /* inline */ + 1
in
    Next

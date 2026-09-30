let
    Plain = "hello",
    Quote = "say ""hi""",
    Escapes = "#(cr)#(lf)#(tab)#(cr,lf)#(0041)#(0001F600)#(#)(",
    Hash = "a#b # c#",
    Verbatim = #!"raw text",
    #"Quoted ""name""" = 1,
    #"let" = 2,
    Dates = { #date(2024, 1, 31), #datetime(2024, 1, 31, 8, 30, 0), #datetimezone(2024, 1, 31, 8, 30, 0, 1, 0), #time(8, 30, 0), #duration(1, 2, 3, 4), #binary({1, 2}) },
    Sections = #sections, Shared = #shared,
    Evaluated = Expression.Evaluate("1 + 1", #shared),
    Unicode = let Größe = 1, _private = 2, été = 3 in Größe + _private + été
in
    Plain

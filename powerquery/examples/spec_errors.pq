let
    Raise = () => error "boom",
    RaiseRecord = () => error Error.Record("Reason", "Message", [Detail = 1]),
    Otherwise = try Raise() otherwise 0,
    Catch = try Raise() catch (e) => e[Message],
    CatchNoParam = try Raise() catch () => "failed",
    Bare = try 1,
    HasError = Bare[HasError]
in
    { Otherwise, Catch, CatchNoParam, HasError }

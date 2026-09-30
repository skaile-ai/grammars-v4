let
    NoArgs = () => 1,
    Typed = (a as number, optional b as nullable text) as number => a,
    Untyped = (x, y) => x + y,
    OnlyOptional = (optional x) => x,
    Each = each _ + 1,
    Recursive = (n) => if n = 0 then 1 else n * @Recursive(n - 1),
    Nested = let inner = (f) => f(1) in inner((v) => v * 2),
    Invoked = Typed(1, "a"),
    Curried = ((a) => (b) => a + b)(1)(2),
    catch = 1,
    optional = 2,
    table = 3,
    text = table + optional + catch
in
    Recursive(5)

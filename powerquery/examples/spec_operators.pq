let
    a = 1 + 2 * 3 - 4 / 5,
    b = "x" & "y",
    c = a = 1 and b <> "z" or not (a < 2) and a <= 3 or a > 4 and a >= 5,
    d = -a + +a,
    e = null ?? 0 ?? 1,
    f = a is number,
    g = a as nullable number,
    h = 1 meta [ IsParameterQuery = true, Type = "Number", IsParameterQueryRequired = true ],
    i = 0xFF + 0X1a + 1.5 + .5 + 1e3 + 2.5E-3,
    j = #infinity, k = - #infinity, l = #nan,
    m = true, n = false,
    o = ...,
    p = {1..10, 20, 25..30},
    q = {}
in
    [ a = a, b = b ]

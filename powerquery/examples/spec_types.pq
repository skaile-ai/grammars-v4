let
    T1 = type number,
    T2 = type nullable text,
    T3 = type { number },
    T4 = type [ a = number, optional b = text ],
    T5 = type [ a = number, ... ],
    T6 = type [ ... ],
    T7 = type [],
    T8 = type table [ Id = Int64.Type, Name = text ],
    T9 = type function (x as number, optional y as text) as number,
    T10 = type nullable { text },
    T11 = type any, T12 = type anynonnull, T13 = type none, T14 = type null, T15 = type type,
    T16 = type binary, T17 = type date, T18 = type datetime, T19 = type datetimezone,
    T20 = type duration, T21 = type function, T22 = type list, T23 = type logical,
    T24 = type record, T25 = type table, T26 = type time,
    Changed = Table.TransformColumnTypes(#table({"A"}, {{"1"}}), {{"A", type number}}),
    Asserted = Value.ReplaceType(1, T1) is number
in
    Changed

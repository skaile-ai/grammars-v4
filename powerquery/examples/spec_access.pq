let
    Source = Excel.CurrentWorkbook(){[Name = "Table1"]}[Content],
    First = Source{0},
    Maybe = Source{99}?,
    Field = First[Name],
    OptField = First[Missing]?,
    Proj = First[[Name], [Id]],
    OptProj = First[[Name], [Nope]]?,
    Implicit = List.Transform({[a = 1]}, each [a] + _[a]),
    ImplicitProj = List.Transform({[a = 1, b = 2]}, each [[a]]),
    Spaced = [#"Sales Amount" = 1][Sales Amount],
    Generalized = [Sales Amount = 1, 1st Quarter = 2, if = 3, Column1.1 = 4, type = 5],
    G2 = Generalized[1st Quarter] + Generalized[if] + Generalized[Column1.1] + Generalized[type],
    Chained = Table.FromRecords({[a = 1]}){0}[a]
in
    Chained

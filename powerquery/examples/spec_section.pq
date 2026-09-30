[ Version = "1.0.0", Tags = { "a", 1, true, null, [ x = 1 ] } ]
section Section1;

shared Base = let Source = #table({"Id", "Name"}, {{1, "a"}, {2, "b"}}) in Source;
[ Description = "Doubles the Id" ]
shared Doubled = let S = Base, A = Table.AddColumn(S, "Twice", each [Id] * 2, Int64.Type) in A;
shared #"Sales 2024 (EU)" = List.Numbers(1, 3);
Private = 1;
shared Access = Section1!Private;

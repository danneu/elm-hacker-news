module Json.Decode.Extra exposing (map10, map11, map9)

import Json.Decode as JD exposing (Decoder)


{-| lol
-}
map9 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder i -> Decoder value
map9 x a b c d e f g h i =
    a
        |> JD.andThen
            (\a_ ->
                b
                    |> JD.andThen
                        (\b_ ->
                            c
                                |> JD.andThen
                                    (\c_ ->
                                        d
                                            |> JD.andThen
                                                (\d_ ->
                                                    e
                                                        |> JD.andThen
                                                            (\e_ ->
                                                                f
                                                                    |> JD.andThen
                                                                        (\f_ ->
                                                                            g
                                                                                |> JD.andThen
                                                                                    (\g_ ->
                                                                                        h
                                                                                            |> JD.andThen
                                                                                                (\h_ ->
                                                                                                    i
                                                                                                        |> JD.map
                                                                                                            (\i_ ->
                                                                                                                x a_ b_ c_ d_ e_ f_ g_ h_ i_
                                                                                                            )
                                                                                                )
                                                                                    )
                                                                        )
                                                            )
                                                )
                                    )
                        )
            )


map10 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder i -> Decoder j -> Decoder value
map10 x a b c d e f g h i j =
    a
        |> JD.andThen
            (\a_ ->
                b
                    |> JD.andThen
                        (\b_ ->
                            c
                                |> JD.andThen
                                    (\c_ ->
                                        d
                                            |> JD.andThen
                                                (\d_ ->
                                                    e
                                                        |> JD.andThen
                                                            (\e_ ->
                                                                f
                                                                    |> JD.andThen
                                                                        (\f_ ->
                                                                            g
                                                                                |> JD.andThen
                                                                                    (\g_ ->
                                                                                        h
                                                                                            |> JD.andThen
                                                                                                (\h_ ->
                                                                                                    i
                                                                                                        |> JD.andThen
                                                                                                            (\i_ ->
                                                                                                                j
                                                                                                                    |> JD.map
                                                                                                                        (\j_ ->
                                                                                                                            x a_ b_ c_ d_ e_ f_ g_ h_ i_ j_
                                                                                                                        )
                                                                                                            )
                                                                                                )
                                                                                    )
                                                                        )
                                                            )
                                                )
                                    )
                        )
            )


map11 : (a -> b -> c -> d -> e -> f -> g -> h -> i -> j -> k -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder i -> Decoder j -> Decoder k -> Decoder value
map11 x a b c d e f g h i j k =
    a
        |> JD.andThen
            (\a_ ->
                b
                    |> JD.andThen
                        (\b_ ->
                            c
                                |> JD.andThen
                                    (\c_ ->
                                        d
                                            |> JD.andThen
                                                (\d_ ->
                                                    e
                                                        |> JD.andThen
                                                            (\e_ ->
                                                                f
                                                                    |> JD.andThen
                                                                        (\f_ ->
                                                                            g
                                                                                |> JD.andThen
                                                                                    (\g_ ->
                                                                                        h
                                                                                            |> JD.andThen
                                                                                                (\h_ ->
                                                                                                    i
                                                                                                        |> JD.andThen
                                                                                                            (\i_ ->
                                                                                                                j
                                                                                                                    |> JD.andThen
                                                                                                                        (\j_ ->
                                                                                                                            k
                                                                                                                                |> JD.map
                                                                                                                                    (\k_ ->
                                                                                                                                        x a_ b_ c_ d_ e_ f_ g_ h_ i_ j_ k_
                                                                                                                                    )
                                                                                                                        )
                                                                                                            )
                                                                                                )
                                                                                    )
                                                                        )
                                                            )
                                                )
                                    )
                        )
            )

module Json.Decode.Extra exposing (map11)

import Json.Decode as JD exposing (Decoder)


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

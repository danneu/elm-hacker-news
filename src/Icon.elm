module Icon exposing (elm, github, logo)

import Html.Attributes as HA
import Svg exposing (..)
import Svg.Attributes exposing (..)


logo : Int -> Svg msg
logo height_ =
    svg [ viewBox "0 0 10 10", height (String.fromInt height_), HA.attribute "role" "img" ]
        [ rect [ fill "none", stroke "white", width "10", height "10" ] []

        -- [ rect [ fill "#DD773F", stroke "white", width "10", height "10" ] []
        , line [ stroke "white", x1 "10", y1 "0", x2 "0", y2 "10" ] []
        , line [ stroke "white", x1 "5", y1 "5", x2 "0", y2 "0" ] []
        ]


elm : Int -> Svg msg
elm length =
    svg
        [ version "1.1"
        , id "Layer_1"
        , x "0px"
        , y "0px"
        , viewBox "0 0 323.141 322.95"
        , enableBackground "new 0 0 323.141 322.95"
        , height (String.fromInt length)
        ]
        [ g []
            [ polygon [ fill "#F0AD00", points "161.649,152.782 231.514,82.916 91.783,82.916" ] []
            , polygon [ fill "#7FD13B", points "8.867,0 79.241,70.375 232.213,70.375 161.838,0" ] []
            , rect [ fill "#7FD13B", x "192.99", y "107.392", transform "matrix(0.7071 0.7071 -0.7071 0.7071 186.4727 -127.2386)", width "107.676", height "108.167" ] []
            , polygon [ fill "#60B5CC", points "323.298,143.724 323.298,0 179.573,0" ] []
            , polygon [ fill "#5A6378", points "152.781,161.649 0,8.868 0,314.432" ] []
            , polygon [ fill "#F0AD00", points "255.522,246.655 323.298,314.432 323.298,178.879" ] []
            , polygon [ fill "#60B5CC", points "161.649,170.517 8.869,323.298 314.43,323.298" ] []
            ]
        ]


github : Int -> Svg msg
github length =
    svg [ viewBox "0 0 24 24", height (String.fromInt length) ]
        [ Svg.path [ d "M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" ] [] ]

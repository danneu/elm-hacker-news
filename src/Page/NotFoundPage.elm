module Page.NotFoundPage exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div
        [ class "NotFoundPage" ]
        [ h2 [] [ text "Not found" ]
        , p [] [ text "Go back to ", a [ href "/" ] [ text "homepage" ] ]
        ]

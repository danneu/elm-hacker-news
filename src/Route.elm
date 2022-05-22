module Route exposing (Route(..), fromUrl, toString)

import Api
import Url
import Url.Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, s)
import Url.Parser.Query as Query


type Route
    = Home Api.PageType (Maybe Int)
    | Story Int
    | User String


toString : Route -> String
toString route =
    case route of
        Home filter maybePage ->
            Url.Builder.relative
                (case filter of
                    Api.Top ->
                        []

                    Api.New ->
                        [ "newest" ]

                    Api.Job ->
                        [ "jobs" ]

                    Api.Ask ->
                        [ "ask" ]

                    Api.Best ->
                        [ "best" ]

                    Api.Show ->
                        [ "show" ]
                )
                (case maybePage of
                    Just page ->
                        [ Url.Builder.int "page" page ]

                    Nothing ->
                        []
                )

        Story id ->
            Url.Builder.relative
                [ "stories", String.fromInt id ]
                []

        User username ->
            Url.Builder.relative
                [ "users", username ]
                []


fromUrl : Url.Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home
            (Parser.oneOf
                [ Parser.top |> Parser.map Api.Top
                , s "newest" |> Parser.map Api.New
                , s "ask" |> Parser.map Api.Ask
                , s "show" |> Parser.map Api.Show
                , s "jobs" |> Parser.map Api.Job
                ]
                <?> Query.int "page"
            )
        , Parser.map Story (s "stories" </> Parser.int)
        , Parser.map User (s "users" </> Parser.string)
        ]

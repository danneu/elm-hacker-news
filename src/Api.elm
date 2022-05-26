module Api exposing (PageType(..), getComment, getPage, getStory, getUser)

import Comment exposing (Comment)
import Http
import Json.Decode as JD
import Story exposing (Story)
import Url.Builder
import User exposing (User)


endpoint : String
endpoint =
    "https://hacker-news.firebaseio.com/v0"


type PageType
    = Top
    | New
    | Best
    | Ask
    | Show
    | Job


getStory : Int -> (Result Http.Error Story -> msg) -> Cmd msg
getStory id tagger =
    let
        url =
            Url.Builder.crossOrigin
                endpoint
                [ "item", String.fromInt id ++ ".json" ]
                []
    in
    Http.request
        { method = "GET"
        , url = url
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectJson tagger Story.decoder
        , timeout = Nothing
        , tracker = Nothing
        }


getUser : String -> (Result Http.Error User -> msg) -> Cmd msg
getUser username tagger =
    let
        url =
            Url.Builder.crossOrigin
                endpoint
                [ "user", username ++ ".json" ]
                []
    in
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson tagger User.decoder
        , timeout = Nothing
        , tracker = Nothing
        }


getPage : PageType -> (Result Http.Error (List Int) -> msg) -> Cmd msg
getPage pageType tagger =
    let
        path =
            case pageType of
                Top ->
                    "topstories.json"

                New ->
                    "newstories.json"

                Best ->
                    "beststories.json"

                Ask ->
                    "askstories.json"

                Show ->
                    "showstories.json"

                Job ->
                    "jobstories.json"

        url =
            Url.Builder.crossOrigin
                endpoint
                [ path ]
                []
    in
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson tagger (JD.list JD.int)
        , timeout = Nothing
        , tracker = Nothing
        }


getComment : Int -> (Result Http.Error Comment -> msg) -> Cmd msg
getComment id tagger =
    let
        url =
            Url.Builder.crossOrigin
                endpoint
                [ "item", String.fromInt id ++ ".json" ]
                []
    in
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson tagger Comment.decoder
        , timeout = Nothing
        , tracker = Nothing
        }

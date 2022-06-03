module Comment exposing (Comment, Comments(..), decoder, getComments, replyCount, setComment, toHnAnchor)

{-| A comment from HN API.

Notes:

  - If json.dead is present (thus true), then there will be a username but no body
    unless, I imagine, the logged-in user has showdead enabled (TODO).
  - If json.deleted is present (thus true), then there will be neither a body nor username.

-}

import Dict exposing (Dict)
import Html exposing (Html, a)
import Html.Attributes exposing (href, rel, target)
import Json.Decode as D
import Json.Decode.Pipeline as P
import RemoteData exposing (WebData)
import Set exposing (Set)
import Time
import Util


type alias Comment =
    { id : Int
    , by : String
    , time : Time.Posix
    , text : String
    , directKidIds : List Int
    , comments : Comments
    , parent : Int
    , isDeleted : Bool
    , allKidIds : Set Int
    }


type Comments
    = Comments (Dict Int (WebData Comment))


replyCount : Comment -> Int
replyCount comment =
    comment
        |> getComments
        |> Dict.size


getComments : { a | comments : Comments } -> Dict Int (WebData Comment)
getComments rec =
    let
        (Comments comments) =
            rec.comments
    in
    comments


setComment : List Int -> WebData Comment -> Comments -> Comments
setComment ids comment (Comments comments) =
    case ids of
        [] ->
            Comments comments

        id :: [] ->
            case comment of
                RemoteData.Success { isDeleted } ->
                    if isDeleted then
                        Comments (Dict.remove id comments)

                    else
                        Comments (Dict.insert id comment comments)

                _ ->
                    Comments (Dict.insert id comment comments)

        id :: rest ->
            case Dict.get id comments of
                Nothing ->
                    Comments comments

                Just (RemoteData.Success subComment) ->
                    let
                        child =
                            RemoteData.succeed
                                { subComment
                                    | comments =
                                        setComment rest comment subComment.comments
                                    , allKidIds =
                                        Set.union
                                            (Set.fromList rest)
                                            subComment.allKidIds
                                }
                    in
                    Comments (Dict.insert id child comments)

                _ ->
                    Comments comments


decoder : D.Decoder Comment
decoder =
    (D.succeed Comment
        |> P.required "id" D.int
        |> P.optional "by" D.string "(Dead)"
        |> P.required "time" Util.posixDecoder
        -- if "dead" exists and "dead"==true, then text key will be missing
        |> P.optional "text" D.string "(Dead)"
        |> P.optional "kids" (D.list D.int) []
        |> P.hardcoded (Comments Dict.empty)
        |> P.required "parent" D.int
        |> P.custom
            (D.oneOf
                [ D.field "deleted" (D.succeed True)
                , D.field "dead" (D.succeed True)
                , D.succeed False
                ]
            )
        |> P.hardcoded Set.empty
    )
        |> D.map
            (\comment ->
                { comment
                    | comments =
                        comment.directKidIds
                            |> List.map (\id -> ( id, RemoteData.Loading ))
                            |> Dict.fromList
                            |> Comments
                    , allKidIds =
                        Set.fromList comment.directKidIds
                }
            )


toHnAnchor : Int -> Html msg -> Html msg
toHnAnchor id child =
    a
        [ href ("https://news.ycombinator.com/item?id=" ++ String.fromInt id)
        , target "_blank"
        , rel "noopener noreferrer"
        ]
        [ child ]

module Comment exposing (Comment, Comments(..), decoder, getComments, replyCount, setComment)

{-| A comment from HN API.

Notes:

  - If json.dead is present (thus true), then there will be a username but no body
    unless, I imagine, the logged-in user has showdead enabled (TODO).
  - If json.deleted is present (thus true), then there will be neither a body nor username.

-}

import Dict exposing (Dict)
import Json.Decode as JD
import RemoteData exposing (WebData)
import Time
import Util


type alias Comment =
    { id : Int
    , by : String
    , time : Time.Posix
    , text : String
    , comments : Comments
    , parent : Int
    , isDeleted : Bool
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
                                }
                    in
                    Comments (Dict.insert id child comments)

                _ ->
                    Comments comments


decoder : JD.Decoder Comment
decoder =
    JD.map7 Comment
        (JD.field "id" JD.int)
        (JD.oneOf
            [ JD.field "by" JD.string
            , JD.succeed "(Dead)"
            ]
        )
        (JD.field "time" Util.posixDecoder)
        -- if "dead" exists and "dead"==true, then text key will be missing
        (JD.oneOf
            [ JD.field "text" JD.string
            , JD.succeed "(Dead)"
            ]
        )
        (JD.oneOf
            [ JD.field "kids" (JD.list JD.int)
            , JD.succeed []
            ]
            |> JD.map
                (\ids ->
                    ids
                        |> List.map (\id -> ( id, RemoteData.Loading ))
                        |> Dict.fromList
                        |> Comments
                )
        )
        (JD.field "parent" JD.int)
        (JD.oneOf
            [ JD.field "deleted" (JD.succeed True)
            , JD.field "dead" (JD.succeed True)
            , JD.succeed False
            ]
        )

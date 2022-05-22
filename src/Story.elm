module Story exposing (Story, StoryType(..), decoder, listCommentsInOrder, setComment)

import Comment exposing (Comment, Comments(..))
import Dict
import Json.Decode as JD
import Json.Decode.Extra exposing (map11)
import RemoteData exposing (WebData)
import Time
import Util


type StoryType
    = IsStory
    | IsJob
    | IsPoll
    | IsUnknown String


type alias Story =
    { type_ : StoryType
    , id : Int
    , by : String
    , title : String
    , time : Time.Posix
    , score : Int
    , url : Maybe String
    , kidIds : List Int
    , comments : Comments
    , replyCount : Int
    , text : Maybe String
    }


setComment : List Int -> WebData Comment -> Story -> Story
setComment ids comment parent =
    { parent
        | comments =
            Comment.setComment ids comment parent.comments
    }


listCommentsInOrder : Story -> List ( Int, WebData Comment )
listCommentsInOrder story =
    let
        (Comments dict) =
            story.comments

        help ids acc =
            case ids of
                [] ->
                    List.reverse acc

                id :: rest ->
                    case Dict.get id dict of
                        Nothing ->
                            help rest acc

                        Just comment ->
                            help rest (( id, comment ) :: acc)
    in
    help story.kidIds []


decoder : JD.Decoder Story
decoder =
    -- type: story | job | poll
    map11 Story
        (JD.field "type"
            (JD.string
                |> JD.map
                    (\s ->
                        case s of
                            "story" ->
                                IsStory

                            "job" ->
                                IsJob

                            "poll" ->
                                IsPoll

                            _ ->
                                IsUnknown s
                    )
            )
        )
        (JD.field "id" JD.int)
        (JD.field "by" JD.string)
        (JD.field "title" JD.string)
        (JD.field "time" Util.posixDecoder)
        (JD.field "score" JD.int)
        (JD.oneOf
            [ JD.field "url" JD.string |> JD.map Just
            , JD.succeed Nothing
            ]
        )
        (JD.oneOf
            [ JD.field "kids" (JD.list JD.int)
            , JD.succeed []
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
        -- e.g. type=job has no descendants key
        (JD.oneOf
            [ JD.field "descendants" JD.int
            , JD.succeed 0
            ]
        )
        (JD.oneOf
            [ JD.field "text" JD.string |> JD.map Just
            , JD.succeed Nothing
            ]
        )

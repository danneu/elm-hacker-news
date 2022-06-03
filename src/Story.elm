module Story exposing (Story, StoryType(..), decoder, listCommentsInOrder, setComment)

import Comment exposing (Comment, Comments(..))
import Dict
import Json.Decode as D
import Json.Decode.Pipeline as P
import RemoteData exposing (WebData)
import Time
import Util


type StoryType
    = IsStory
    | IsJob
    | IsPoll
    | IsUnknown String


storyTypeFromString : String -> StoryType
storyTypeFromString s =
    case s of
        "story" ->
            IsStory

        "job" ->
            IsJob

        "poll" ->
            IsPoll

        _ ->
            IsUnknown s


type alias Story =
    { type_ : StoryType
    , id : Int
    , by : String
    , title : String
    , time : Time.Posix
    , score : Int
    , url : Maybe String

    -- comments are unordered, so we use kidIds to store the original comment order :/
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


decoder : D.Decoder Story
decoder =
    (D.succeed Story
        -- type: story | job | poll
        |> P.required "type" (D.string |> D.map storyTypeFromString)
        |> P.required "id" D.int
        |> P.required "by" D.string
        |> P.required "title" D.string
        |> P.required "time" Util.posixDecoder
        |> P.required "score" D.int
        |> P.optional "url" (D.string |> D.map Just) Nothing
        |> P.optional "kids" (D.list D.int) []
        -- Post-process .comments instead of decoding "kids" twice.
        |> P.hardcoded (Comments Dict.empty)
        -- e.g. type=job has no descendants key
        |> P.optional "descendants" D.int 0
        |> P.optional "text" (D.string |> D.map Just) Nothing
    )
        |> D.map
            (\story ->
                { story
                    | comments =
                        story.kidIds
                            |> List.map (\id -> ( id, RemoteData.Loading ))
                            |> Dict.fromList
                            |> Comments
                }
            )

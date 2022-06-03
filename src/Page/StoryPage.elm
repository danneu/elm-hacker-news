port module Page.StoryPage exposing (Model, Msg, OutMsg(..), init, update, view)

import Api
import Comment exposing (Comment)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Html.Parser
import Http
import Icon
import RemoteData exposing (WebData)
import Set exposing (Set)
import Story exposing (Story)
import Task
import Time
import Util


reqBatchSize : Int
reqBatchSize =
    1


port scrollToComment : Int -> Cmd msg


type alias Model =
    { id : Int
    , story : WebData Story
    , collapsedIds : Set Int
    , now : Maybe Time.Posix

    -- Layman's depth-first queue when reqBatchSize == 1
    , pendingIds : List ( Int, List Int )
    }


type Msg
    = RecvTime Time.Posix
    | RecvStory (Result Http.Error Story)
    | RecvComment (List Int) Int (Result Http.Error Comment)
    | CollapseComment Int


type OutMsg
    = ChangeTitle String


init : Int -> ( Model, Cmd Msg )
init id =
    ( { id = id
      , story = RemoteData.Loading
      , collapsedIds = Set.empty
      , now = Nothing
      , pendingIds = []
      }
    , Cmd.batch
        [ Api.getStory id RecvStory
        , Task.perform RecvTime Time.now
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        RecvTime posix ->
            ( { model | now = Just posix }, Cmd.none, Nothing )

        CollapseComment id ->
            let
                ( collapsedIds, cmd ) =
                    if Set.member id model.collapsedIds then
                        ( Set.remove id model.collapsedIds
                        , Cmd.none
                        )

                    else
                        ( Set.insert id model.collapsedIds
                        , scrollToComment id
                        )
            in
            ( { model
                | collapsedIds = collapsedIds
              }
            , cmd
            , Nothing
            )

        RecvComment parentIds id result ->
            let
                newPendingIds =
                    List.append
                        (case result of
                            Ok comment ->
                                comment
                                    |> Comment.getComments
                                    |> Dict.toList
                                    |> List.map (\( kidId, _ ) -> ( kidId, List.append parentIds [ id ] ))

                            _ ->
                                []
                        )
                        model.pendingIds
            in
            ( { model
                | story =
                    model.story
                        |> RemoteData.map
                            (\story ->
                                Story.setComment
                                    (List.append parentIds [ id ])
                                    (RemoteData.fromResult result)
                                    story
                            )
                , pendingIds =
                    List.drop reqBatchSize newPendingIds
              }
            , newPendingIds
                |> List.take reqBatchSize
                |> List.map
                    (\( kidId, kidParentIds ) ->
                        Api.getComment kidId (RecvComment kidParentIds kidId)
                    )
                |> Cmd.batch
            , Nothing
            )

        RecvStory result ->
            case result of
                Ok story ->
                    let
                        pendingIds =
                            story
                                |> Story.listCommentsInOrder
                                |> List.map (\( id, _ ) -> ( id, [] ))
                    in
                    ( { model
                        | story =
                            RemoteData.succeed story
                        , pendingIds =
                            List.drop reqBatchSize pendingIds
                      }
                    , pendingIds
                        |> List.take reqBatchSize
                        |> List.map (\( id, parentIds ) -> Api.getComment id (RecvComment parentIds id))
                        -- HACK: Request the stories at the top first
                        |> List.reverse
                        |> Cmd.batch
                    , Just (ChangeTitle story.title)
                    )

                Err error ->
                    ( { model | story = RemoteData.Failure error }
                    , Cmd.none
                    , Nothing
                    )


config : Html.Parser.Config
config =
    [ ( "quot", "\"" )
    , ( "QUOT", "\"" )
    , ( "apos", "'" )
    , ( "gt", ">" )
    , ( "GT", ">" )
    , ( "Gt", ">" )
    , ( "lt", "<" )
    , ( "LT", "<" )
    , ( "Lt", "<" )
    , ( "amp", "&" )
    , ( "AMP", "&" )
    , ( "nbsp", "\u{00A0}" )
    ]
        |> Dict.fromList
        |> Html.Parser.customCharRefs


viewLoadedComment : Int -> Maybe Time.Posix -> Set Int -> Comment -> List (Html Msg)
viewLoadedComment depth now collapsedIds comment =
    let
        html =
            case Html.Parser.run config ("<p>" ++ comment.text) of
                Err _ ->
                    [ text "(Parse error)" ]

                Ok nodes ->
                    Html.Parser.nodesToHtml nodes
    in
    [ header
        [ class "byline" ]
        [ a [ href ("/users/" ++ comment.by) ] [ Icon.user 18, text comment.by ]
        , text " "

        -- , span [ style "word-break" "break-all" ] [ text (Debug.toString comment.allKidIds) ]
        , case now of
            Nothing ->
                text ""

            Just end ->
                Comment.toHnAnchor comment.id (Util.viewTimeAgo comment.time end)
        ]
    , div [] html
    , if Comment.replyCount comment == 0 then
        text ""

      else
        footer
            [ class "comment-replies"
            , class ("depth-" ++ String.fromInt (modBy 3 depth))
            ]
            [ div
                [ class "gutter"
                , class ("gutter-depth-" ++ String.fromInt (modBy 3 depth))
                , onClick (CollapseComment comment.id)
                ]
                []
            , if Set.member comment.id collapsedIds then
                button
                    [ onClick (CollapseComment comment.id)
                    , class "btn btn-link"
                    ]
                    [ text ("Show " ++ String.fromInt (Set.size comment.allKidIds) ++ " replies") ]

              else
                Html.Keyed.ul
                    []
                    (comment
                        |> Comment.getComments
                        |> Dict.toList
                        |> List.map
                            (\( id, kid ) ->
                                ( String.fromInt id
                                , li []
                                    [ viewComment (depth + 1) now collapsedIds id kid ]
                                )
                            )
                    )
            ]
    ]


viewComment : Int -> Maybe Time.Posix -> Set Int -> Int -> WebData Comment -> Html Msg
viewComment depth now collapsedIds id data =
    div
        [ class "comment"

        -- Used by scrollToComment port handler
        , class ("comment-" ++ String.fromInt id)
        ]
        (case data of
            RemoteData.NotAsked ->
                []

            RemoteData.Loading ->
                [ text ("Loading comment " ++ String.fromInt id) ]

            RemoteData.Success comment ->
                viewLoadedComment depth now collapsedIds comment

            RemoteData.Failure _ ->
                [ text "Failed to load comment: "
                , Comment.toHnAnchor id (text (String.fromInt id))
                ]
        )


viewStoryInfo : Story -> Maybe Time.Posix -> Html Msg
viewStoryInfo story maybeNow =
    div
        [ class "story-info" ]
        (List.append
            (case story.url of
                Just url ->
                    let
                        domain =
                            Util.extractDomain url
                                |> Maybe.withDefault "--"
                    in
                    [ h2 [ class "title" ]
                        [ a
                            [ href url ]
                            [ text story.title
                            ]
                        , small [] [ text (" (" ++ domain ++ ")") ]
                        ]
                    ]

                Nothing ->
                    [ h2 [ class "title" ] [ text story.title ] ]
            )
            [ div [ class "byline", style "margin-bottom" "1rem" ]
                [ text (String.fromInt story.score ++ " points by ")
                , a [ class "author", href ("/users/" ++ story.by) ]
                    [ Icon.user 18
                    , text story.by
                    ]
                , text " "
                , case maybeNow of
                    Just now ->
                        Util.viewTimeAgo story.time now

                    Nothing ->
                        text ""
                ]
            , story.text
                |> Maybe.andThen (\html -> Html.Parser.run config html |> Result.toMaybe)
                |> Maybe.map Html.Parser.nodesToHtml
                |> Maybe.map (\nodes -> div [ class "story-text" ] nodes)
                |> Maybe.withDefault (text "")
            ]
        )


view : Model -> Html Msg
view model =
    div
        [ class "StoryPage" ]
        [ case model.story of
            RemoteData.Success story ->
                div
                    []
                    [ viewStoryInfo story model.now
                    , hr [] []
                    , if story.replyCount == 0 then
                        text "(This story has no comments)"

                      else
                        div [ class "comments" ]
                            [ Html.Keyed.ul
                                []
                                (story
                                    |> Story.listCommentsInOrder
                                    |> List.map
                                        (\( id, comment ) ->
                                            ( String.fromInt id
                                            , li
                                                []
                                                [ viewComment 0 model.now model.collapsedIds id comment ]
                                            )
                                        )
                                )
                            ]
                    ]

            RemoteData.Failure _ ->
                text "Failed to load story"

            RemoteData.Loading ->
                text "Loading"

            RemoteData.NotAsked ->
                text ""
        ]

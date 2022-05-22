module Page.HomePage exposing (Model, Msg, init, update, view)

import Api
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Http
import RemoteData exposing (WebData)
import Story exposing (Story)
import Task
import Time
import Util


type alias WebStory =
    { id : Int, data : WebData Story }


type alias Model =
    { stories : List WebStory
    , now : Time.Posix
    , page : Int
    , perPage : Int
    }


type Msg
    = RecvTime Time.Posix
    | RecvStory Int (Result Http.Error Story)
    | RecvStoryIds (Result Http.Error (List Int))
    | ChangePage Int


init : Api.PageType -> Maybe Int -> ( Model, Cmd Msg )
init filter maybePage =
    let
        perPage =
            25

        page =
            maybePage
                |> Maybe.map (Basics.max 1)
                |> Maybe.map (Basics.min (500 // perPage))
                |> Maybe.withDefault 1
    in
    ( { stories = []
      , now = Time.millisToPosix 0
      , page = page

      -- Should be factor of 500 (the amount of stories HN's API gives us)
      , perPage = perPage
      }
    , Cmd.batch
        [ Task.perform RecvTime Time.now
        , Api.getPage filter RecvStoryIds
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangePage page ->
            ( { model | page = page }
            , Api.getPage Api.Top RecvStoryIds
            )

        RecvTime posix ->
            ( { model | now = posix }, Cmd.none )

        RecvStory id result ->
            ( { model
                | stories =
                    List.map
                        (\story ->
                            if story.id == id then
                                { story | data = RemoteData.fromResult result }

                            else
                                story
                        )
                        model.stories
              }
            , Cmd.none
            )

        RecvStoryIds result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok allIds ->
                    let
                        ids =
                            allIds
                                |> List.drop ((model.page - 1) * model.perPage)
                                |> List.take model.perPage
                    in
                    ( { model
                        | stories =
                            List.map (\id -> { id = id, data = RemoteData.Loading }) ids
                      }
                    , ids
                        |> List.map (\id -> Api.getStory id (RecvStory id))
                        -- HACK: Make Elm load stories in opposite order (stories at top first)
                        |> List.reverse
                        |> Cmd.batch
                    )


viewStory : Time.Posix -> WebStory -> Html Msg
viewStory now ({ id } as webStory) =
    case webStory.data of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text ("Fetching story " ++ String.fromInt id)

        RemoteData.Failure _ ->
            text "Failed to load story"

        RemoteData.Success story ->
            article
                [ class "story"
                ]
                [ let
                    viewSummary story_ =
                        a [ href ("/stories/" ++ String.fromInt story_.id) ]
                            [ text <| String.fromInt story_.replyCount ++ " replies" ]
                  in
                  aside
                    []
                    [ case story.type_ of
                        Story.IsStory ->
                            viewSummary story

                        Story.IsPoll ->
                            viewSummary story

                        Story.IsJob ->
                            text "Hiring"

                        Story.IsUnknown s ->
                            text s
                    , br [] []
                    , text (String.fromInt story.score ++ " pts")
                    ]
                , section []
                    [ header []
                        (case story.url of
                            Just url ->
                                [ a
                                    [ href url ]
                                    [ text story.title ]
                                , let
                                    domain =
                                        Util.extractDomain url
                                            |> Maybe.withDefault "--"
                                  in
                                  text (" (" ++ domain ++ ")")
                                ]

                            Nothing ->
                                [ text story.title ]
                        )
                    , footer [ class "byline" ]
                        [ text "submitted by "
                        , a [ href ("/users/" ++ story.by) ] [ text story.by ]
                        , text " "
                        , Util.viewTimeAgo story.time now
                        ]
                    ]
                ]


viewPagination : Model -> Html Msg
viewPagination model =
    if List.isEmpty model.stories then
        -- Don't show pagination until stories are on screen
        text ""

    else
        List.range 1 (500 // model.perPage)
            |> List.map
                (\num ->
                    if model.page == num then
                        text (String.fromInt num)

                    else
                        a
                            [ if num == 1 then
                                href "?"

                              else
                                href ("?page=" ++ String.fromInt num)
                            ]
                            [ text (String.fromInt num) ]
                )
            |> List.intersperse (text " ")
            |> (\nodes -> div [ class "pagination" ] (List.append [ text "Page " ] nodes))


view : Model -> Html Msg
view model =
    div [ class "HomePage" ]
        [ Html.Keyed.ol
            []
            (List.map
                (\story ->
                    ( String.fromInt story.id, li [] [ viewStory model.now story ] )
                )
                model.stories
            )
        , viewPagination model
        ]

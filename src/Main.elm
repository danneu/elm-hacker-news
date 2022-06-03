module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Icon
import Page
import Page.HomePage
import Page.NotFoundPage
import Page.StoryPage
import Page.UserPage
import Route
import Url


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Maybe Page.Page
    , subtitle : Maybe String
    , filter : Api.PageType
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( model, cmd ) =
            { key = key
            , url = url
            , page = Nothing
            , subtitle = Nothing
            , filter = Api.Top
            }
                |> setRoute (Route.fromUrl url)
    in
    ( model
    , cmd
    )


setRoute : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        ( newModel, cmd ) =
            case maybeRoute of
                Nothing ->
                    ( { model | page = Just Page.NotFound }, Cmd.none )

                Just (Route.Home filter page) ->
                    let
                        ( pageModel, pageCmd ) =
                            Page.HomePage.init filter page
                    in
                    ( { model
                        | page =
                            Just (Page.Home pageModel)
                        , filter = filter
                      }
                    , Cmd.map HomePageMsg pageCmd
                    )

                Just (Route.Story id) ->
                    let
                        ( pageModel, pageCmd ) =
                            Page.StoryPage.init id
                    in
                    ( { model
                        | page =
                            Just (Page.Story pageModel)
                      }
                    , Cmd.map StoryPageMsg pageCmd
                    )

                Just (Route.User username) ->
                    let
                        ( pageModel, pageCmd ) =
                            Page.UserPage.init username
                    in
                    ( { model
                        | page =
                            Just (Page.User pageModel)
                      }
                    , Cmd.map UserPageMsg pageCmd
                    )
    in
    ( { newModel | subtitle = Nothing }
    , cmd
    )


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
      -- Pages
    | HomePageMsg Page.HomePage.Msg
    | StoryPageMsg Page.StoryPage.Msg
    | UserPageMsg Page.UserPage.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            setRoute (Route.fromUrl url) model

        HomePageMsg pageMsg ->
            case model.page of
                Just (Page.Home pageModel) ->
                    let
                        ( newPageModel, pageCmd ) =
                            Page.HomePage.update pageMsg pageModel
                    in
                    ( { model
                        | page =
                            Just (Page.Home newPageModel)
                      }
                    , Cmd.map HomePageMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        StoryPageMsg pageMsg ->
            case model.page of
                Just (Page.Story pageModel) ->
                    let
                        ( newPageModel, pageCmd, outMsg ) =
                            Page.StoryPage.update pageMsg pageModel

                        newModel =
                            case outMsg of
                                Just (Page.StoryPage.ChangeTitle title) ->
                                    { model | subtitle = Just title }

                                Nothing ->
                                    model
                    in
                    ( { newModel
                        | page =
                            Just (Page.Story newPageModel)
                      }
                    , Cmd.map StoryPageMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )

        UserPageMsg pageMsg ->
            case model.page of
                Just (Page.User pageModel) ->
                    let
                        ( newPageModel, pageCmd, outMsg ) =
                            Page.UserPage.update pageMsg pageModel

                        newModel =
                            case outMsg of
                                Just (Page.UserPage.ChangeTitle title) ->
                                    { model | subtitle = Just title }

                                Nothing ->
                                    model
                    in
                    ( { newModel
                        | page =
                            Just (Page.User newPageModel)
                      }
                    , Cmd.map UserPageMsg pageCmd
                    )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


viewNavbar : Model -> Html Msg
viewNavbar model =
    let
        iconSize =
            24
    in
    header
        [ class "navbar" ]
        [ section []
            [ a
                [ href "/"
                , class "icon"
                , style "margin-right" ".4rem"
                , title "app logo"
                , style "height" (String.fromInt iconSize ++ "px")

                -- , style "display" "inline-block"
                ]
                [ Icon.logo iconSize ]
            , a [ href "/", class "brand" ] [ text "Hacker News" ]
            , a [ href "/", classList [ ( "active", model.filter == Api.Top ) ] ] [ text "Top" ]
            , a [ href "/newest", classList [ ( "active", model.filter == Api.New ) ] ] [ text "New" ]
            , a [ href "/ask", classList [ ( "active", model.filter == Api.Ask ) ] ] [ text "Ask" ]
            , a [ href "/show", classList [ ( "active", model.filter == Api.Show ) ] ] [ text "Show" ]
            , a [ href "/jobs", classList [ ( "active", model.filter == Api.Job ) ] ] [ text "Jobs" ]
            ]
        , section []
            [ a [ href "https://github.com/danneu/elm-hacker-news", title "github logo", class "icon" ] [ Icon.github 24 ]
            ]
        ]


viewFooter : Html Msg
viewFooter =
    let
        size =
            18
    in
    footer
        [ class "global-footer" ]
        [ p []
            [ text "Built by danneu with "
            , a
                [ href "https://elm-lang.org", title "elm-lang.org logo" ]
                [ Icon.elm size ]
            ]
        , p []
            [ text "Source code on "
            , a [ href "https://github.com/danneu/elm-hacker-news", title "Github.com logo" ] [ Icon.github size ]
            ]
        ]


viewContent : Model -> Html Msg
viewContent model =
    main_ []
        [ case model.page of
            Nothing ->
                text ""

            Just (Page.Home pageModel) ->
                Page.HomePage.view pageModel
                    |> Html.map HomePageMsg

            Just (Page.Story pageModel) ->
                Page.StoryPage.view pageModel
                    |> Html.map StoryPageMsg

            Just (Page.User pageModel) ->
                Page.UserPage.view pageModel
                    |> Html.map UserPageMsg

            Just Page.NotFound ->
                Page.NotFoundPage.view
        ]


view : Model -> Browser.Document Msg
view model =
    let
        baseTitle =
            "elm-hacker-news"
    in
    { title =
        case model.subtitle of
            Just subtitle ->
                subtitle ++ " | " ++ baseTitle

            Nothing ->
                baseTitle
    , body =
        [ viewNavbar model
        , viewContent model
        , div [ class "spacer" ] []
        , viewFooter
        ]
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }

module Page.UserPage exposing (Model, Msg, OutMsg(..), init, update, view)

import Api
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import RemoteData exposing (WebData)
import User exposing (User)


type alias Model =
    { username : String
    , user : WebData User
    }


type Msg
    = RecvUser (Result Http.Error User)


type OutMsg
    = ChangeTitle String


init : String -> ( Model, Cmd Msg )
init username =
    ( { username = username
      , user = RemoteData.Loading
      }
    , Api.getUser username RecvUser
    )


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        RecvUser result ->
            case result of
                Err error ->
                    ( { model | user = RemoteData.Failure error }
                    , Cmd.none
                    , Nothing
                    )

                Ok user ->
                    ( { model | user = RemoteData.Success user }
                    , Cmd.none
                    , Just (ChangeTitle ("Profile: " ++ user.username))
                    )


view : Model -> Html Msg
view model =
    div
        [ class "UserPage" ]
        (case model.user of
            RemoteData.Success user ->
                [ text user.username
                ]

            RemoteData.Loading ->
                [ text "Loading..." ]

            RemoteData.Failure _ ->
                [ text "Failed to fetch user" ]

            RemoteData.NotAsked ->
                [ text "" ]
        )

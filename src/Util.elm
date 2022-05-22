module Util exposing (extractDomain, posixDecoder, viewTimeAgo)

import Html exposing (..)
import Html.Attributes as HA
import Json.Decode as JD
import Time
import Url


{-| Decodes seconds since epoch into a date
-}
posixDecoder : JD.Decoder Time.Posix
posixDecoder =
    JD.int
        |> JD.map ((*) 1000)
        |> JD.map Time.millisToPosix


{-| Render Time.Posix to ISO-8601 format.

    posixToIso8601 time == "2011-11-18T14:54:39"

-}
posixToIso8601 : Time.Posix -> String
posixToIso8601 posix =
    let
        toMonthNumber : Time.Month -> Int
        toMonthNumber month =
            case month of
                Time.Jan ->
                    1

                Time.Feb ->
                    2

                Time.Mar ->
                    3

                Time.Apr ->
                    4

                Time.May ->
                    5

                Time.Jun ->
                    6

                Time.Jul ->
                    7

                Time.Aug ->
                    8

                Time.Sep ->
                    9

                Time.Oct ->
                    10

                Time.Nov ->
                    11

                Time.Dec ->
                    12
    in
    [ String.fromInt (Time.toYear Time.utc posix)
    , "-"
    , Time.toMonth Time.utc posix
        |> toMonthNumber
        |> String.fromInt
        |> String.padLeft 2 '0'
    , "-"
    , Time.toDay Time.utc posix
        |> String.fromInt
        |> String.padLeft 2 '0'
    , "T"
    , Time.toHour Time.utc posix
        |> String.fromInt
        |> String.padLeft 2 '0'
    , ":"
    , Time.toMinute Time.utc posix
        |> String.fromInt
        |> String.padLeft 2 '0'
    , ":"
    , Time.toSecond Time.utc posix
        |> String.fromInt
        |> String.padLeft 2 '0'
    ]
        |> String.join ""


viewTimeAgo : Time.Posix -> Time.Posix -> Html msg
viewTimeAgo start end =
    time
        [ HA.datetime (posixToIso8601 start) ]
        [ text (timeAgo start end) ]


timeAgo : Time.Posix -> Time.Posix -> String
timeAgo start end =
    let
        millis =
            Time.posixToMillis end - Time.posixToMillis start

        minutes =
            millis // 1000 // 60

        hours =
            minutes // 60

        days =
            hours // 24

        years =
            days // 365

        plural : Int -> String -> String
        plural n word =
            String.fromInt n
                ++ " "
                ++ word
                ++ (if n == 1 then
                        ""

                    else
                        "s"
                   )
                ++ " ago"
    in
    if minutes < 60 then
        plural minutes "minute"

    else if hours < 24 then
        plural hours "hour"

    else if days < 365 then
        plural days "day"

    else
        plural years "year"


extractDomain : String -> Maybe String
extractDomain url =
    Url.fromString url
        |> Maybe.map .host

module User exposing (User, decoder)

import Json.Decode as JD
import Time
import Util


type alias User =
    { username : String
    , karma : Int
    , created : Time.Posix
    , about : Maybe String
    }


decoder : JD.Decoder User
decoder =
    JD.map4 User
        (JD.field "id" JD.string)
        (JD.field "karma" JD.int)
        (JD.field "created" Util.posixDecoder)
        (JD.oneOf
            [ JD.field "about" (JD.map Just JD.string)
            , JD.succeed Nothing
            ]
        )

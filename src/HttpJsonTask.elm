module HttpJsonTask exposing
    ( jsonResolver
    , JsonArgs
    , jsonTask
    , postJsonTask
    , getJsonTask
    , resolve
    )

{-| Some basic json utils for use with elm/http.

@docs jsonResolver
@docs JsonArgs
@docs jsonTask
@docs postJsonTask
@docs getJsonTask
@docs resolve

-}

import Http exposing (Error(..), Resolver, Response(..))
import Json.Decode as JD
import Task exposing (Task)


{-| jsonResolver, similar to stringResolver or bytesResolver in elm/http.
-}
jsonResolver : JD.Decoder a -> Resolver Error a
jsonResolver decoder =
    Http.stringResolver <|
        resolve
            (\string ->
                Result.mapError JD.errorToString (JD.decodeString decoder string)
            )


{-| Args struct for jsonTask and its relatives.
-}
type alias JsonArgs a =
    { url : String, body : Http.Body, decoder : JD.Decoder a }


{-| make a json task; specify the http method as a string.
-}
jsonTask : String -> JsonArgs a -> Task Error a
jsonTask method args =
    Http.task
        { method = method
        , headers = []
        , url = args.url
        , body = args.body
        , resolver = jsonResolver args.decoder
        , timeout = Nothing
        }


{-| jsonTask with method POST.
-}
postJsonTask : JsonArgs a -> Task Error a
postJsonTask args =
    jsonTask "POST" args


{-| jsonTask with method GET.
-}
getJsonTask : JsonArgs a -> Task Error a
getJsonTask args =
    jsonTask "GET" args


{-| lifted out of elm/http
-}
resolve : (body -> Result String a) -> Response body -> Result Error a
resolve toResult response =
    case response of
        BadUrl_ url ->
            Err (BadUrl url)

        Timeout_ ->
            Err Timeout

        NetworkError_ ->
            Err NetworkError

        BadStatus_ metadata _ ->
            Err (BadStatus metadata.statusCode)

        GoodStatus_ _ body ->
            Result.mapError BadBody (toResult body)

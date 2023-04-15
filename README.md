# HttpJsonTask

This [elm package](https://package.elm-lang.org/packages/bburdette/httpjsontask/latest/) provides some 
support code for building json Tasks for use with elm/http.  


### Code example:

Here's one where I wanted the time of reply along with the reply itself.  `postJsonTask` is from this lib.

```
sendZIMsgExp : String -> ZI.SendMsg -> (Result Http.Error ( Time.Posix, ZI.ServerResponse ) -> Msg) -> Cmd Msg
sendZIMsgExp location msg tomsg =
    postJsonTask
        { url = location ++ "/private"
        , body = Http.jsonBody (ZI.encodeSendMsg msg)
        , decoder = ZI.serverResponseDecoder
        }
        |> Task.andThen (\x -> Task.map (\posix -> ( posix, x )) Time.now)
        |> Task.attempt tomsg
```


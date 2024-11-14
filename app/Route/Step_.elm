module Route.Step_ exposing (ActionData, Data, route, RouteParams, Msg, Model)

{-|

@docs ActionData, Data, route, RouteParams, Msg, Model

-}

import BackendTask
import BackendTask.Custom
import Console
import Effect
import ErrorPage
import FatalError
import Form
import Form.Field
import Form.Validation as Validation
import Head
import Html
import Html.Attributes as Attr
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.Form
import PagesMsg exposing (PagesMsg)
import Route exposing (Route(..))
import RouteBuilder
import Server.Request exposing (Request)
import Server.Response
import Shared
import UrlPath
import View


type alias Model =
    {}


type alias RouteParams =
    { step : String }


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.buildWithLocalState
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
        (RouteBuilder.serverRender { data = data, action = action, head = head })


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    let
        stepStatus : String
        stepStatus =
            case app.url of
                Just url ->
                    case url.path of
                        [ "step-1" ] ->
                            "Started Step 1"

                        [ "step-2" ] ->
                            "Completed Step 1 and Started Step 2"

                        [ "step-3" ] ->
                            "Completed Step 2 and Started Step 3"

                        [ "step-4" ] ->
                            "Completed Step 3 and Started Step 4"

                        _ ->
                            "Invalid step"

                Nothing ->
                    "Invalid step"
    in
    ( {}
      -- Log the step status to the console on the client
    , Console.log stepStatus
        |> Effect.fromCmd
    )


type Msg
    = NoOp


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions :
    RouteParams
    -> UrlPath.UrlPath
    -> Shared.Model
    -> Model
    -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    {}


data :
    RouteParams
    -> Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    BackendTask.succeed (Server.Response.render {})


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg Msg)
view app shared model =
    { title = "Step " ++ app.routeParams.step
    , body =
        [ Html.div [ Attr.style "margin" "16px" ]
            [ case app.routeParams.step of
                "step-1" ->
                    step1Form
                        |> Pages.Form.renderHtml []
                            (Form.options "step-1-form")
                            app

                "step-2" ->
                    step2Form
                        |> Pages.Form.renderHtml []
                            (Form.options "step-2-form")
                            app

                "step-3" ->
                    step3Form
                        |> Pages.Form.renderHtml []
                            (Form.options "step-3-form")
                            app

                "step-4" ->
                    Html.text "Finished"

                _ ->
                    Html.text "Invalid step"
            ]
        ]
    }


step1Form =
    Form.form
        (\name ->
            { combine =
                Validation.succeed name
            , view =
                \formState ->
                    [ Html.button
                        [ Attr.type_ "submit"
                        ]
                        [ if formState.submitting then
                            Html.text "Submitting..."

                          else
                            Html.text "Continue to Step 2"
                        ]
                    ]
            }
        )
        |> Form.field "name" Form.Field.text


step2Form =
    Form.form
        (\name ->
            { combine =
                Validation.succeed name
            , view =
                \formState ->
                    [ Html.button
                        [ Attr.type_ "submit"
                        ]
                        [ if formState.submitting then
                            Html.text "Submitting..."

                          else
                            Html.text "Continue to Step 3"
                        ]
                    ]
            }
        )
        |> Form.field "name" Form.Field.text


step3Form =
    Form.form
        (\phone ->
            { combine =
                Validation.succeed phone
            , view =
                \formState ->
                    [ Html.button
                        [ Attr.type_ "submit"
                        ]
                        [ if formState.submitting then
                            Html.text "Submitting..."

                          else
                            Html.text "Continue to Step 4"
                        ]
                    ]
            }
        )
        |> Form.field "phone" Form.Field.text


type alias ActionData =
    {}


action :
    RouteParams
    -> Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    -- pretend we are doing someting on the server that takes about a second
    case routeParams.step of
        "step-1" ->
            BackendTask.Custom.run "sleep" (Encode.int 1000) (Decode.succeed ())
                |> BackendTask.allowFatal
                |> BackendTask.map
                    (\_ ->
                        Route.Step_ { step = "step-2" }
                            |> Route.redirectTo
                    )

        "step-2" ->
            BackendTask.Custom.run "sleep" (Encode.int 1000) (Decode.succeed ())
                |> BackendTask.allowFatal
                |> BackendTask.map
                    (\_ ->
                        Route.Step_ { step = "step-3" }
                            |> Route.redirectTo
                    )

        "step-3" ->
            BackendTask.Custom.run "sleep" (Encode.int 1000) (Decode.succeed ())
                |> BackendTask.allowFatal
                |> BackendTask.map
                    (\_ ->
                        Route.Step_ { step = "step-4" }
                            |> Route.redirectTo
                    )

        "step-4" ->
            BackendTask.Custom.run "sleep" (Encode.int 1000) (Decode.succeed ())
                |> BackendTask.allowFatal
                |> BackendTask.map
                    (\_ ->
                        Route.Step_ { step = "step-5" }
                            |> Route.redirectTo
                    )

        _ ->
            Route.redirectTo Route.Index
                |> BackendTask.succeed

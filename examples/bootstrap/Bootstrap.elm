module Bootstrap exposing (main)

import Date exposing (Date, day, weekday, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, div, form, h1, input, label, text)
import Html.Attributes exposing (class, type_, value)
import Browser
import Time exposing (Weekday(..))


type Msg
    = ToDatePicker DatePicker.Msg


type alias Model =
    { date : Maybe Date
    , datePicker : DatePicker.DatePicker
    }


settings : DatePicker.Settings
settings =
    let
        isDisabled date =
            [ Sat, Sun ]
                |> List.member (weekday date)
    in
        { defaultSettings
            | isDisabled = isDisabled
            , inputClassList = [ ( "form-control", True ) ]
            , inputName = Just "date"
            , inputId = Just "date-field"
        }


init : ( Model, Cmd Msg )
init =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
        ( { date = Nothing
          , datePicker = datePicker
          }
        , Cmd.map ToDatePicker datePickerFx
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ datePicker } as model) =
    case msg of
        ToDatePicker subMsg ->
            let
                ( newDatePicker, datePickerFx, event ) =
                    DatePicker.update settings subMsg datePicker
            in
                ( { model
                    | date =
                        case event of
                            Picked date ->
                                Just date

                            _ ->
                                model.date
                    , datePicker = newDatePicker
                  }
                , Cmd.map ToDatePicker datePickerFx
                )


view : Model -> Html Msg
view ({ date, datePicker } as model) =
    div [ class "col-md-3" ]
        [ form []
            [ div [ class "form-group" ]
                [ label [] [ text "Pick a date" ]
                , DatePicker.view date settings datePicker
                    |> Html.map ToDatePicker
                ]
            , input
                [ type_ "submit"
                , class "btn btn-primary"
                , value "Submit"
                ]
                []
            ]
        ]

main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

module Components.App.Panels.MacroPanel exposing (..)

import Array exposing (Array)
import Components.App.Panels.Utils exposing (visibilityToDisplayStyle)
import Dict
import FontAwesome as Icon exposing (Icon)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Layering as Icon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import Html exposing (..)
import Html.Attributes exposing (class, id, style, type_)
import Html.Events exposing (onClick, onInput)
import Logic.App.Model exposing (Model)
import Logic.App.Msg exposing (Msg(..))
import Logic.App.Types exposing (Iota(..), Panel(..))
import Logic.App.Utils.GetIotaValue exposing (getIotaValueAsHtmlMsg, getIotaValueAsString)
import Logic.App.Utils.Utils exposing (ifThenElse)
import Settings.Theme exposing (iotaColorMap)


macroPanel : Model -> Html Msg
macroPanel model =
    let
        visibility =
            List.member MacroPanel model.ui.openPanels
    in
    div [ id "macro_panel", class "panel", visibilityToDisplayStyle visibility ]
        (h1 [ class "panel_title" ] [ text "Macros" ]
            :: renderMacroDict model
        )


renderMacroDict : Model -> List (Html Msg)
renderMacroDict model =
    let
        renderEntry entry =
            case entry of
                ( signature, ( displayName, _, iota ) ) ->
                    div [ class "stored_iota_container" ]
                        (div [ class "saved_iota_title" ]
                            [ button
                                [ class "trash_button"
                                , style "margin-left" "0.15em"
                                , style "margin-right" "0.2em"
                                , onClick (RemoveMacro signature)
                                ]
                                [ Icon.css
                                , Icon.trash |> Icon.styled [ Icon.xs ] |> Icon.view
                                ]
                            , input
                                [ class "stored_iota_label"
                                , style "margin-right" "0"
                                , Html.Attributes.value displayName
                                , onInput (ChangeMacroName signature)
                                ]
                                []
                            , button
                                [ class "add_button"
                                , onClick (InputPattern signature)
                                ]
                                [ Icon.css
                                , Icon.plus |> Icon.styled [ Icon.xs ] |> Icon.view
                                ]
                            ]
                            :: renderIotaBox iota
                        )
    in
    Dict.toList model.castingContext.macros
        |> List.map renderEntry
        |> List.intersperse (div [ class "divider" ] [])


renderIotaBox : Iota -> List (Html msg)
renderIotaBox iota =
    [ div [ style "display" "flex" ]
        [ div [ class "iota_box" ] (getIotaValueAsHtmlMsg 0 iota 0)
        ]
    ]


renderContents : Array Iota -> List (Html msg)
renderContents stack =
    let
        renderIota index iota =
            getIotaValueAsHtmlMsg index iota 0
    in
    Array.indexedMap renderIota stack
        |> Array.toList
        |> List.concat

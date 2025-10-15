module Logic.App.Patterns.OperatorUtils exposing (..)

import Array exposing (Array)
import Array.Extra as Array
import Length
import Logic.App.Types exposing (ActionResult, CastingContext, Iota(..), Mishap(..))
import Logic.App.Utils.Utils exposing (unshift)
import Quantity exposing (Quantity(..))
import Vector3d as Vec3d


makeConstant : Iota -> Array Iota -> CastingContext -> ActionResult
makeConstant iota stack ctx =
    { stack = unshift iota stack, ctx = ctx, success = True }


actionNoInput : Array Iota -> CastingContext -> (CastingContext -> ( Array Iota, CastingContext )) -> ActionResult
actionNoInput stack ctx action =
    let
        actionResult =
            action
                ctx
    in
    if nanOrInfinityCheck (Tuple.first actionResult) then
        { stack = unshift (Garbage MathematicalError) stack, ctx = Tuple.second actionResult, success = False }

    else
        { stack = Array.append (Tuple.first actionResult) stack, ctx = Tuple.second actionResult, success = True }


action1Input : Array Iota -> CastingContext -> (Iota -> Maybe Iota) -> (Iota -> CastingContext -> ( Array Iota, CastingContext )) -> ActionResult
action1Input stack ctx inputGetter action =
    let
        maybeIota =
            Array.get 0 stack

        newStack =
            Array.slice 1 (Array.length stack) stack
    in
    case maybeIota of
        Nothing ->
            { stack = unshift (Garbage NotEnoughIotas) newStack, ctx = ctx, success = False }

        Just iota ->
            case inputGetter iota of
                Nothing ->
                    { stack = unshift (Garbage IncorrectIota) newStack, ctx = ctx, success = False }

                Just _ ->
                    let
                        actionResult =
                            action iota ctx
                    in
                    if nanOrInfinityCheck (Tuple.first actionResult) then
                        { stack = unshift (Garbage MathematicalError) stack, ctx = Tuple.second actionResult, success = False }

                    else
                        { stack = Array.append (Tuple.first actionResult) newStack, ctx = Tuple.second actionResult, success = True }


action2Inputs : Array Iota -> CastingContext -> (Iota -> Maybe Iota) -> (Iota -> Maybe Iota) -> (Iota -> Iota -> CastingContext -> ( Array Iota, CastingContext )) -> ActionResult
action2Inputs stack ctx inputGetter1 inputGetter2 action =
    let
        maybeIota1 =
            Array.get 1 stack

        maybeIota2 =
            Array.get 0 stack

        newStack =
            Array.slice 2 (Array.length stack) stack
    in
    if maybeIota1 == Nothing || maybeIota2 == Nothing then
        { stack = Array.append (Array.map mapNothingToMissingIota <| Array.fromList <| moveNothingsToFront [ maybeIota1, maybeIota2 ]) newStack
        , ctx = ctx
        , success = False
        }

    else
        case ( Maybe.map inputGetter1 maybeIota1, Maybe.map inputGetter2 maybeIota2 ) of
            ( Just iota1, Just iota2 ) ->
                if iota1 == Nothing || iota2 == Nothing then
                    { stack =
                        Array.append
                            (Array.fromList
                                [ Maybe.withDefault (Garbage IncorrectIota) iota1
                                , Maybe.withDefault (Garbage IncorrectIota) iota2
                                ]
                            )
                            newStack
                    , ctx = ctx
                    , success = False
                    }

                else
                    let
                        actionResult =
                            action
                                (Maybe.withDefault (Garbage IncorrectIota) iota1)
                                (Maybe.withDefault (Garbage IncorrectIota) iota2)
                                ctx
                    in
                    if nanOrInfinityCheck (Tuple.first actionResult) then
                        { stack = unshift (Garbage MathematicalError) stack, ctx = Tuple.second actionResult, success = False }

                    else
                        { stack = Array.append (Tuple.first actionResult) newStack, ctx = Tuple.second actionResult, success = True }

            _ ->
                -- this should never happen
                { stack = unshift (Garbage CatastrophicFailure) newStack
                , ctx = ctx
                , success = False
                }


action3Inputs : Array Iota -> CastingContext -> (Iota -> Maybe Iota) -> (Iota -> Maybe Iota) -> (Iota -> Maybe Iota) -> (Iota -> Iota -> Iota -> CastingContext -> ( Array Iota, CastingContext )) -> ActionResult
action3Inputs stack ctx inputGetter1 inputGetter2 inputGetter3 action =
    let
        maybeIota1 =
            Array.get 2 stack

        maybeIota2 =
            Array.get 1 stack

        maybeIota3 =
            Array.get 0 stack

        newStack =
            Array.slice 3 (Array.length stack) stack
    in
    if maybeIota1 == Nothing || maybeIota2 == Nothing || maybeIota3 == Nothing then
        { stack = Array.append (Array.map mapNothingToMissingIota <| Array.fromList <| moveNothingsToFront [ maybeIota1, maybeIota2, maybeIota3 ]) newStack
        , ctx = ctx
        , success = False
        }

    else
        case ( Maybe.map inputGetter1 maybeIota1, Maybe.map inputGetter2 maybeIota2, Maybe.map inputGetter3 maybeIota3 ) of
            ( Just iota1, Just iota2, Just iota3 ) ->
                if iota1 == Nothing || iota2 == Nothing || iota3 == Nothing then
                    { stack =
                        Array.append
                            (Array.fromList
                                [ Maybe.withDefault (Garbage IncorrectIota) iota1
                                , Maybe.withDefault (Garbage IncorrectIota) iota2
                                , Maybe.withDefault (Garbage IncorrectIota) iota3
                                ]
                            )
                            newStack
                    , ctx = ctx
                    , success = False
                    }

                else
                    let
                        actionResult =
                            action
                                (Maybe.withDefault (Garbage IncorrectIota) iota1)
                                (Maybe.withDefault (Garbage IncorrectIota) iota2)
                                (Maybe.withDefault (Garbage IncorrectIota) iota3)
                                ctx
                    in
                    if nanOrInfinityCheck (Tuple.first actionResult) then
                        { stack = unshift (Garbage MathematicalError) stack, ctx = Tuple.second actionResult, success = False }

                    else
                        { stack = Array.append (Tuple.first actionResult) newStack, ctx = Tuple.second actionResult, success = True }

            _ ->
                -- this should never happen
                { stack = unshift (Garbage CatastrophicFailure) newStack
                , ctx = ctx
                , success = False
                }


spellNoInput : Array Iota -> CastingContext -> ActionResult
spellNoInput stack ctx =
    actionNoInput stack ctx (\_ -> ( Array.empty, ctx ))


spell1Input : Array Iota -> CastingContext -> (Iota -> Maybe Iota) -> ActionResult
spell1Input stack ctx inputGetter =
    action1Input stack ctx inputGetter (\_ _ -> ( Array.empty, ctx ))


spell2Inputs : Array Iota -> CastingContext -> (Iota -> Maybe Iota) -> (Iota -> Maybe Iota) -> ActionResult
spell2Inputs stack ctx inputGetter1 inputGetter2 =
    action2Inputs stack ctx inputGetter1 inputGetter2 (\_ _ _ -> ( Array.empty, ctx ))


spell3Inputs : Array Iota -> CastingContext -> (Iota -> Maybe Iota) -> (Iota -> Maybe Iota) -> (Iota -> Maybe Iota) -> ActionResult
spell3Inputs stack ctx inputGetter1 inputGetter2 inputGetter3 =
    action3Inputs stack ctx inputGetter1 inputGetter2 inputGetter3 (\_ _ _ _ -> ( Array.empty, ctx ))


nanOrInfinityCheck : Array Iota -> Bool
nanOrInfinityCheck array =
    Array.any
        (\i ->
            case i of
                Number number ->
                    isNaN number || isInfinite number

                Vector ( x, y, z ) ->
                    Array.any (\num -> isNaN num || isInfinite num) <| Array.fromList [ x, y, z ]

                _ ->
                    False
        )
        array


getPatternList : Iota -> Maybe Iota
getPatternList iota =
    case iota of
        IotaList list ->
            if
                List.all
                    (\i ->
                        case i of
                            PatternIota _ _ ->
                                True

                            _ ->
                                False
                    )
                <|
                    Array.toList list
            then
                Just iota

            else
                Nothing

        _ ->
            Nothing


getPatternOrIotaList : Iota -> Maybe Iota
getPatternOrIotaList iota =
    case iota of
        PatternIota _ _ ->
            Just iota

        IotaList _ ->
            Just iota

        _ ->
            Nothing


getPatternIota : Iota -> Maybe Iota
getPatternIota iota =
    case iota of
        PatternIota _ _ ->
            Just iota

        _ ->
            Nothing


getNumberOrVector : Iota -> Maybe Iota
getNumberOrVector iota =
    case iota of
        Vector _ ->
            Just iota

        Number _ ->
            Just iota

        _ ->
            Nothing


getInteger : Iota -> Maybe Iota
getInteger iota =
    case iota of
        Number number ->
            if toFloat (round number) == number then
                Just iota

            else
                Nothing

        _ ->
            Nothing


getPositiveInteger : Iota -> Maybe Iota
getPositiveInteger iota =
    case iota of
        Number number ->
            if toFloat (round number) == number && round number >= 0 then
                Just iota

            else
                Nothing

        _ ->
            Nothing


getNumber : Iota -> Maybe Iota
getNumber iota =
    case iota of
        Number _ ->
            Just iota

        _ ->
            Nothing


getVector : Iota -> Maybe Iota
getVector iota =
    case iota of
        Vector _ ->
            Just iota

        _ ->
            Nothing


getEntity : Iota -> Maybe Iota
getEntity iota =
    case iota of
        Entity _ ->
            Just iota

        _ ->
            Nothing


getIotaList : Iota -> Maybe Iota
getIotaList iota =
    case iota of
        IotaList _ ->
            Just iota

        _ ->
            Nothing


getBoolean : Iota -> Maybe Iota
getBoolean iota =
    case iota of
        Boolean _ ->
            Just iota

        _ ->
            Nothing


getAny : Iota -> Maybe Iota
getAny iota =
    Just iota


getNumberOrList : Iota -> Maybe Iota
getNumberOrList iota =
    case iota of
        Number _ ->
            Just iota

        IotaList _ ->
            Just iota

        _ ->
            Nothing


getIntegerOrList : Iota -> Maybe Iota
getIntegerOrList iota =
    case iota of
        Number number ->
            if toFloat (round number) == number then
                Just iota

            else
                Nothing

        IotaList _ ->
            Just iota

        _ ->
            Nothing


checkNotGarbage : Iota -> Bool
checkNotGarbage iota =
    case iota of
        Garbage _ ->
            False

        _ ->
            True


mapNothingToMissingIota maybeIota =
    case maybeIota of
        Nothing ->
            Garbage NotEnoughIotas

        Just iota ->
            iota


moveNothingsToFront : List (Maybe a) -> List (Maybe a)
moveNothingsToFront list =
    let
        comparison : Maybe a -> Maybe a -> Order
        comparison a b =
            let
                checkNothing x =
                    case x of
                        Nothing ->
                            1

                        _ ->
                            2
            in
            case compare (checkNothing a) (checkNothing b) of
                LT ->
                    LT

                EQ ->
                    EQ

                GT ->
                    GT
    in
    List.sortWith comparison list


checkEquality : Iota -> Iota -> Bool
checkEquality iota1 iota2 =
    let
        tolerance =
            0.0001
    in
    case ( iota1, iota2 ) of
        ( PatternIota pattern1 _, PatternIota pattern2 _ ) ->
            pattern1.signature == pattern2.signature

        ( IotaList list1, IotaList list2 ) ->
            List.map2 (\i1 i2 -> checkEquality i1 i2) (Array.toList list1) (Array.toList list2)
                |> List.member False
                |> not

        ( Vector vector1Tuple, Vector vector2Tuple ) ->
            let
                vector1 =
                    Vec3d.fromTuple Length.meters vector1Tuple

                vector2 =
                    Vec3d.fromTuple Length.meters vector2Tuple
            in
            Vec3d.equalWithin (Quantity tolerance) vector1 vector2

        ( Number number1, Number number2 ) ->
            abs (number1 - number2) < tolerance

        ( Entity entity1, Entity entity2 ) ->
            entity1 == entity2

        _ ->
            iota1 == iota2

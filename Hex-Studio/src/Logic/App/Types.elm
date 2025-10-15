module Logic.App.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)


type Panel
    = StackPanel
    | PatternPanel
    | ConfigHexPanel
    | FilePanel
    | MacroPanel
    | LibraryPanel


type HeldItem
    = Trinket
    | Artifact
    | Cypher
    | Focus
    | Spellbook
    | Pie
    | NoItem


type MetaActionMsg
    = None
    | ClearPatterns
    | Reset
    | Backspace
    | Wrap


type alias Pattern =
    { signature : String
    , startDirection : Direction
    , action : Array Iota -> CastingContext -> ActionResult
    , metaAction : MetaActionMsg
    , displayName : String
    , internalName : String
    , color : String
    , outputOptions : List IotaType
    , selectedOutput : Maybe ( IotaType, Iota )
    , active : Bool
    }


type PatternValidationState
    = Error
    | Success


type Mishap
    = InvalidPattern
    | NotEnoughIotas
    | IncorrectIota
    | VectorOutOfAmbit
    | EntityOutOfAmbit
    | EntityIsImmune
    | MathematicalError
    | IncorrectItem
    | IncorrectBlock
    | DelveTooDeep
    | TransgressOther
    | DisallowedAction
    | CatastrophicFailure


type IotaType
    = NumberType
    | VectorType
    | BooleanType
    | EntityType
    | IotaListType IotaType
    | PatternType
    | NullType
    | GarbageType


type Iota
    = Number Float
    | Vector ( Float, Float, Float )
    | Boolean Bool
    | Entity String
    | IotaList (Array Iota)
    | PatternIota Pattern Bool
    | Null
    | Garbage Mishap
    | OpenParenthesis (Array Iota)


type alias GridPoint =
    { x : Float
    , y : Float
    , offsetX : Int -- doubled coordinates (https://www.redblobgames.com/grids/hexagons/#coordinates)
    , offsetY : Int
    , radius : Float
    , used : Bool
    , color : String
    , connectedPoints : List PointConnection
    }


type alias PointConnection =
    { color : String, offsetX : Int, offsetY : Int, betweenOffsetValues : ( ( Int, Int ), ( Int, Int ), ( Int, Int ) ) }


type alias CoordinatePair =
    { x1 : Float
    , y1 : Float
    , x2 : Float
    , y2 : Float
    }


type alias IntCoordinatePair =
    { x1 : Int
    , y1 : Int
    , x2 : Int
    , y2 : Int
    }


type alias ElementLocation =
    { element : String
    , left : Int
    , bottom : Int
    , top : Int
    , right : Int
    }


type ApplyToStackResult
    = Succeeded
    | Failed
    | Considered


type alias CastingContext =
    { ravenmind : Maybe Iota
    , libraries : Dict ( Int, Int, Int ) (Dict String (Maybe Iota))
    , entities : Dict String { heldItem : HeldItem, heldItemContent : Maybe Iota }
    , macros : Dict String ( String, Direction, Iota )
    }


type alias ActionResult =
    { stack : Array Iota, ctx : CastingContext, success : Bool }


type Direction
    = Northeast
    | Northwest
    | East
    | West
    | Southeast
    | Southwest
    | ErrorDirection


type alias Grid =
    { width : Float
    , height : Float
    , points : List (List GridPoint)
    , drawnPoints : List GridPoint
    , drawing :
        { drawingMode : Bool
        , activePath : List GridPoint
        }
    }


type Overlay
    = NoOverlay
    | ImportTextOverlay
    | ExportTextOverlay


type alias Timeline =
    Array { stack : Array Iota, patternIndex : Int }


type ContextMenuContext
    = PatternItem Bool Bool Pattern Int --is active, is macro, pattern, index

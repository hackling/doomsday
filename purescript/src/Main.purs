module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref as Ref
import Control.Monad.Eff.Timer as Timer
import Data.Const (Const)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..), maybe)
import Data.Date (Date, canonicalDate, diff) as Date
import Data.Enum (toEnum)
import Data.Date.Component (Month(March)) as Date
import Data.Time.Duration (Days) as Date
import Control.Monad.Eff.Now (nowDate) as Date
import Spork.App as App
import Spork.EventQueue as EventQueue
import Data.DateTime.Locale (LocalValue(..))
import Spork.Html (Html, div, styles, text, Style(..))
import Spork.Interpreter (Interpreter(..), merge, never)

type Model =
    Maybe Date.Date


data Msg =
    Days Date.Date


data Sub a =
    TickDays (Date.Date -> a)


derive instance functorSub :: Functor Sub


init :: App.Transition (Const Void) Model Msg
init =
    App.purely Nothing

doomsDay :: Maybe Date.Date
doomsDay =
  Date.canonicalDate <$> toEnum 2018 <*> pure Date.March <*> toEnum 29

daysUntil :: Maybe Date.Date -> Maybe Date.Days
daysUntil date =
    Date.diff <$> doomsDay <*> date

printDaysUntil :: Maybe Date.Days -> String
printDaysUntil = maybe "?" show

render :: Model -> Html Msg
render model =
    div [ styles [Style "width" "300px"] ]
        [ text $ printDaysUntil $ daysUntil model
        ]


update :: Model -> Msg -> App.Transition (Const Void) Model Msg
update model msg =
    case msg of
        Days time ->
            App.purely (Just time)


subs :: Model -> App.Batch Sub Msg
subs model =
    App.lift (TickDays Days)


app :: App.App (Const Void) Sub Model Msg
app =
    { render
    , update
    , subs
    , init
    }


runSubscriptions :: forall i. Interpreter (Eff _) Sub i
runSubscriptions = Interpreter $ EventQueue.withAccumArray \queue -> do
    model <- Ref.newRef []

    let
        getDate = case _ of
                       LocalValue _ date -> date

        tick = do
            now <- Date.nowDate
            Ref.readRef model >>= traverse_ case _ of
                TickDays k -> queue.push (k $ getDate now)
            queue.run

        commit new = do
            old <- Ref.readRef model
            Ref.writeRef model new
            case old, new of
                [], _ -> void $ Timer.setInterval 1000 tick
                _, _  -> pure unit

            pure unit

    pure commit

main :: Eff _ Unit
main = do
    inst <- App.makeWithSelector (never `merge` runSubscriptions) app "#app"
    inst.run

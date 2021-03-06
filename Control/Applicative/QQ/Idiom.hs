{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}

-- | Idiom brackets. Vixey's idea.

module Control.Applicative.QQ.Idiom (i) where

import Control.Applicative
import Language.Haskell.Meta (parseExp)
import Language.Haskell.TH.Lib
import Language.Haskell.TH.Quote
import Language.Haskell.TH.Syntax

-- ghci> [$i| (,) "foo" "bar" |]
-- [('f','b'),('f','a'),('f','r'),('o','b'),('o','a'),('o','r'),('o','b'),('o','a'),('o','r')]
i :: QuasiQuoter
i = QuasiQuoter { quoteExp = applicateQ }

applicateQ :: String -> ExpQ
applicateQ s = case either fail unwindE (parseExp s) of
                  x:y:xs -> foldl
                              (\e e' -> [|$e <*> $e'|])
                              [|$(return x) <$> $(return y)|]
                              (fmap return xs)
                  _ -> fail "applicateQ fails."

unwindE :: Exp -> [Exp]
unwindE = go []
  where go acc (e `AppE` e') = go (e':acc) e
        go acc e = e:acc


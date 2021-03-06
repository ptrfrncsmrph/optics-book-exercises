{-# LANGUAGE RecordWildCards #-}

-- | Unlawful lenses in here
module Ch03.Laws where

import Control.Lens

-- | Violates get-set and set-get
unlawful1 :: Lens' (a, a) a
unlawful1 = lens g s
  where
    g :: (a, a) -> a
    g (x, _) = x
    s :: (a, a) -> a -> (a, a)
    s (x, _) y = (x, y)

-- `s (0, 1) (g (0, 1))` is `(0, 0)` not `(0, 1)`
-- `g (s (0, 1) 2)` is `0` not `2`

-- | Violates set-set (idempotence)
unlawful2 ::
  Semigroup m =>
  Lens' (a, m) m
unlawful2 = lens g s
  where
    g = snd
    s (x, m) m' = (x, m <> m')

-- `s (s (0, "") "a") "b"` is `(0, "ab")` not `(0, "a")`

-- | Violates all three
unlawful3 ::
  forall a m.
  Monoid m =>
  Lens' (a, m, m) m
unlawful3 = lens g s
  where
    g :: (a, m, m) -> m
    g (_, _, x) = x
    s :: (a, m, m) -> m -> (a, m, m)
    s (x, m, n) m' = (x, m <> m', n)

-- | Still useful, maybe? (Breaks get-set)
unlawful4 ::
  forall m.
  Monoid m =>
  Lens' (Maybe m) m
unlawful4 = lens g s
  where
    g :: Maybe m -> m
    g (Just m) = m
    g Nothing = mempty
    s :: Maybe m -> m -> Maybe m
    s (Just _) m = Just m
    s Nothing _ = Nothing

-----------------------------------------------

-- | Write a lawful lens for the following type
data Builder
  = Builder
      { _context :: [String],
        _build :: [String] -> String
      }

-- Not sure about this one
builder :: Lens' Builder String
builder = lens g s
  where
    g :: Builder -> String
    g Builder {..} = _build _context
    s :: Builder -> String -> Builder
    s b str =
      b
        { _build = \c' ->
            if c' == _context b
              then str
              else _build b c'
        }

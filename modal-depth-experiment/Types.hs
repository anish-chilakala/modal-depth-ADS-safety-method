{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE UnboxedTuples #-}

module Types where

-- The UNPACK pragma removes the heap pointer and stores the raw Double directly inside the record.
-- The '!' ensures the value is evaluated instantly, preventing lazy thunks.
data Scenario = Scenario 
  { c                :: {-# UNPACK #-} !Double
  , d_a              :: {-# UNPACK #-} !Double
  , d_e              :: {-# UNPACK #-} !Double
  , d_c              :: {-# UNPACK #-} !Double
  , d_s              :: {-# UNPACK #-} !Double
  , observed_context :: {-# UNPACK #-} !Double
  } deriving (Show, Eq)

data ModeSet = ModeSet 
  { d_a_active       :: !Bool
  , d_e_active       :: !Bool
  , d_c_active       :: !Bool
  , d_s_active       :: !Bool 
  } deriving (Show, Eq)

data Action = ACT | NO_ACT deriving (Show, Eq)

-- Unpack the Action and Bool so Result doesn't allocate memory when created.
data Result = Result 
  { action           :: !Action
  , correct          :: !Bool 
  } deriving (Show, Eq)





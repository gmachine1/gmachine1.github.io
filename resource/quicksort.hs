import Control.Monad
import Control.Monad.ST (ST (..), runST)
import Data.Array.ST

foreach :: (Monad m, Foldable t) => t a -> b -> (b -> a -> m b) -> m b
foreach xs v f = foldM f v xs

swap :: (Ix i, MArray arr e m) => arr i e -> i -> i -> m ()
swap arr ia ib = do
    a <- readArray arr ia
    b <- readArray arr ib
    writeArray arr ia b
    writeArray arr ib a

partition arr l r mid = do
    pivot <- readArray arr mid
    swap arr mid r
    slot <- foreach [l..r-1] l (\slot i -> do
        val <- readArray arr i
        if val < pivot
           then swap arr i slot >> return (slot+1)
           else return slot)
    swap arr slot r >> return slot

qsortImpl arr l r = when (r > l) $ do
    let mid = l + (r - l) `div` 2
    nmid <- partition arr l r mid
    qsortImpl arr l (nmid - 1)
    qsortImpl arr (nmid + 1) r

qsort :: [Int] -> [Int]
qsort xs = runST $ do
    let len = length xs - 1
    arr <- newListArray (0, len) xs :: ST s (STArray s Int Int)
    qsortImpl arr 0 len >> getElems arr

main = print $ qsort [2,1,7,4,5,3]
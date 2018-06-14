---
layout: post
title: Quicksort in Haskell
category: [haskell]
---

A common sales trick for Haskell and functional programming languages in general is the two-line quicksort presented below.

{% highlight haskell %}
qsort :: Ord a => [a] -> [a]
qsort [] = []
qsort (x:xs) = qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++ qsort (filter (>= x) xs)
{% endhighlight %}

Except this is far from real quicksort. First of all, the list type `[a]` has linear, not constant time access. Secondly, the sorting is done, not in place, by making a copies to construct the sorted list.

To do the genuine in-place quicksort, we will need some form of Haskell array. Here, we will use the `STArray`, which is powered by the ST Monad. The ST Monad can be summarized as follows.

### ST Monad

In `Monad.ST`, `runST` has the signature

```runST :: (forall s . ST s a) -> a```,

and the constructor has signature

```newSTRef :: a -> ST s (STRef s a)```
 
which means that the `s` in the computation cannot have any type constraints on it. It is an instance of what is called a phantom type, which is statically checked by the compiler but not used at runtime, which is handy for certain forms of protection. In this specific case, the `STRef` wrapped inside, by holding the phantom type `s` that is caged inside the `ST`. So we cannot directly take out the `STRef` to modify it, and instead all modifications of it must happen within the ST Monad. An example of what we cannot do:

```
Prelude Data.STRef Control.Monad.ST> runST $ newSTRef (15 :: Int)

<interactive>:11:9:
    Couldn't match type ‘a’ with ‘STRef s Int’
      because type variable ‘s’ would escape its scope
    This (rigid, skolem) type variable is bound by
      a type expected by the context: ST s a
      at <interactive>:11:1-28
    Expected type: ST s a
      Actual type: ST s (STRef s Int)
    Relevant bindings include it :: a (bound at <interactive>:11:1)
    In the second argument of ‘($)’, namely ‘newSTRef (15 :: Int)’
    In the expression: runST $ newSTRef (15 :: Int)
```

Below is an example of in place modifications within the ST Monad context.

{% highlight haskell %}
sumST :: Num a => [a] -> a
sumST xs = runST $ do           -- runST takes out stateful code and makes it pure again.
 
    n <- newSTRef 0             -- Create an STRef (place in memory to store values)
 
    forM_ xs $ \x -> do         -- For each element of xs ..
        modifySTRef n (+x)      -- add it to what we have in n.
 
    readSTRef n
{% endhighlight %}

### Array type

`STArray` is defined as
```data STArray s i e :: * -> * -> * -> *```,
with `s` the state variable argument for the `ST` type, `i` the index type, and `e` the element type.

It is an instance of `MArray`
`MArray (STArray s) e (ST s)` where `e` is the element type of the array.

Our array constructor is

```newListArray :: (Ix i, MArray a e m) => (i, i) -> [e] -> m (a i e)```.

This means to construct our array (of `Int`), we run along the lines of

```arr <- newListArray (0, len) xs :: ST s (STArray s Int Int)```

within a do block.

Afterwards we run quicksort on the `arr`, of course inside the ST Monad. The result is

{% highlight haskell %}
qsort :: [Int] -> [Int]
qsort xs = runST $ do
    let len = length xs - 1
    arr <- newListArray (0, len) xs :: ST s (STArray s Int Int)
    qsortImpl arr 0 len >> getElems arr
{% endhighlight %}

Essentially, in an ST Monad context, we create an array out of our list, sort it in place, and extract the result.

### Quicksort Implementation

The bulk of the logic of `qsortImpl` is within the `partition` function, that in imperative pseudocode could be described with the following:

```
algorithm partition(A, lo, hi) is
    pivot := A[hi]
    i := lo
    for j := lo to hi – 1 do
        if A[j] <= pivot then
            swap A[i] with A[j]
            i := i + 1
    swap A[i] with A[hi]
    return i
```

How to translate this to Haskell? In the for loop in the above pseudocode, there is the `i` swap index as state. What we want is to take in this state variable perform our maybe swap operation under this state and emit the next state, as we loop through the array. This can be modelled as a fold in a monadic context, implemented in Haskell as

```foldM :: (Foldable t, Monad m) => (b -> a -> m b) -> b -> t a -> m b```

We define `foreach` as `foldM` with arguments swapped for stylistic purposes

{% highlight haskell %}
foreach :: (Monad m, Foldable t) => t a -> b -> (b -> a -> m b) -> m b
foreach xs v f = foldM f v xs
{% endhighlight %}

We implement partition using this

{% highlight haskell %}
partition arr l r mid = do
    pivot <- readArray arr mid
    swap arr mid r
    slot <- foreach [l..r-1] l (\slot i -> do
        val <- readArray arr i
        if val < pivot
           then swap arr i slot >> return (slot+1)
           else return slot)
    swap arr slot r >> return slot
{% endhighlight %}

We also use in `partition` an auxiliary `swap` function, implemented below.

{% highlight haskell %}
swap :: (Ix i, MArray arr e m) => arr i e -> i -> i -> m ()
swap arr ia ib = do
    a <- readArray arr ia
    b <- readArray arr ib
    writeArray arr ia b
    writeArray arr ib a
{% endhighlight %}

Finally, comes the relatively straightforward

{% highlight haskell %}
qsortImpl arr l r = when (r > l) $ do
    let mid = l + (r - l) `div` 2
    nmid <- partition arr l r mid
    qsortImpl arr l (nmid - 1)
    qsortImpl arr (nmid + 1) r
{% endhighlight %}

Link to the complete source code [here](../../../../resource/quicksort.hs).

### References

[1] [https://stackoverflow.com/questions/12468622/how-does-the-st-monad-work](https://stackoverflow.com/questions/12468622/how-does-the-st-monad-work)

[2] [https://wiki.haskell.org/Monad/ST](https://wiki.haskell.org/Monad/ST)

[3] [http://sighingnow.github.io/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/quicksort_in_haskell.html](http://sighingnow.github.io/%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80/quicksort_in_haskell.html)

[4] [http://hackage.haskell.org/package/array-0.5.2.0/docs/Data-Array-ST.html](http://hackage.haskell.org/package/array-0.5.2.0/docs/Data-Array-ST.html)
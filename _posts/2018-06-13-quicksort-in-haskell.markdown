---
layout: post
title: Quicksort in Haskell
category: [haskell]
---

A common sales trick for Haskell and functional programming languages in general is the two-line quicksort below.

{% highlight haskell %}
quicksort :: Ord a => [a] -> [a]
quicksort [] = []
quicksort (x:xs) = quicksort (x:xs) = quicksort (filter (< x) xs) ++ [x] ++ quicksort (filter (>= x) xs)
{% endhighlight %}

Except this is far from real quicksort. First of all, the list type `[a]` has linear, not constant time access. Secondly, the sorting is done, not in place, by making a copies to construct the sorted product.

To do the genuine in-place quicksort, we will need some form of Haskell array. Here, we will use the `STArray`, which is powered by the `ST Monad`. The `ST Monad` can be summarized as follows.

In the `Monad.ST`, `runST` has the signature

`runST :: (forall s . ST s a) -> a`

, and the constructor has signature

`newSTRef :: a -> ST s (STRef s a)`
 
which means that the `s` in the computation cannot have any type constraints on it. It is an instance of what is called a phantom type, which is statically checked by the compiler but not used at runtime, which is handy for certain forms of protection. In this specific case, the `STRef` wrapped inside, by holding the phantom type `s` that is caged inside the `ST`. So we cannot directly take out the `STRef` to modify it, and instead all modifications of it must happen within the ST Monad. An example of what we cannot do:

{% highlight %}
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
{% endhighlight %}

sumST :: Num a => [a] -> a
sumST xs = runST $ do           -- runST takes out stateful code and makes it pure again.
 
    n <- newSTRef 0             -- Create an STRef (place in memory to store values)
 
    forM_ xs $ \x -> do         -- For each element of xs ..
        modifySTRef n (+x)      -- add it to what we have in n.
 
    readSTRef n 
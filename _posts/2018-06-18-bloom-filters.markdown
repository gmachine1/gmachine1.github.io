---
layout: post
title: Bloom filters
category: [data structures, distributed systems]
---

The Bloom filter is a quintessential data structure implemented widely across distributed systems to test set membership, imperfectly, with the benefit of space efficiency. It is imperfect in that there may be false positive matches, that is, elements not in the set may be deemed as in the set by the Bloom filter. The idea is rather simple. Start with a bit array of $m$ bits all set to $0$. Construct $k$ different hash functions which maps or hashes set elements to one of the array positions, generating a uniform random distribution. To test membership of the element, check whether all $k$ hashes of it are set. If the element is already inside the Bloom filter, this is guaranteed. If not, the other elements in the filter could have set all $k$ of the bits, resulting in a false positive. One can, of course, perform a probabilistic analysis of this, which I'll leave for later.

For now, I'll go over a usage example. In a Coursera course, there was this question on the final exam that prompted me to revisit the Bloom filter, which was


> You are debugging a key-value store that uses a Bloom filter in its SSTables. The Bloom filter uses two hash functions $H_1$ and $H_2$, where $H_i(x) = (x*i) \pmod{64}$. In a particular SSTable using $m = 64$ bits, the following keys are inserted: $1975, 1985, 1995, 2005$. Then, checking for membership of the key for $2015$ will:

Modulo $64$, the keys are $55, 1, 11, 21$. Multiplying by two gives $46, 2, 22, 42$. $2015$ gets hashed to $31$ and $62$ by $H_1$ and $H_2$ respectively, neither of which are in the Bloom filter.
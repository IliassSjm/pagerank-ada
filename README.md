# PageRank in Ada — dense and sparse

PageRank by power iteration on the Google matrix, written in Ada with two
interchangeable storage backends: a dense `n × n` matrix and a hand-rolled
CSR-style sparse structure (three lists `A`, `IA`, `JA`).

ENSEEIHT first-year *projet long* (PIM, 2020), done in a pair like every *projet
long*. The Ada sources under `src/` are that two-person submission, unmodified.
Everything under `tools/` and this README are mine, written later, in 2026, to
check that the original actually works.

## The algorithm

Given a directed graph of `n` pages with adjacency `A` (rows normalised, dangling
rows set uniform), the Google matrix is

```
G = α · A + (1 − α)/n · 𝟙𝟙ᵀ
```

and the ranking is the stationary distribution `π = πG`, computed by power
iteration. Defaults are `α = 0.85` and 150 iterations, matching the assignment.

The output is two files next to the input: `<graph>.p` holds the weights (a header
line `n α iterations`, then one weight per page), `<graph>.ord` holds the page
indices sorted by decreasing weight.

## Build and run

```bash
cd src && gnatmake pagerank.adb

./pagerank ../data/exemple_sujet.net             # sparse backend, alpha=0.85, 150 iters
./pagerank -P ../data/exemple_sujet.net          # dense backend
./pagerank -A 0.90 -I 200 ../data/worm.net       # tune damping / iteration count
```

Input format: the page count on the first line, then one `source target` pair per
line. Two graphs are included; the assignment's larger corpora (a ~9 MB web crawl)
are not, since they aren't mine to redistribute.

## Verification

`tools/reference_pagerank.py` is an independent NumPy implementation that reads the
same format and compares against what the Ada program wrote.

On the assignment's own example the Ada output is **exact** — the weights agree to
every printed digit and the ranking is identical:

```
$ ./pagerank ../data/exemple_sujet.net
$ python ../tools/reference_pagerank.py ../data/exemple_sujet.net
exemple_sujet.net: 6 pages, 10 edges, alpha=0.85, 150 iterations
sum of weights = 1.000000000
top 10: 3(0.34870), 5(0.26860), 4(0.19990), 1(0.07368), 2(0.05741), 0(0.05170)
Ada .ord top 6: MATCH
Ada .p weights sum to 1.000000500
```

Both backends produce identical rankings on every graph tested, which is the point
of having two.

## Known limitation

On `worm.net` the Ada output disagrees with the reference. The cause is in
`Construire_A_IA_JA` (`src/g_creuse.adb`), which infers the column convention of
the whole file from the **first edge only**:

```ada
if Numero_Page > Numero_Page_Pointee then
   ordre := 0;                    -- assume the file is "target source"
   ...
```

`worm.net` opens with `12 0`, so the reader decides the file is transposed and
swaps every subsequent pair. The consequence is precise and reproducible: the
program ranks the **reverse** graph.

```
$ python ../tools/reference_pagerank.py ../data/worm.net
Ada .ord top 10: MISMATCH

$ python ../tools/reference_pagerank.py ../data/worm.net --reverse
Ada .ord top 10: MATCH          # the Ada output is the reversed graph's ranking
```

A second symptom follows from the same swap: after transposing, pages with no
outgoing edges are no longer given a uniform row, so probability mass leaks out of
the chain and the weights sum to **0.613** instead of 1.

Two assumptions are doing the damage, and neither is checked at runtime:

1. the edge list is sorted by source page (the CSR builder detects the end of a row
   by watching the source index increase), and
2. the orientation of the whole file can be read off its first line.

The fix is an explicit flag rather than a heuristic. The original code is left as
submitted; the diagnosis is the contribution.

## Layout

```
src/       pagerank.adb, g_naive.{ads,adb} (dense), g_creuse.{ads,adb} (sparse)
data/      two sample graphs
tools/     NumPy reference implementation and comparison harness
legacy/    an earlier dense-only draft and a second sparse variant, kept for history
```

## License

MIT

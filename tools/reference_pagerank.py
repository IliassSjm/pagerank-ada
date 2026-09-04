"""Independent NumPy reference for the Ada implementation.

Reads the same `.net` format, computes PageRank by dense power iteration, and
compares against the `.p` (weights) and `.ord` (ranking) files the Ada program
writes.  This is a verification harness written in 2026, not part of the
original 2023 submission.

Usage
-----
    python tools/reference_pagerank.py data/exemple_sujet.net
    python tools/reference_pagerank.py data/worm.net --reverse
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np


def read_net(path: Path) -> tuple[int, list[tuple[int, int]]]:
    """First token is the page count; the rest are `source target` pairs."""
    tokens = path.read_text().split()
    n = int(tokens[0])
    rest = [int(t) for t in tokens[1:]]
    if len(rest) % 2:
        raise ValueError(f"{path}: odd number of edge tokens")
    return n, list(zip(rest[0::2], rest[1::2]))


def pagerank(
    n: int,
    edges: list[tuple[int, int]],
    alpha: float = 0.85,
    iterations: int = 150,
) -> np.ndarray:
    """Dense power iteration on the Google matrix.

    Dangling pages (no outgoing link) are given a uniform row, which keeps the
    matrix stochastic and the stationary vector normalised.
    """
    A = np.zeros((n, n))
    for i, j in edges:
        A[i, j] = 1.0
    for i in range(n):
        total = A[i].sum()
        A[i] = A[i] / total if total else np.full(n, 1.0 / n)

    G = alpha * A + (1.0 - alpha) / n
    pi = np.full(n, 1.0 / n)
    for _ in range(iterations):
        pi = pi @ G
    return pi


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("net", type=Path)
    ap.add_argument("-a", "--alpha", type=float, default=0.85)
    ap.add_argument("-i", "--iterations", type=int, default=150)
    ap.add_argument("--reverse", action="store_true",
                    help="transpose the edge list before ranking")
    args = ap.parse_args()

    n, edges = read_net(args.net)
    if args.reverse:
        edges = [(j, i) for i, j in edges]
    pi = pagerank(n, edges, args.alpha, args.iterations)
    order = np.argsort(-pi)

    print(f"{args.net}: {n} pages, {len(edges)} edges, "
          f"alpha={args.alpha}, {args.iterations} iterations")
    print(f"sum of weights = {pi.sum():.9f}")
    print("top 10:", ", ".join(f"{p}({pi[p]:.5f})" for p in order[:10]))

    stem = args.net.with_suffix("")
    ord_file, p_file = Path(f"{stem}.ord"), Path(f"{stem}.p")
    if ord_file.exists():
        ada = [int(t) for t in ord_file.read_text().split()]
        k = min(10, len(ada))
        print(f"Ada .ord top {k}: {'MATCH' if ada[:k] == list(order[:k]) else 'MISMATCH'}")
    if p_file.exists():
        ada_w = [float(t) for t in p_file.read_text().split()[3:]]
        print(f"Ada .p weights sum to {sum(ada_w):.9f} "
              f"(should be 1 if the chain is stochastic)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

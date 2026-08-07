#!/usr/bin/env python3
"""Host proof for the bounded deferred draw-job stream."""

from __future__ import annotations

import random
from dataclasses import dataclass


LOGICAL_COLUMNS = 80
MAX_RENDER_PORTAL_DEPTH = 6
COLUMN_WIDTH = 4
JOB_SIZE = 20
JOB_CAPACITY = LOGICAL_COLUMNS * MAX_RENDER_PORTAL_DEPTH


@dataclass(frozen=True)
class Event:
    kind: int
    ray: bytes
    column: int
    clip_start: int
    clip_end: int
    top: int
    bottom: int


def make_event(rng: random.Random, column: int, kind: int) -> Event:
    clip_start = rng.randrange(240)
    clip_end = rng.randrange(clip_start + 1, 241)
    top = rng.randrange(241)
    bottom = rng.randrange(top, 241)
    return Event(
        kind=kind,
        ray=rng.randbytes(14),
        column=column,
        clip_start=clip_start,
        clip_end=clip_end,
        top=top,
        bottom=bottom,
    )


def encode(event: Event) -> bytes:
    return b"".join(
        (
            event.ray,
            bytes(
                (
                    event.column,
                    event.clip_start,
                    event.clip_end,
                    event.top,
                    event.bottom,
                    event.kind,
                )
            ),
        )
    )


def decode(job: bytes) -> Event:
    if len(job) != JOB_SIZE:
        raise AssertionError(f"job size {len(job)} != {JOB_SIZE}")
    return Event(
        kind=job[19],
        ray=job[:14],
        column=job[14],
        clip_start=job[15],
        clip_end=job[16],
        top=job[17],
        bottom=job[18],
    )


def verify_random_streams() -> int:
    rng = random.Random(0xD3F3_2026)
    checked = 0

    for _ in range(100_000):
        immediate: list[Event] = []
        for column in range(LOGICAL_COLUMNS):
            depth = rng.randrange(MAX_RENDER_PORTAL_DEPTH + 1)
            for layer in range(depth):
                # A nonterminal layer is a mask; the last layer can be any of
                # the three high-level operations used by the C compositor.
                kind = 2 if layer + 1 < depth else rng.randrange(3)
                immediate.append(make_event(rng, column, kind))

        if len(immediate) > JOB_CAPACITY:
            raise AssertionError("modeled compositor exceeded hard capacity")
        replay = [decode(encode(event)) for event in immediate]
        if replay != immediate:
            raise AssertionError("deferred replay changed draw order or payload")
        if any(event.column * COLUMN_WIDTH > 316 for event in replay):
            raise AssertionError("logical-column reconstruction exceeded LCD")
        checked += len(immediate)

    return checked


def verify_worst_case() -> None:
    rng = random.Random(1)
    events = [
        make_event(rng, column, 2)
        for column in range(LOGICAL_COLUMNS)
        for _ in range(MAX_RENDER_PORTAL_DEPTH)
    ]
    if len(events) != JOB_CAPACITY:
        raise AssertionError("hard-capacity derivation changed")
    if sum(len(encode(event)) for event in events) != JOB_CAPACITY * JOB_SIZE:
        raise AssertionError("job-buffer byte derivation changed")


def main() -> None:
    verify_worst_case()
    events = verify_random_streams()
    print(
        "deferred overlap model exact: "
        f"{events} randomized high-level draws; "
        f"hard max {JOB_CAPACITY} jobs x {JOB_SIZE} bytes = "
        f"{JOB_CAPACITY * JOB_SIZE} bytes; original column/layer order retained"
    )


if __name__ == "__main__":
    main()

---
title: Families compose the building blocks
state: proposed
kind: implementation
part-of: combinations-layered-from-building-blocks
needs: [export-building-block-combinations]
touches: [sources/combinations/families.nix, tests/]
---

# Families compose the building blocks

Rewrite each family as `base` plus blocks, as the families table in [the end state](combinations-layered-from-building-blocks.md) lists. `skill-collections` shrinks from 60 to 46 skills and `skill-packaging` from 61 to 47; the other families keep their content.

Can ship in the same PR as [the export of the blocks](export-building-block-combinations.md).

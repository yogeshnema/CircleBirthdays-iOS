# Relationship Rules

This file is the source of truth for explaining relationship answers in the in-app family assistant.

## Family ID Convention

- A single base family ID such as `A` can be the root person.
- A spouse is represented by adding `0` to the partner's family ID. For example, `A0` is the spouse of `A`, and `A10` is the spouse of `A1`.
- Children extend the parent's base family ID by one branch character. For example, children of `A` can be `A1`, `A2`, `A3`.
- Children of `A1` can be `A11`, `A12`, `A13`, while `A10` remains the spouse of `A1`.
- Siblings usually share the same parent base and have IDs at the same depth.
- Older and younger labels are inferred from birth date when available, otherwise by branch order.
- Relationship answers are from the current logged-in user's point of view unless the question explicitly asks otherwise.

## Explanation Template

When answering a relationship question:

1. Identify the target person and the current logged-in user.
2. Compare their base family IDs, ignoring spouse suffix `0` for generation math.
3. Use spouse suffix and gender to choose husband/wife/in-law terms.
4. Use generation difference for parent, child, grandparent, and grandchild terms.
5. Use shared parent or extended sibling paths for sibling, uncle/aunt, nephew/niece, and cousin-side terms.
6. Answer with the relation label and a short reason in plain language.

## Relationship Labels

### Self

Use when the target is the current user. Say that this is the user's own profile.

### Husband

Use when the target is the male spouse of the current user.

### Wife

Use when the target is the female spouse of the current user.

### Papa

Use when the target is the current user's father or father-position parent.

### Mummy

Use when the target is the current user's mother or mother-position parent.

### Beta

Use when the target is the current user's son.

### Beti

Use when the target is the current user's daughter.

### Bhaiya

Use for an elder brother in the same generation.

### Bhai

Use for a younger brother or same-generation brother when elder status is not known.

### Didi

Use for an elder sister in the same generation.

### Behan

Use for a younger sister or same-generation sister when elder status is not known.

### Bhabhi

Use for the wife of a brother or male same-generation relative.

### Jijaji

Use for the husband of a sister or female same-generation relative.

### Dadaji

Use for the paternal grandfather or grandfather-position elder on the father's side.

### Dadi

Use for the paternal grandmother or grandmother-position elder on the father's side.

### Nana

Use for the maternal grandfather or grandfather-position elder on the mother's side.

### Nani

Use for the maternal grandmother or grandmother-position elder on the mother's side.

### Bade Papa

Use for the father's elder brother or elder paternal uncle.

### Chachaji

Use for the father's younger brother or younger paternal uncle.

### Badi Amma

Use for the wife of Bade Papa or an elder paternal aunt by marriage.

### Chachiji

Use for the wife of Chachaji or a younger paternal aunt by marriage.

### Badi Bua

Use for the father's elder sister.

### Choti Bua

Use for the father's younger sister.

### Bade Fufa

Use for the husband of Badi Bua.

### Chote Fufa

Use for the husband of Choti Bua.

### Bade Mamaji

Use for the mother's elder brother.

### Chote Mamaji

Use for the mother's younger brother.

### Badi Mamiji

Use for the wife of Bade Mamaji.

### Choti Mamiji

Use for the wife of Chote Mamaji.

### Badi Mausi

Use for the mother's elder sister.

### Choti Mausi

Use for the mother's younger sister.

### Bade Mausa

Use for the husband of Badi Mausi.

### Chote Mausa

Use for the husband of Choti Mausi.

### Bhatija

Use for a brother's son.

### Bhatiji

Use for a brother's daughter.

### Bhanja

Use for a sister's son.

### Bhanji

Use for a sister's daughter.

### Pota

Use for a son's son.

### Poti

Use for a son's daughter.

### Nati

Use for a daughter's son.

### Natin

Use for a daughter's daughter.

### Bahu

Use for a son's wife or a male descendant's wife.

### Damand

Use for a daughter's husband or a female descendant's husband.

### Sasurji

Use for the spouse's father.

### Saasuma

Use for the spouse's mother.

### Devar

Use for a husband's younger brother.

### Jeth

Use for a husband's elder brother.

### Nanad

Use for a husband's sister.

### Saala

Use for a wife's brother.

### Saali

Use for a wife's sister.

### Grandparent

Use when the target is more than two generations above the current user and a specific grandparent term cannot be inferred.

### Grandchild

Use when the target is more than two generations below the current user and a specific grandchild term cannot be inferred.

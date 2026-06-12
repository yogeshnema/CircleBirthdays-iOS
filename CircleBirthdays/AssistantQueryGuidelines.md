# Assistant Query Guidelines

This file describes how the in-app assistant should answer profile-directory questions from the cached member data.

## Profile Cache Source

- Use the live in-memory member cache: `AppViewModel.allResolvedMembers`.
- Each cached profile can include name, family ID, gender, date of birth, phone, email, location, spouse, parents, relationship, address, status, and event dates.
- Prefer resolved profile fields because they include inferred parents, spouse, immediate family, and relationship labels.

## Name and Profile Matching

- Match people by name first.
- Also use family ID, spouse name, father name, mother name, relationship, and location as searchable profile context.
- If multiple people match, ask which one and show enough identifying information to choose correctly.
- Include family ID and birthday/location when useful for disambiguation.

## Birth Year Queries

- Questions like "how many people were born in 1985", "born in 1985", "1985 birth", or "who was born in 1985" should filter profiles by `dateOfBirth` year.
- For "how many" questions, answer with the count and a short sample of matching names.
- For "who/list/show" questions, list matching people with birthday, family ID, and relationship when available.
- If no profiles match, say no saved profiles match that birth year.

## Profile Count Queries

- Count questions should use cached profiles and state what was counted.
- Support counts by active member, pending member, birth year, location, gender, and relationship where possible.
- When the question is ambiguous, explain the available query examples.

## Profile Detail Queries

- If a question asks about a known person without specifying a field, summarize the profile from cached fields.
- Include name, family ID, relationship, birthday, parents, spouse, location, and phone when saved.
- Do not invent missing fields; say "not saved" or omit unavailable fields.

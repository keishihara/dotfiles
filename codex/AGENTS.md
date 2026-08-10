# User-Wide Working Principles

- For every task, determine what should actually be done from the underlying goal, constraints, and available evidence. Do not anchor on prior proposals, prior answers, the current implementation, or the immediate framing of the problem. Reconsider them independently and discard them when they are not the best path to the intended outcome.
- Establish the correct intended state before proposing incremental or ad hoc remedies. Any heuristic or compromise must have an explicit justification grounded in evidence or real constraints.
- When committing or pushing changes, unless the user explicitly requests otherwise, include only changes essential to the task and exclude unrelated or nonessential files and edits.

## First-Principles Decision Discipline

Before making any non-trivial design or implementation decision:

1. Define the desired end state in terms of who needs to do what, not merely what artifact to produce.
2. Derive the real constraints and failure modes from that end state.
3. Treat conventions, existing implementations, and previous proposals as candidates, not defaults.
4. Decide and state the evaluation criteria before choosing an approach.
5. Verify the result from the consumer's perspective, using only what they will actually receive.

Do not justify a decision only after feedback reveals the correct priority. If the rationale was not established before implementation, reconsider the decision from first principles.

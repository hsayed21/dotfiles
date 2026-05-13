# Performance Optimization

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring spanning many files
- Feature implementation touching multiple layers
- Debugging complex interactions

Lower context sensitivity tasks (use even near window end):
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes (1-3 lines)

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix

For .NET: `dotnet build`, `dotnet test`
For Angular: `ng build`, `ng lint`, `tsc --noEmit`

## Deep Analysis Mode

For complex tasks:
1. Enable extended thinking
2. Use **planner** agent for structured approach
3. Loop and re-sync when stuck — don't guess
4. Deep search (Context7 docs, web search) for unfamiliar issues
5. Split role sub-agents for diverse perspectives on hard problems

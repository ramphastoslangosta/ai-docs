# Anti-Patterns to Avoid

1. **Router without data processing** - app/routes/quotes.py returned raw Quote objects
2. **Missing template compatibility testing** - No tests for template data requirements
3. **Premature duplicate removal** - TASK-012 attempted before router verification
4. **No integration tests** - Only unit tests existed
5. **Insufficient deployment verification** - Router deployed without template smoke tests

# Patterns to Follow

1. **Presenter Pattern** - app/presenters/quote_presenter.py (HOTFIX-20251001-001 fix)
2. **Keep duplicates during transition** - main.py kept old routes until verification
3. **Integration testing** - tests/test_integration_quotes_routes.py (13 tests)
4. **Gradual rollout** - Test env first, production after verification

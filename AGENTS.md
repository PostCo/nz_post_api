# AGENTS

This project is a Ruby gem wrapper for the NZ Post API.

## Principles

1.  **TDD**: Write tests first using RSpec.
2.  **Mocking**: Use WebMock for all external HTTP requests.
3.  **Structure**: Follow the pattern of having resources and a client.
4.  **Code Style**: Follow standard Ruby conventions.

## Development Workflow

1.  Create a spec file for the new feature.
2.  Implement the test case.
3.  Implement the code to pass the test.
4.  Refactor.

## API Documentation

- **Authentication**: Requires `client_id` and `client_secret` to get a Bearer token.
- **Resources**:
  - `ParcelAddress`: Address search/validation.
  - `ParcelLabel`: Label creation, status check, download.

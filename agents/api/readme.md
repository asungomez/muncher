# API

Index of conventions for working on the API: a FastAPI application in `api/`,
with its sources in `api/src/muncher_api/`, run from the image built by
`docker/api.Dockerfile` and reached at `http://localhost:9100`.

In the cloud the same application runs as a Lambda function behind the
front-end's CloudFront distribution, under `/api`. Only the entry point differs
— `aws_lambda.py`, where Mangum adapts the ASGI application to the function's
events — so nothing else in `api/` knows where it is running.

These documents record how the API is already built. Where a task would depart
from what they describe, that is a convention change — decide it deliberately and
update the document, rather than leaving the two to disagree.

The rules that apply to code in any language are in
[coding/readme.md](../coding/readme.md). Read both.

## Index

Read the file that matches the task before starting work.

| Read | When |
| --- | --- |
| [types.md](types.md) | Writing annotations, or declaring a model an endpoint returns. |
| [docstrings.md](docstrings.md) | Writing a docstring, on anything. |

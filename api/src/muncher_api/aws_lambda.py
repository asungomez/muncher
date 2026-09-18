"""The entry point Lambda invokes in the cloud.

There is no server there: CloudFront invokes the function URL and Mangum turns
that event into the ASGI call uvicorn makes locally, so the application in
`main.py` is the same one in both places and knows about neither.
"""

from mangum import Mangum

from muncher_api.main import app

# CloudFront routes /api/* to the function URL without rewriting the path, so
# the prefix arrives here and comes off before the routers match. Locally the
# Vite proxy strips it instead; see front-end/vite.config.ts.
handler = Mangum(app, api_gateway_base_path="/api")

class ContentSecurityPolicyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        response['Content-Security-Policy'] = (
            "default-src 'self'; "
            "script-src 'self' https://unpkg.com https://cdn.jsdelivr.net; "
            "style-src 'self' https://unpkg.com https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; "
            "object-src 'none';"
        )
        return response

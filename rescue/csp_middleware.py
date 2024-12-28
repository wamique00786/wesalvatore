class ContentSecurityPolicyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        response['Content-Security-Policy'] = (
            "default-src 'self'; "
            "script-src 'self' https://unpkg.com https://cdn.jsdelivr.net 'unsafe-inline' 'unsafe-eval'; "  # Allow scripts from trusted sources
            "style-src 'self' https://unpkg.com https://cdn.jsdelivr.net 'unsafe-inline'; "  # Allow styles from trusted sources
            "img-src 'self' data: https://*.tile.openstreetmap.org https://unpkg.com; "  # Allow images from trusted sources
            "font-src 'self' https://cdnjs.cloudflare.com; "  # Allow fonts from trusted sources
            "object-src 'none';"  # Disallow all object sources
        )
        return response
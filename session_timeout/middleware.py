# session_timeout/middleware.py

from django.shortcuts import redirect
from django.urls import reverse
from django.utils.deprecation import MiddlewareMixin
from django.contrib import messages

class SessionTimeoutMiddleware(MiddlewareMixin):
    def process_request(self, request):
        if request.user.is_authenticated:
            if not request.session.get('last_activity'):
                request.session['last_activity'] = request.session.get('_session_expiry_timestamp')
            
            last_activity = request.session.get('last_activity')
            if last_activity and (request.session.get_expiry_age() <= 0):
                messages.warning(request, 'Your session has expired. Please log in again.')
                return redirect('logout')  # Replace 'logout' with your logout URL name

            request.session['last_activity'] = request.session.get_expiry_date().timestamp()
        return None
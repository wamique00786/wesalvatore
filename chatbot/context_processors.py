from .models import ChatMessage

def chat_widget_context(request):
    if request.user.is_authenticated:
        chat_history = ChatMessage.objects.filter(user=request.user).order_by('-timestamp')[:50]
        return {'chat_history': chat_history}
    return {'chat_history': []}
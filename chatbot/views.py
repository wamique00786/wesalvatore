from django.shortcuts import render
from django.http import JsonResponse
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_http_methods
from .models import ChatMessage
import random

def generate_bot_response(message):
    # Convert message to lowercase for easier matching
    message = message.lower()
    
    # Adoption related responses
    if any(word in message for word in ['adopt', 'adoption', 'pet', 'take home']):
        responses = [
            "I'd be happy to help you with adoption! Here's what you need to know:\n"
            "1. Browse available animals on our adoption page\n"
            "2. Fill out an adoption application\n"
            "3. Schedule a meet-and-greet\n"
            "Would you like me to guide you through the process?",
            
            "That's wonderful that you're considering adoption! We have many lovely animals "
            "waiting for their forever homes. What type of pet are you interested in?",
            
            "Adoption is a beautiful commitment! Before proceeding, please consider:\n"
            "- Space in your home\n"
            "- Time for pet care\n"
            "- Financial responsibility\n"
            "Would you like to discuss any of these aspects?",
        ]
        return random.choice(responses)
    
    # Donation related responses
    elif any(word in message for word in ['donate', 'donation', 'contribute', 'help', 'money']):
        responses = [
            "Thank you for your interest in supporting our cause! You can donate through:\n"
            "1. One-time donation\n"
            "2. Monthly sponsorship\n"
            "3. Specific animal sponsorship\n"
            "Which option would you like to learn more about?",
            
            "Your generosity helps save lives! We accept:\n"
            "- Financial donations\n"
            "- Pet supplies\n"
            "- Volunteer time\n"
            "How would you like to contribute?",
            
            "Every donation makes a difference! Currently, we're running a special campaign "
            "where every donation is matched by our partners. Would you like to know more?",
        ]
        return random.choice(responses)
    
    # Rescue related responses
    elif any(word in message for word in ['rescue', 'save', 'emergency', 'help animal', 'injured']):
        responses = [
            "For animal emergencies, please:\n"
            "1. Call our rescue hotline: [EMERGENCY_NUMBER]\n"
            "2. Share the location\n"
            "3. Stay with the animal if safe\n"
            "Is this an emergency situation?",
            
            "Our rescue team is available 24/7. To report an animal in need:\n"
            "- Send photos if possible\n"
            "- Note any injuries\n"
            "- Provide exact location\n"
            "Can you provide these details?",
            
            "Thank you for caring about animals in need! Please let me know:\n"
            "1. Is the animal injured?\n"
            "2. Where is it located?\n"
            "3. Is it in immediate danger?",
        ]
        return random.choice(responses)
    
     # Location/Contact related responses
    elif any(word in message for word in ['location', 'address', 'contact', 'phone', 'visit']):
        responses = [
            "You can find us at:\n"
            "Pune, Maharashtra, India\n" 
            "Phone: +911234567890\n"
            "Email: contact@wesalvator.com\n"
            "Would you like directions?",
        
            "We're open Monday-Saturday, 9 AM - 6 PM.\n"
            "Sunday: 10 AM - 4 PM\n"
            "Best time for visits is during weekday afternoons!",
        
            "You can reach us through:\n"
            "- Phone: +911234567890\n"
            "- Email: contact@wesalvator.com\n" 
            "- Social Media: @WesalvatorRescue\n"
            "How would you prefer to connect?",
        ]
        return random.choice(responses)
    
    # Volunteer related responses
    elif any(word in message for word in ['volunteer', 'help out', 'work', 'join']):
        responses = [
            "We love new volunteers! Here are our opportunities:\n"
            "1. Animal Care\n"
            "2. Event Support\n"
            "3. Administrative Help\n"
            "4. Foster Program\n"
            "Which interests you?",
            
            "Thank you for wanting to volunteer! We require:\n"
            "- Minimum 4 hours/week commitment\n"
            "- Orientation attendance\n"
            "- Age 18+ (or 16+ with guardian)\n"
            "Would you like to sign up?",
            
            "Volunteers are our heroes! Current needs:\n"
            "- Morning feeders\n"
            "- Weekend support\n"
            "- Transport helpers\n"
            "When are you available?",
        ]
        return random.choice(responses)
    
    # Greeting responses
    elif any(word in message for word in ['hi', 'hello', 'hey', 'greetings']):
        responses = [
            "Hello! Welcome to Wesalvator Animal Rescue. How can I assist you today?",
            "Hi there! I'm here to help with adoptions, donations, or rescue information. What brings you here?",
            "Welcome! I'm Wesalvator's virtual assistant. What would you like to know about our animal rescue services?",
        ]
        return random.choice(responses)
    
    # Default/unclear responses
    else:
        responses = [
            "I'm here to help with:\n"
            "1. Animal Adoption\n"
            "2. Donations\n"
            "3. Animal Rescue\n"
            "4. Volunteering\n"
            "What would you like to know more about?",
            
            "I'm not sure I understood that. Could you please specify if you're interested in:\n"
            "- Adopting a pet\n"
            "- Making a donation\n"
            "- Reporting an animal in need\n"
            "- Volunteering opportunities",
            
            "Let me help you better! Are you looking for information about:\n"
            "- Our rescue services\n"
            "- Adoption process\n"
            "- Ways to contribute\n"
            "- Volunteer programs",
        ]
        return random.choice(responses)

@login_required
def chat_home(request):
    chat_history = ChatMessage.objects.filter(user=request.user)
    return render(request, 'chatbot/chat.html', {'chat_history': chat_history})

@login_required
@require_http_methods(["POST"])
def get_bot_response(request):
    try:
        user_message = request.POST.get('message')
        if not user_message:
            return JsonResponse({'error': 'No message provided'}, status=400)
            
        # Get the appropriate response using the enhanced function
        bot_response = generate_bot_response(user_message)
        
        # Save the conversation
        ChatMessage.objects.create(
            user=request.user,
            user_message=user_message,
            bot_response=bot_response
        )
        
        return JsonResponse({'response': bot_response})
    except Exception as e:
        print(f"Error processing message: {str(e)}")  # For debugging
        return JsonResponse({'error': 'Internal server error'}, status=500)
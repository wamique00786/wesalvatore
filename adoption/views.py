from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .models import AdoptableAnimal
from .forms import AdoptableAnimalForm

def adopt_view(request):
    animals = AdoptableAnimal.objects.filter(is_adoptable=True)
    return render(request, 'adoption/adopt.html', {'animals': animals})

def adopt_animal(request):
    # Fetch all adoptable animals
    adoptable_animals = AdoptableAnimal.objects.filter(is_adoptable=True)

    context = {
        'adoptable_animals': adoptable_animals,
    }

    return render(request, 'adoption/adopt_animal.html', context)

@login_required
def add_adoptable_animal(request):
    #if request.user.userprofile.user_type != 'ADMIN':
        #return redirect('not_authorized')  # Redirect to a 'not authorized' page

    if request.method == 'POST':
        form = AdoptableAnimalForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect('adoptable_animals_list')
    else:
        form = AdoptableAnimalForm()
    return render(request, 'adoption/add_adoptable_animal.html', {'form': form})

def adoptable_animals_list(request):
    adoptable_animals = AdoptableAnimal.objects.all()  # Fetch all adoptable animals
    return render(request, 'adoption/adopt_animal.html', {'adoptable_animals': adoptable_animals})  # Render the template with the animals




from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from .models import Donation, NGO
from .forms import DonationForm

def donations(request):
    # Fetch all donations
    donations_list = Donation.objects.all().order_by('-date')

    context = {
        'donations': donations_list,
    }

    return render(request, 'donation/donations.html', context)

def donations_view(request):
   donations = Donation.objects.all()  # Fetch all donations from the database
   return render(request, 'donation/donations.html', {'donations': donations})

@login_required
def donate_view(request):
    if request.method == 'POST':
        form = DonationForm(request.POST)
        if form.is_valid():
            donation = Donation(
                user=request.user,
                amount=form.cleaned_data['amount'],
                ngo=form.cleaned_data['ngo']  # Save the selected NGO
            )
            donation.save()
            return redirect('donation_success')  # Redirect to a success page
    else:
        form = DonationForm()
    
    ngos = NGO.objects.all()  # Fetch all NGOs
    return render(request, 'donation/donate.html', {'form': form, 'ngos': ngos})

def donation_success_view(request):
   return render(request, 'donation/donation_success.html')

@login_required
def donation_list(request):
    donations = Donation.objects.all().order_by('-date')  # Fetch all donations
    ngos = NGO.objects.all()  # Fetch all NGOs
    return render(request, 'donation/donation_list.html', {'donations': donations, 'ngos': ngos})

@login_required
def donate_to_ngo(request, ngo_id):
    ngo = get_object_or_404(NGO, id=ngo_id)

    if request.method == 'POST':
        form = DonationForm(request.POST)
        if form.is_valid():
            donation = Donation(
                user=request.user,
                amount=form.cleaned_data['amount'],
                ngo=ngo  # Set the selected NGO
            )
            donation.save()
            return redirect('donation_success')  # Redirect to a success page
    else:
        form = DonationForm()

    return render(request, 'donation/donate_to_ngo.html', {'form': form, 'ngo': ngo})

def ngo_list(request):
    print("ngo_list view is called")  # Debugging line
    ngos = NGO.objects.all()  # Fetch all NGOs
    return render(request, 'donation/ngo_list.html', {'ngos': ngos})

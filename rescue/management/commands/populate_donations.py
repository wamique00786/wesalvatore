# your_app/management/commands/populate_donations.py
from django.core.management.base import BaseCommand
from rescue.models import Donation, NGO
from django.contrib.auth.models import User

class Command(BaseCommand):
    help = 'Populate the database with sample donations'

    def handle(self, *args, **kwargs):
        # Assuming you have at least one user and one NGO in the database
        user = User.objects.first()  # Get the first user
        ngos = NGO.objects.all()  # Get all NGOs

        donations = [
            {'user': user, 'amount': 50.00, 'ngo': ngos[0]},
            {'user': user, 'amount': 75.00, 'ngo': ngos[1]},
            {'user': user, 'amount': 100.00, 'ngo': ngos[2]},
            {'user': user, 'amount': 25.00, 'ngo': ngos[3]},
            {'user': user, 'amount': 150.00, 'ngo': ngos[4]},
        ]

        for donation in donations:
            Donation.objects.get_or_create(
                user=donation['user'],
                amount=donation['amount'],
                ngo=donation['ngo']
            )
        
        self.stdout.write(self.style.SUCCESS('Successfully populated donations'))
# your_app/management/commands/populate_ngos.py
from django.core.management.base import BaseCommand
from rescue.models import NGO

class Command(BaseCommand):
    help = 'Populate the database with sample NGOs'

    def handle(self, *args, **kwargs):
        ngos = [
            {'name': 'Animal Welfare Society', 'description': 'Dedicated to the rescue and rehabilitation of animals.', 'website': 'https://aws.org'},
            {'name': 'Save the Animals', 'description': 'Working towards the protection of endangered species.', 'website': 'https://saveanimals.org'},
            {'name': 'Pet Rescue Foundation', 'description': 'A non-profit organization focused on rescuing pets in need.', 'website': 'https://petrescue.org'},
            {'name': 'Wildlife Conservation Society', 'description': 'Committed to conserving wildlife and wild places.', 'website': 'https://wcs.org'},
            {'name': 'Humane Society International', 'description': 'Advocating for animal welfare worldwide.', 'website': 'https://hsi.org'},
        ]

        for ngo in ngos:
            NGO.objects.get_or_create(
                name=ngo['name'],
                description=ngo['description'],
                website=ngo['website']
            )
        
        self.stdout.write(self.style.SUCCESS('Successfully populated NGOs'))
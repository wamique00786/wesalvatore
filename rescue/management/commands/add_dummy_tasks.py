from django.core.management.base import BaseCommand
from rescue.models import RescueTask
from django.contrib.auth.models import User

class Command(BaseCommand):
    help = 'Add dummy tasks for testing'

    def handle(self, *args, **kwargs):
        # Assuming you have a volunteer user with ID 1
        volunteer_user = User.objects.get(username='volunteer2')

        # Create dummy tasks
        tasks = [
            RescueTask(title='Rescue a stray dog', description='A stray dog has been spotted near the park.', assigned_to=volunteer_user),
            RescueTask(title='Feed the cats at the shelter', description='Feed the cats and check their health.', assigned_to=volunteer_user),
            RescueTask(title='Transport injured animal to vet', description='An injured animal needs to be taken to the vet.', assigned_to=volunteer_user),
            RescueTask(title='Clean the animal shelter', description='Help clean the shelter and prepare for new arrivals.', assigned_to=volunteer_user),
            RescueTask(title='Adopt a pet event', description='Assist in organizing the adoption event this weekend.', assigned_to=volunteer_user),
        ]

        # Save the tasks to the database
        RescueTask.objects.bulk_create(tasks)
        self.stdout.write(self.style.SUCCESS('Dummy tasks created successfully.'))
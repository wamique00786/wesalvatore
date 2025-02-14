from django.db import models

class JobOpening(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    posted_on = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

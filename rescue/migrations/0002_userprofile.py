# Generated by Django 5.1.4 on 2024-12-15 12:41

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("rescue", "0001_initial"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="UserProfile",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "user_type",
                    models.CharField(
                        choices=[
                            ("USER", "Regular User"),
                            ("VOLUNTEER", "Volunteer"),
                            ("ADMIN", "Administrator"),
                        ],
                        default="USER",
                        max_length=20,
                    ),
                ),
                ("phone", models.CharField(blank=True, max_length=15)),
                ("address", models.TextField(blank=True)),
                (
                    "user",
                    models.OneToOneField(
                        on_delete=django.db.models.deletion.CASCADE,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]
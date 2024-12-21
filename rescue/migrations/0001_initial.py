# Generated by Django 5.1.4 on 2024-12-14 16:00

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="Animal",
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
                ("name", models.CharField(max_length=100)),
                (
                    "species",
                    models.CharField(
                        choices=[
                            ("DOG", "Dog"),
                            ("CAT", "Cat"),
                            ("BIRD", "Bird"),
                            ("OTHER", "Other"),
                        ],
                        max_length=50,
                    ),
                ),
                ("rescue_date", models.DateField()),
                (
                    "status",
                    models.CharField(
                        choices=[
                            ("RESCUED", "Rescued"),
                            ("TREATMENT", "Under Treatment"),
                            ("RECOVERED", "Recovered"),
                            ("ADOPTED", "Adopted"),
                        ],
                        max_length=50,
                    ),
                ),
                ("medical_needs", models.TextField()),
                ("rescue_location", models.CharField(max_length=200)),
                (
                    "photo",
                    models.ImageField(
                        blank=True, null=True, upload_to="animal_photos/"
                    ),
                ),
                (
                    "assigned_to",
                    models.ForeignKey(
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
        migrations.CreateModel(
            name="MedicalRecord",
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
                ("date", models.DateField()),
                ("treatment", models.TextField()),
                ("notes", models.TextField()),
                (
                    "animal",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE, to="rescue.animal"
                    ),
                ),
                (
                    "created_by",
                    models.ForeignKey(
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]
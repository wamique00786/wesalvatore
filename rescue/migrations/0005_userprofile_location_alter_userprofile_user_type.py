# Generated by Django 5.1.4 on 2024-12-18 12:02

import django.contrib.gis.db.models.fields
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("rescue", "0004_animalreport"),
    ]

    operations = [
        migrations.AddField(
            model_name="userprofile",
            name="location",
            field=django.contrib.gis.db.models.fields.PointField(
                blank=True, null=True, srid=4326
            ),
        ),
        migrations.AlterField(
            model_name="userprofile",
            name="user_type",
            field=models.CharField(
                choices=[
                    ("USER", "User"),
                    ("VOLUNTEER", "Volunteer"),
                    ("ADMIN", "Admin"),
                ],
                max_length=20,
            ),
        ),
    ]

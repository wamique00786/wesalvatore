# Generated by Django 5.1.4 on 2024-12-23 11:02

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("rescue", "0010_alter_adoptableanimal_options"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name="medicalrecord",
            name="added_by",
            field=models.ForeignKey(
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name="added_animals",
                to=settings.AUTH_USER_MODEL,
            ),
        ),
    ]
# Generated by Django 5.1.4 on 2024-12-15 13:09

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("rescue", "0002_userprofile"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="userprofile",
            name="address",
        ),
        migrations.RemoveField(
            model_name="userprofile",
            name="phone",
        ),
    ]
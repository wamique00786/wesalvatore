# Generated by Django 5.1.4 on 2025-01-27 11:54

import phonenumber_field.modelfields
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0008_alter_userprofile_mobile_number'),
    ]

    operations = [
        migrations.AlterField(
            model_name='userprofile',
            name='mobile_number',
            field=phonenumber_field.modelfields.PhoneNumberField(blank=True, max_length=128, null=True, region=None),
        ),
    ]

# Generated by Django 5.1.4 on 2024-12-21 16:49

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("rescue", "0009_alter_medicalrecord_animal_volunteerprofile"),
    ]

    operations = [
        migrations.AlterModelOptions(
            name="adoptableanimal",
            options={
                "permissions": [
                    ("can_add_adoptable_animal", "Can add adoptable animal")
                ]
            },
        ),
    ]

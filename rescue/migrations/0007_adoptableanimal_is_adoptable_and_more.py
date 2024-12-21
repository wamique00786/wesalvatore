# Generated by Django 5.1.4 on 2024-12-20 13:33

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("rescue", "0006_adoptableanimal_donation"),
    ]

    operations = [
        migrations.AddField(
            model_name="adoptableanimal",
            name="is_adoptable",
            field=models.BooleanField(default=True),
        ),
        migrations.AlterField(
            model_name="adoptableanimal",
            name="photo",
            field=models.ImageField(upload_to="animal_photos/"),
        ),
    ]